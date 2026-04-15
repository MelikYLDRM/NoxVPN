import '../data/models/connection_stats.dart';
import '../data/models/server_config.dart';
import '../data/models/vpn_status.dart';

abstract class VpnEngine {
  Future<bool> prepareVpn();
  Future<bool> connect(
    ServerConfig server, {
    required String clientPrivateKey,
    bool killSwitch = false,
    List<String> excludedApps = const [],
  });
  Future<bool> disconnect();
  Future<VpnConnectionStatus> getStatus();
  Future<ConnectionStats?> getStatistics();
  Future<Map<String, String>> generateKeyPair();
}
