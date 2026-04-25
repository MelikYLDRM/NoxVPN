/// Bilinen Cloudflare WARP endpoint'leri.
///
/// Cloudflare WARP, anycast IP'ler kullanır — her endpoint sizi en yakın
/// edge POP'a (300+ şehir) yönlendirir. Birden fazla farklı /24 öneki
/// listelemek, ISP'nizin BGP tablo durumuna göre farklı yollar açar ve
/// kayıp/tıkanıklık olduğunda alternatif yol bulmamızı sağlar.
///
/// Kaynak: Cloudflare WARP infrastructure (cloudflareclient.com)
class WarpEndpoints {
  static const List<WarpEndpoint> endpoints = [
    // 162.159.192.0/24 — birincil WARP anycast bloğu
    WarpEndpoint(
      host: '162.159.192.1',
      port: 2408,
      label: 'WARP',
      region: 'Auto (Anycast)',
    ),
    WarpEndpoint(
      host: '162.159.192.7',
      port: 2408,
      label: 'WARP B',
      region: 'Auto (Anycast)',
    ),
    // 162.159.193.0/24
    WarpEndpoint(
      host: '162.159.193.1',
      port: 2408,
      label: 'WARP C',
      region: 'Auto (Anycast)',
    ),
    WarpEndpoint(
      host: '162.159.193.10',
      port: 2408,
      label: 'WARP D',
      region: 'Auto (Anycast)',
    ),
    // 162.159.195.0/24
    WarpEndpoint(
      host: '162.159.195.1',
      port: 2408,
      label: 'WARP E',
      region: 'Auto (Anycast)',
    ),
    WarpEndpoint(
      host: '162.159.195.10',
      port: 2408,
      label: 'WARP F',
      region: 'Auto (Anycast)',
    ),
    // Yedek portlar — bazı ISP'ler 2408'i throttle/blok ediyor
    WarpEndpoint(
      host: '162.159.192.1',
      port: 1701,
      label: 'WARP (Port 1701)',
      region: 'Bypass',
    ),
    WarpEndpoint(
      host: '162.159.192.1',
      port: 500,
      label: 'WARP (Port 500)',
      region: 'Bypass',
    ),
  ];

  /// Endpoint string listesi (host:port)
  static List<String> get allEndpointStrings =>
      endpoints.map((e) => e.endpointString).toList();
}

class WarpEndpoint {
  final String host;
  final int port;
  final String label;
  final String region;

  const WarpEndpoint({
    required this.host,
    required this.port,
    required this.label,
    required this.region,
  });

  String get endpointString => '$host:$port';
}
