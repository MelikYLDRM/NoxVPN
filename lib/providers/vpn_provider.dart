import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/constants/app_constants.dart';
import '../data/models/connection_stats.dart';
import '../data/models/server_config.dart';
import '../data/models/vpn_status.dart';
import '../services/mock_vpn_engine.dart';
import '../services/vpn_engine.dart';
import '../services/wireguard_platform_channel.dart';
import 'settings_provider.dart';

final vpnEngineProvider = Provider<VpnEngine>((ref) {
  if (AppConstants.kDemoMode) {
    return MockVpnEngine();
  }
  return WireGuardPlatformChannel();
});

final clientKeyPairProvider = FutureProvider<Map<String, String>>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final storedPrivate = prefs.getString('wg_private_key');
  final storedPublic = prefs.getString('wg_public_key');
  if (storedPrivate != null && storedPublic != null) {
    return {'privateKey': storedPrivate, 'publicKey': storedPublic};
  }
  final engine = ref.read(vpnEngineProvider);
  final keyPair = await engine.generateKeyPair();
  await prefs.setString('wg_private_key', keyPair['privateKey']!);
  await prefs.setString('wg_public_key', keyPair['publicKey']!);
  return keyPair;
});

final vpnStateProvider = StateNotifierProvider<VpnNotifier, VpnState>((ref) {
  return VpnNotifier(ref);
});

class VpnNotifier extends StateNotifier<VpnState> {
  final Ref _ref;
  int _retryCount = 0;
  static const int _maxRetries = 5;
  Timer? _healthTimer;
  bool _isReconnecting = false;

  VpnNotifier(this._ref) : super(VpnState.disconnected());

  Future<void> connect(ServerConfig server) async {
    _retryCount = 0;
    _isReconnecting = false;
    await _connectInternal(server);
  }

