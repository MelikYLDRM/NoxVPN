import 'dart:math';

import '../data/models/connection_stats.dart';
import '../data/models/server_config.dart';
import '../data/models/vpn_status.dart';
import 'vpn_engine.dart';

class MockVpnEngine implements VpnEngine {
  VpnConnectionStatus _status = VpnConnectionStatus.disconnected;
  DateTime? _connectedSince;
  int _mockDownload = 0;
  int _mockUpload = 0;
  final _random = Random();

  @override
  Future<bool> prepareVpn() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return true;
  }

  @override
  Future<bool> connect(
    ServerConfig server, {
    required String clientPrivateKey,
  }) async {
    _status = VpnConnectionStatus.connecting;
    await Future.delayed(const Duration(seconds: 2));
    _status = VpnConnectionStatus.connected;
    _connectedSince = DateTime.now();
    _mockDownload = 0;
    _mockUpload = 0;
    return true;
  }

  @override
  Future<bool> disconnect() async {
    _status = VpnConnectionStatus.disconnecting;
    await Future.delayed(const Duration(seconds: 1));
    _status = VpnConnectionStatus.disconnected;
    _connectedSince = null;
    return true;
  }

  @override
  Future<VpnConnectionStatus> getStatus() async {
    return _status;
  }

  @override
  Future<ConnectionStats?> getStatistics() async {
    if (_status != VpnConnectionStatus.connected || _connectedSince == null) {
      return null;
    }

    // Simulate traffic
    final dlIncrement = _random.nextInt(500000) + 100000;
    final ulIncrement = _random.nextInt(200000) + 50000;
    _mockDownload += dlIncrement;
    _mockUpload += ulIncrement;

    return ConnectionStats(
      downloadBytes: _mockDownload,
      uploadBytes: _mockUpload,
      downloadSpeedBps: dlIncrement.toDouble(),
      uploadSpeedBps: ulIncrement.toDouble(),
      connectionDuration: DateTime.now().difference(_connectedSince!),
    );
  }

  @override
  Future<Map<String, String>> generateKeyPair() async {
    return {
      'privateKey': 'MOCK_PRIVATE_KEY_BASE64_ENCODED==',
      'publicKey': 'MOCK_PUBLIC_KEY_BASE64_ENCODED==',
    };
  }
}
