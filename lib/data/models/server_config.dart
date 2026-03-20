class ServerConfig {
  final String id;
  final String country;
  final String city;
  final String countryCode;
  final String serverPublicKey;
  final String endpoint;
  final String? presharedKey;
  final List<String> allowedIPs;
  final int persistentKeepalive;
  final String? clientPrivateKey;
  final String clientAddress;
  final List<String> dnsServers;
  final int mtu;
  final int estimatedPingMs;

  const ServerConfig({
    required this.id,
    required this.country,
    required this.city,
    required this.countryCode,
    required this.serverPublicKey,
    required this.endpoint,
    this.presharedKey,
    this.allowedIPs = const ['0.0.0.0/0', '::/0'],
    this.persistentKeepalive = 25,
    this.clientPrivateKey,
    required this.clientAddress,
    this.dnsServers = const ['1.1.1.1', '1.0.0.1'],
    this.mtu = 1420,
    this.estimatedPingMs = 50,
  });

  String get flagUrl => 'https://flagcdn.com/w320/$countryCode.png';

  bool get hasPrivateKey => clientPrivateKey != null && clientPrivateKey!.isNotEmpty;

  ServerConfig copyWith({
    String? id,
    String? country,
    String? city,
    String? countryCode,
    String? serverPublicKey,
    String? endpoint,
    String? presharedKey,
    List<String>? allowedIPs,
    int? persistentKeepalive,
    String? clientPrivateKey,
    String? clientAddress,
    List<String>? dnsServers,
    int? mtu,
    int? estimatedPingMs,
  }) {
    return ServerConfig(
      id: id ?? this.id,
      country: country ?? this.country,
      city: city ?? this.city,
      countryCode: countryCode ?? this.countryCode,
      serverPublicKey: serverPublicKey ?? this.serverPublicKey,
      endpoint: endpoint ?? this.endpoint,
      presharedKey: presharedKey ?? this.presharedKey,
      allowedIPs: allowedIPs ?? this.allowedIPs,
      persistentKeepalive: persistentKeepalive ?? this.persistentKeepalive,
      clientPrivateKey: clientPrivateKey ?? this.clientPrivateKey,
      clientAddress: clientAddress ?? this.clientAddress,
      dnsServers: dnsServers ?? this.dnsServers,
      mtu: mtu ?? this.mtu,
      estimatedPingMs: estimatedPingMs ?? this.estimatedPingMs,
    );
  }
}
