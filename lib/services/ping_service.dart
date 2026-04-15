import 'dart:io';

class PingService {
  /// Measure latency to a WireGuard endpoint by attempting a TCP connection.
  /// Returns latency in milliseconds, or -1 on failure.
  static Future<int> measurePing(String endpoint) async {
    try {
      final parts = endpoint.split(':');
      if (parts.length < 2) return -1;

      final host = parts[0];
      final port = int.tryParse(parts[1]) ?? 51820;

      final stopwatch = Stopwatch()..start();
      final socket = await Socket.connect(
        host,
        port,
        timeout: const Duration(seconds: 3),
      );
      stopwatch.stop();
      socket.destroy();

      return stopwatch.elapsedMilliseconds;
    } catch (_) {
      // TCP connection may be refused but latency is still measurable
      // from the time it took to get the rejection
      return -1;
    }
  }

  /// Measure ping using DNS lookup as fallback (works for most hosts)
  static Future<int> measureDnsLatency(String endpoint) async {
    try {
      final host = endpoint.split(':').first;
      final stopwatch = Stopwatch()..start();
      await InternetAddress.lookup(host);
      stopwatch.stop();
      return stopwatch.elapsedMilliseconds;
    } catch (_) {
      return -1;
    }
  }

  /// Best-effort ping: try TCP first, fall back to DNS lookup
  static Future<int> ping(String endpoint) async {
    if (endpoint.isEmpty) return -1;

    final tcpResult = await measurePing(endpoint);
    if (tcpResult > 0) return tcpResult;

    return await measureDnsLatency(endpoint);
  }
}
