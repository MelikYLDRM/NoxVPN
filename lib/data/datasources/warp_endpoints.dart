/// Known Cloudflare WARP endpoints for multi-endpoint selection.
/// These are Cloudflare's primary anycast IPs for the WARP service.
/// The same registration works with any of these endpoints.
class WarpEndpoints {
  static const List<WarpEndpoint> endpoints = [
    WarpEndpoint(
      host: '162.159.192.1',
      port: 2408,
      label: 'WARP',
      region: 'Global',
    ),
    WarpEndpoint(
      host: '162.159.193.1',
      port: 2408,
      label: 'WARP Alt',
      region: 'Global',
    ),
    WarpEndpoint(
      host: '162.159.195.1',
      port: 2408,
      label: 'WARP Alt 2',
      region: 'Global',
    ),
  ];

  /// Get endpoint string (host:port)
  static List<String> get allEndpointStrings =>
      endpoints.map((e) => '${e.host}:${e.port}').toList();
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
