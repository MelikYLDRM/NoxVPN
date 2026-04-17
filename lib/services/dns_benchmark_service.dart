import 'dart:io';

class DnsBenchmarkService {
  static const _dnsProviders = {
    'cloudflare': ['1.1.1.1', '1.0.0.1'],
    'google': ['8.8.8.8', '8.8.4.4'],
    'quad9': ['9.9.9.9', '149.112.112.112'],
  };

  static const _testDomains = ['google.com', 'cloudflare.com', 'amazon.com'];

  /// Benchmark a single DNS server by measuring lookup times
  static Future<int> _benchmarkDns(String dnsServer) async {
    var totalMs = 0;
    var successCount = 0;

    for (final domain in _testDomains) {
      try {
        final stopwatch = Stopwatch()..start();
        await InternetAddress.lookup(domain);
        stopwatch.stop();
        totalMs += stopwatch.elapsedMilliseconds;
        successCount++;
      } catch (_) {
        totalMs += 3000; // Penalty for failure
      }
    }

    if (successCount == 0) return 9999;
    return totalMs ~/ _testDomains.length;
  }

  /// Find the fastest DNS provider and return its servers
  static Future<List<String>> findBestDns() async {
    final results = <String, int>{};

    final futures = _dnsProviders.entries.map((entry) async {
      final avgMs = await _benchmarkDns(entry.value.first);
      return MapEntry(entry.key, avgMs);
    });

    final benchmarks = await Future.wait(futures);
    for (final entry in benchmarks) {
      results[entry.key] = entry.value;
    }

    final sorted = results.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    final bestProvider = sorted.first.key;
    return _dnsProviders[bestProvider]!;
  }
}
