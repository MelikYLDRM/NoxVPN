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
      try {
        final socket = await Socket.connect(
          host,
          port,
          timeout: const Duration(milliseconds: 1500),
        );
        stopwatch.stop();
        socket.destroy();
        return stopwatch.elapsedMilliseconds;
      } on SocketException {
        stopwatch.stop();
        // Connection refused still gives us a latency measurement
        // since the packet reached the host and came back
        final elapsed = stopwatch.elapsedMilliseconds;
        if (elapsed > 0 && elapsed < 1500) {
          return elapsed;
        }
        return -1;
      }
    } catch (_) {
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