  Future<void> _connectInternal(ServerConfig server) async {
    if (!_isReconnecting) {
      state = state.copyWith(
        status: VpnConnectionStatus.requestingPermission,
        activeServer: server,
        clearError: true,
      );
    }

    final engine = _ref.read(vpnEngineProvider);

    final permitted = await engine.prepareVpn();
    if (!permitted) {
      _stopHealthMonitor();
      state = state.copyWith(
        status: VpnConnectionStatus.error,
        errorMessage: '@vpnPermissionDenied',
      );
      return;
    }

    if (_isReconnecting) {
      state = state.copyWith(
        status: VpnConnectionStatus.reconnecting,
        clearError: true,
      );
    } else {
      state = state.copyWith(status: VpnConnectionStatus.connecting);
    }

    try {
      String privateKey;
      if (server.hasPrivateKey) {
        privateKey = server.clientPrivateKey!;
      } else {
        final keyPair = await _ref.read(clientKeyPairProvider.future);
        privateKey = keyPair['privateKey']!;
      }

      final settings = _ref.read(settingsProvider);

      // Apply DNS from auto benchmark if mode is 'auto'
      List<String> dnsServers = settings.activeDnsServers;
      if (settings.dnsMode == 'auto') {
        try {
          final autoDns = await _ref.read(autoDnsProvider.future);
          dnsServers = autoDns;
        } catch (_) {
          // Fallback to default
        }
      }

      final serverWithSettings = server.copyWith(
        dnsServers: dnsServers,
        persistentKeepalive: settings.keepaliveInterval,
        allowedIPs: settings.activeAllowedIPs,
      );

      final success = await engine.connect(
        serverWithSettings,
        clientPrivateKey: privateKey,
        killSwitch: settings.killSwitchEnabled,
        excludedApps: settings.excludedApps,
      );

      if (success) {
        var tunnelUp = false;
        for (int i = 0; i < 30; i++) {
          await Future.delayed(const Duration(milliseconds: 500));
          final realStatus = await engine.getStatus();
          if (realStatus == VpnConnectionStatus.connected) {
            tunnelUp = true;
            break;
          }
          if (realStatus == VpnConnectionStatus.error ||
              realStatus == VpnConnectionStatus.disconnected) {
            break;
          }
        }

        if (tunnelUp) {
          _retryCount = 0;
          _isReconnecting = false;
          state = state.copyWith(
            status: VpnConnectionStatus.connected,
            connectedSince: state.connectedSince ?? DateTime.now(),
          );
          _startHealthMonitor(server);
          // DNS önbelleğini ve WireGuard handshake'ini ısıt — ilk tıklama
          // gecikmesini önler. Bağlantı UI'ı bloklamasın diye unawaited.
          unawaited(_warmUpTunnel());
        } else {
          await _retryOrFail(server, '@tunnelFailed');
        }
      } else {
        await _retryOrFail(server, '@connectionFailed');
      }
    } catch (e) {
      _stopHealthMonitor();
      state = state.copyWith(
        status: VpnConnectionStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> _retryOrFail(ServerConfig server, String errorKey) async {
    if (_retryCount < _maxRetries) {
      _retryCount++;
      final delay = Duration(
        seconds: _retryCount <= 3 ? _retryCount * 2 : _retryCount * 3,
      );
      await Future.delayed(delay);
      if (mounted) {
        await _connectInternal(server);
      }
    } else {
      _stopHealthMonitor();
      _isReconnecting = false;
      state = state.copyWith(
        status: VpnConnectionStatus.error,
        errorMessage: '$errorKey:$_maxRetries',
      );
    }
  }

  void _startHealthMonitor(ServerConfig server) {
    _stopHealthMonitor();
    _healthTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      if (!mounted) {
        _stopHealthMonitor();
        return;
      }

      final engine = _ref.read(vpnEngineProvider);
      try {
        final status = await engine.getStatus();
        if (status != VpnConnectionStatus.connected && mounted) {
          _stopHealthMonitor();
          _isReconnecting = true;
          _retryCount = 0;
          state = state.copyWith(
            status: VpnConnectionStatus.reconnecting,
            clearError: true,
          );
          await _connectInternal(server);
        }
      } catch (_) {
        // Ignore transient errors in health check
      }
    });
  }

  void _stopHealthMonitor() {
    _healthTimer?.cancel();
    _healthTimer = null;
  }

  /// Tünel kurulduktan sonra paralel olarak birkaç kritik domaini DNS
  /// üzerinden çözerek WireGuard handshake'ini ve OS DNS önbelleğini
  /// ısıtır. Böylece kullanıcının ilk tarayıcı tıklaması bekletilmez.
  Future<void> _warmUpTunnel() async {
    const domains = [
      'www.google.com',
      'www.cloudflare.com',
      'www.youtube.com',
      'www.facebook.com',
    ];
    try {
      await Future.wait(
        domains.map(
          (d) => InternetAddress.lookup(d)
              .timeout(const Duration(seconds: 3))
              .catchError((_) => <InternetAddress>[]),
        ),
      );
    } catch (_) {
      // Sessizce yut — warm-up best-effort.
    }
  }

  Future<void> disconnect() async {
    _stopHealthMonitor();
    _isReconnecting = false;
    state = state.copyWith(status: VpnConnectionStatus.disconnecting);
    final engine = _ref.read(vpnEngineProvider);
    await engine.disconnect();
    state = VpnState.disconnected();
  }

  @override
  void dispose() {
    _stopHealthMonitor();
    super.dispose();
  }
}

final connectionStatsProvider = StreamProvider<ConnectionStats>((ref) async* {
  final vpnState = ref.watch(vpnStateProvider);
  if (vpnState.status != VpnConnectionStatus.connected) return;

  final engine = ref.read(vpnEngineProvider);
  while (true) {
    await Future.delayed(AppConstants.statsPollingInterval);

    final currentState = ref.read(vpnStateProvider);
    if (currentState.status != VpnConnectionStatus.connected) return;

    final stats = await engine.getStatistics();
    if (stats != null) {
      yield stats;
    }
  }
});
