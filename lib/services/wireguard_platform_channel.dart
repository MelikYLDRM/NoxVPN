import 'package:flutter/services.dart';

import '../core/constants/app_constants.dart';
import '../data/models/connection_stats.dart';
import '../data/models/server_config.dart';
import '../data/models/vpn_status.dart';
import 'vpn_engine.dart';

class WireGuardPlatformChannel implements VpnEngine {
  static const _channel = MethodChannel(AppConstants.vpnChannelName);
  static const _eventChannel = EventChannel(AppConstants.vpnEventChannelName);

  /// Stream of VPN status changes pushed from native side
  static Stream<VpnConnectionStatus> get statusStream {
    return _eventChannel.receiveBroadcastStream().map((event) {
      final statusName = event as String;
      return VpnConnectionStatus.values.firstWhere(
        (s) => s.name == statusName,
        orElse: () => VpnConnectionStatus.disconnected,
      );
    });
  }

  @override
  Future<bool> prepareVpn() async {
    try {
      final result = await _channel.invokeMethod<bool>('prepareVpn');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<bool> connect(
    ServerConfig server, {
    required String clientPrivateKey,
    bool killSwitch = false,
    List<String> excludedApps = const [],
  }) async {
    try {
      final config = {
        'privateKey': clientPrivateKey,
        'address': server.clientAddress,
        'dns': server.dnsServers.join(','),
        'mtu': server.mtu,
        'publicKey': server.serverPublicKey,
        'endpoint': server.endpoint,
        'allowedIPs': server.allowedIPs.join(','),
        'presharedKey': server.presharedKey ?? '',
        'persistentKeepalive': server.persistentKeepalive,
        'killSwitch': killSwitch,
        'excludedApps': excludedApps,
      };
      final result = await _channel.invokeMethod<bool>('connect', config);
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<bool> disconnect() async {
    try {
      final result = await _channel.invokeMethod<bool>('disconnect');
      return result ?? false;
    } on PlatformException {
      return false;
    }
  }

  @override
  Future<VpnConnectionStatus> getStatus() async {
    try {
      final result = await _channel.invokeMethod<String>('getStatus');
      return VpnConnectionStatus.values.firstWhere(
        (s) => s.name == result,
        orElse: () => VpnConnectionStatus.disconnected,
      );
    } on PlatformException {
      return VpnConnectionStatus.disconnected;
    }
  }

  @override
  Future<ConnectionStats?> getStatistics() async {
    try {
      final result = await _channel.invokeMethod<Map<Object?, Object?>>(
        'getStatistics',
      );
      if (result == null) return null;
      return ConnectionStats(
        downloadBytes: (result['downloadBytes'] as int?) ?? 0,
        uploadBytes: (result['uploadBytes'] as int?) ?? 0,
        downloadSpeedBps: (result['downloadSpeedBps'] as num?)?.toDouble() ?? 0,
        uploadSpeedBps: (result['uploadSpeedBps'] as num?)?.toDouble() ?? 0,
      );
    } on PlatformException {
      return null;
    }
  }

  @override
  Future<Map<String, String>> generateKeyPair() async {
    try {
      final result = await _channel.invokeMethod<Map<Object?, Object?>>(
        'generateKeyPair',
      );
      if (result == null) {
        throw PlatformException(code: 'NULL_RESULT');
      }
      return {
        'privateKey': result['privateKey'] as String,
        'publicKey': result['publicKey'] as String,
      };
    } on PlatformException {
      rethrow;
    }
  }

  Future<List<Map<String, String>>> getInstalledApps() async {
    try {
      final result = await _channel.invokeMethod<List<Object?>>(
        'getInstalledApps',
      );
      if (result == null) return [];
      return result.map((item) {
        final map = item as Map<Object?, Object?>;
        return {
          'packageName': map['packageName'] as String? ?? '',
          'appName': map['appName'] as String? ?? '',
        };
      }).toList();
    } on PlatformException {
      return [];
    }
  }
}
