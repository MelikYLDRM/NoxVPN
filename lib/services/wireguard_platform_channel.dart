import 'package:flutter/services.dart';

import '../core/constants/app_constants.dart';
import '../data/models/connection_stats.dart';
import '../data/models/server_config.dart';
import '../data/models/vpn_status.dart';
import 'vpn_engine.dart';

class WireGuardPlatformChannel implements VpnEngine {
  static const _channel = MethodChannel(AppConstants.vpnChannelName);

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
}
