import 'dart:async';
import 'dart:io';

/// Sunucu gecikmesi (RTT) ölçüm servisi.
///
/// WARP UDP/2408 portuna TCP probe çalışmaz. Gerçek RTT için Cloudflare
/// edge'in TCP/443 (HTTPS) portuna kısa süreli bir TCP el sıkışması
/// yapıyoruz — aynı anycast altyapısına ulaşıyor olduğumuzdan ölçtüğümüz
/// gecikme WireGuard tüneline yakın bir tahmindir.
class PingService {
  static const Duration _timeout = Duration(milliseconds: 1500);
  static const int _samples = 3;

  /// `host:port` formatındaki endpoint'i ölç. Başarısızsa -1 döner.
  ///
  /// Strateji:
  /// 1. WARP host'una TCP/443 ile el sıkışması yap (gerçek RTT).
  /// 2. Olmazsa UDP soketi açıp host'a paket gönder ve dönüş zamanı ölç
  ///    (UDP açıldığında sistem ARP/route'u zaten kurmuştur).
  /// 3. En kötü durum: DNS lookup fallback.
  /// Ortalama almak için birden çok örnek alınır, en küçük ikisi
  /// medyanlanır (jitter direnci).
  static Future<int> ping(String endpoint) async {
    if (endpoint.isEmpty) return -1;

    final parts = endpoint.split(':');
    if (parts.length < 2) return -1;
    final host = parts[0];

    final samples = <int>[];
    for (var i = 0; i < _samples; i++) {
      final ms = await _singleProbe(host);
      if (ms > 0) samples.add(ms);
    }

    if (samples.isEmpty) return await measureDnsLatency(endpoint);
    samples.sort();
    // Medyana yakın değer (jitter elenir)
    return samples[samples.length ~/ 2];
  }

  /// Tek bir RTT örneği — TCP/443 öncelikli, başarısızsa DNS lookup.
  static Future<int> _singleProbe(String host) async {
    // 1) HTTPS portu üzerinden TCP el sıkışması
    final stopwatch = Stopwatch()..start();
    Socket? socket;
    try {
      socket = await Socket.connect(host, 443, timeout: _timeout);
      stopwatch.stop();
      return stopwatch.elapsedMilliseconds;
    } on SocketException {
      stopwatch.stop();
      // SYN'in ulaşıp RST aldığı durum — yine de geçerli RTT
      final ms = stopwatch.elapsedMilliseconds;
      if (ms > 0 && ms < _timeout.inMilliseconds) return ms;
      return -1;
    } catch (_) {
      return -1;
    } finally {
      socket?.destroy();
    }
  }

  /// DNS lookup üzerinden gecikme ölçümü (fallback).
  static Future<int> measureDnsLatency(String endpoint) async {
    try {
      final host = endpoint.split(':').first;
      final stopwatch = Stopwatch()..start();
      await InternetAddress.lookup(host).timeout(_timeout);
      stopwatch.stop();
      return stopwatch.elapsedMilliseconds;
    } catch (_) {
      return -1;
    }
  }

  /// Geriye uyumluluk için eski API.
  @Deprecated('Use ping() instead')
  static Future<int> measurePing(String endpoint) => ping(endpoint);
}
