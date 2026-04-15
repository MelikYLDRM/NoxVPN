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

  bool get hasPrivateKey =>
      clientPrivateKey != null && clientPrivateKey!.isNotEmpty;

  bool get isWarp => countryCode == 'warp';

  Map<String, dynamic> toJson() => {
    'id': id,
    'country': country,
    'city': city,
    'countryCode': countryCode,
    'serverPublicKey': serverPublicKey,
    'endpoint': endpoint,
    'presharedKey': presharedKey,
    'allowedIPs': allowedIPs,
    'persistentKeepalive': persistentKeepalive,
    'clientPrivateKey': clientPrivateKey,
    'clientAddress': clientAddress,
    'dnsServers': dnsServers,
    'mtu': mtu,
    'estimatedPingMs': estimatedPingMs,
  };

  factory ServerConfig.fromJson(Map<String, dynamic> map) {
    return ServerConfig(
      id: map['id'] as String,
      country: map['country'] as String,
      city: map['city'] as String,
      countryCode: map['countryCode'] as String,
      serverPublicKey: map['serverPublicKey'] as String,
      endpoint: map['endpoint'] as String,
      presharedKey: map['presharedKey'] as String?,
      allowedIPs: (map['allowedIPs'] as List<dynamic>).cast<String>(),
      persistentKeepalive: map['persistentKeepalive'] as int,
      clientPrivateKey: map['clientPrivateKey'] as String?,
      clientAddress: map['clientAddress'] as String,
      dnsServers: (map['dnsServers'] as List<dynamic>).cast<String>(),
      mtu: map['mtu'] as int,
      estimatedPingMs: map['estimatedPingMs'] as int,
    );
  }

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
