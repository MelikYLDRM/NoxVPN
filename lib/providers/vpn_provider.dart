import 'dart:async';

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

  VpnNotifier(this._ref) : super(VpnState.disconnected());

  Future<void> connect(ServerConfig server) async {
    state = state.copyWith(
      status: VpnConnectionStatus.requestingPermission,
      activeServer: server,
      clearError: true,
    );

    final engine = _ref.read(vpnEngineProvider);

    final permitted = await engine.prepareVpn();
    if (!permitted) {
      state = state.copyWith(
        status: VpnConnectionStatus.error,
        errorMessage: 'VPN permission denied',
      );
      return;
    }

    state = state.copyWith(status: VpnConnectionStatus.connecting);

    try {
      // Use private key from imported config if available, otherwise generate
      String privateKey;
      if (server.hasPrivateKey) {
        privateKey = server.clientPrivateKey!;
      } else {
        final keyPair = await _ref.read(clientKeyPairProvider.future);
        privateKey = keyPair['privateKey']!;
      }

      final settings = _ref.read(settingsProvider);

      // Apply DNS from settings to server config
      final serverWithDns = server.copyWith(
        dnsServers: settings.activeDnsServers,
      );

      final success = await engine.connect(
        serverWithDns,
        clientPrivateKey: privateKey,
      );

      if (success) {
        // The native side starts the service asynchronously.
        // Poll the real tunnel status for up to 15 seconds.
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
          state = state.copyWith(
            status: VpnConnectionStatus.connected,
            connectedSince: DateTime.now(),
          );
        } else {
          state = state.copyWith(
            status: VpnConnectionStatus.error,
            errorMessage: 'Tunnel failed to establish',
          );
        }
      } else {
        state = state.copyWith(
          status: VpnConnectionStatus.error,
          errorMessage: 'Connection failed',
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: VpnConnectionStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> disconnect() async {
    state = state.copyWith(status: VpnConnectionStatus.disconnecting);
    final engine = _ref.read(vpnEngineProvider);
    await engine.disconnect();
    state = VpnState.disconnected();
  }
}

final connectionStatsProvider = StreamProvider<ConnectionStats>((ref) async* {
  final vpnState = ref.watch(vpnStateProvider);
  if (vpnState.status != VpnConnectionStatus.connected) return;

  final engine = ref.read(vpnEngineProvider);
  while (true) {
    await Future.delayed(AppConstants.statsPollingInterval);
    final stats = await engine.getStatistics();
    if (stats != null) {
      yield stats;
    }
  }
});
