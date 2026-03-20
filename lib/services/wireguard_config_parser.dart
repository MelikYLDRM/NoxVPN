import '../data/models/server_config.dart';

class WireGuardConfigParser {
  /// Parses a standard WireGuard .conf file content into a ServerConfig.
  /// Example .conf:
  /// ```
  /// [Interface]
  /// PrivateKey = ...
  /// Address = 10.0.0.2/32
  /// DNS = 1.1.1.1, 1.0.0.1
  /// MTU = 1420
  ///
  /// [Peer]
  /// PublicKey = ...
  /// PresharedKey = ...
  /// Endpoint = 1.2.3.4:51820
  /// AllowedIPs = 0.0.0.0/0, ::/0
  /// PersistentKeepalive = 25
  /// ```
  static ParsedWireGuardConfig? parse(String configContent) {
    try {
      final lines = configContent.split('\n');
      String? privateKey;
      String? address;
      String dns = '1.1.1.1,1.0.0.1';
      int mtu = 1420;
      String? publicKey;
      String? presharedKey;
      String? endpoint;
      String allowedIPs = '0.0.0.0/0,::/0';
      int persistentKeepalive = 25;

      String currentSection = '';

      for (final line in lines) {
        final trimmed = line.trim();
        if (trimmed.isEmpty || trimmed.startsWith('#')) continue;

        if (trimmed == '[Interface]') {
          currentSection = 'interface';
          continue;
        } else if (trimmed == '[Peer]') {
          currentSection = 'peer';
          continue;
        }

        final eqIndex = trimmed.indexOf('=');
        if (eqIndex == -1) continue;

        final key = trimmed.substring(0, eqIndex).trim().toLowerCase();
        final value = trimmed.substring(eqIndex + 1).trim();

        if (currentSection == 'interface') {
          switch (key) {
            case 'privatekey':
              privateKey = value;
            case 'address':
              address = value.replaceAll(' ', '');
            case 'dns':
              dns = value.replaceAll(' ', '');
            case 'mtu':
              mtu = int.tryParse(value) ?? 1420;
          }
        } else if (currentSection == 'peer') {
          switch (key) {
            case 'publickey':
              publicKey = value;
            case 'presharedkey':
              presharedKey = value;
            case 'endpoint':
              endpoint = value;
            case 'allowedips':
              allowedIPs = value.replaceAll(' ', '');
            case 'persistentkeepalive':
              persistentKeepalive = int.tryParse(value) ?? 25;
          }
        }
      }

      if (privateKey == null ||
          publicKey == null ||
          endpoint == null ||
          address == null) {
        return null;
      }

      return ParsedWireGuardConfig(
        privateKey: privateKey,
        address: address,
        dns: dns,
        mtu: mtu,
        publicKey: publicKey,
        presharedKey: presharedKey,
        endpoint: endpoint,
        allowedIPs: allowedIPs,
        persistentKeepalive: persistentKeepalive,
      );
    } catch (_) {
      return null;
    }
  }

  /// Converts a parsed config into a ServerConfig with a display name.
  static ServerConfig toServerConfig(
    ParsedWireGuardConfig parsed, {
    required String name,
    String country = 'Imported',
    String countryCode = 'xx',
  }) {
    return ServerConfig(
      id: 'imported-${DateTime.now().millisecondsSinceEpoch}',
      country: country,
      city: name,
      countryCode: countryCode,
      serverPublicKey: parsed.publicKey,
      endpoint: parsed.endpoint,
      presharedKey: parsed.presharedKey,
      allowedIPs: parsed.allowedIPs.split(','),
      persistentKeepalive: parsed.persistentKeepalive,
      clientPrivateKey: parsed.privateKey,
      clientAddress: parsed.address,
      dnsServers: parsed.dns.split(','),
      mtu: parsed.mtu,
      estimatedPingMs: 0,
    );
  }
}

class ParsedWireGuardConfig {
  final String privateKey;
  final String address;
  final String dns;
  final int mtu;
  final String publicKey;
  final String? presharedKey;
  final String endpoint;
  final String allowedIPs;
  final int persistentKeepalive;

  const ParsedWireGuardConfig({
    required this.privateKey,
    required this.address,
    required this.dns,
    required this.mtu,
    required this.publicKey,
    this.presharedKey,
    required this.endpoint,
    required this.allowedIPs,
    required this.persistentKeepalive,
  });
}
