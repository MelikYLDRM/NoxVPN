import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../data/datasources/warp_endpoints.dart';
import '../data/models/server_config.dart';

/// Cloudflare WARP registration response model
class WarpRegistration {
  final String id;
  final String token;
  final String clientPrivateKey;
  final String clientPublicKey;
  final String serverPublicKey;
  final String clientIpv4;
  final String clientIpv6;
  final String endpoint;

  const WarpRegistration({
    required this.id,
    required this.token,
    required this.clientPrivateKey,
    required this.clientPublicKey,
    required this.serverPublicKey,
    required this.clientIpv4,
    required this.clientIpv6,
    required this.endpoint,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'token': token,
    'clientPrivateKey': clientPrivateKey,
    'clientPublicKey': clientPublicKey,
    'serverPublicKey': serverPublicKey,
    'clientIpv4': clientIpv4,
    'clientIpv6': clientIpv6,
    'endpoint': endpoint,
  };

  factory WarpRegistration.fromJson(Map<String, dynamic> json) =>
      WarpRegistration(
        id: json['id'] as String,
        token: json['token'] as String,
        clientPrivateKey: json['clientPrivateKey'] as String,
        clientPublicKey: json['clientPublicKey'] as String,
        serverPublicKey: json['serverPublicKey'] as String,
        clientIpv4: json['clientIpv4'] as String,
        clientIpv6: json['clientIpv6'] as String,
        endpoint: json['endpoint'] as String,
      );
}

class WarpService {
  static const _apiBase = 'https://api.cloudflareclient.com/v0a2158';
  static const _prefsKey = 'warp_registration';

  /// Load existing WARP registration from storage
  static Future<WarpRegistration?> loadRegistration() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_prefsKey);
    if (json == null) return null;
    try {
      return WarpRegistration.fromJson(
        jsonDecode(json) as Map<String, dynamic>,
      );
    } catch (e) {
      return null;
    }
  }

  /// Save WARP registration to storage
  static Future<void> _saveRegistration(WarpRegistration reg) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(reg.toJson()));
  }

  /// Register with Cloudflare WARP and get WireGuard config.
  /// [generateKeyPair] should be a function that generates a WireGuard key pair
  /// using the native platform channel.
  static Future<WarpRegistration?> register({
    required Future<Map<String, String>> Function() generateKeyPair,
  }) async {
    try {
      // Check if already registered
      final existing = await loadRegistration();
      if (existing != null) {
        return existing;
      }

      // Generate WireGuard key pair via native platform
      final keyPair = await generateKeyPair();
      final privateKey = keyPair['privateKey']!;
      final publicKey = keyPair['publicKey']!;

      // Register with WARP API
      final response = await http.post(
        Uri.parse('$_apiBase/reg'),
        headers: {
          'Content-Type': 'application/json',
          'CF-Client-Version': 'a-6.11-2223',
        },
        body: jsonEncode({
          'key': publicKey,
          'tos': DateTime.now().toUtc().toIso8601String(),
          'model': 'Android',
          'type': 'Android',
          'locale': 'en_US',
        }),
      );

      if (response.statusCode != 200) {
        return null;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      // Extract config from response
      final config = data['config'] as Map<String, dynamic>?;
      if (config == null) return null;

      final iface = config['interface'] as Map<String, dynamic>?;
      final addresses = iface?['addresses'] as Map<String, dynamic>?;
      final peers = config['peers'] as List<dynamic>?;

      if (addresses == null || peers == null || peers.isEmpty) return null;

      final peer = peers[0] as Map<String, dynamic>;
      final peerPublicKey = peer['public_key'] as String?;
      final peerEndpoint = peer['endpoint'] as Map<String, dynamic>?;

      if (peerPublicKey == null || peerEndpoint == null) {
        return null;
      }

      // Build endpoint string - prefer v4
      final endpointHost =
          peerEndpoint['v4'] as String? ??
          peerEndpoint['host'] as String? ??
          '';

      // Cloudflare WARP uses port 2408
      // The API may return IP:0 or just IP - always force port 2408
      String cleanHost = endpointHost;
      if (cleanHost.contains(':')) {
        cleanHost = cleanHost.split(':').first;
      }
      final fullEndpoint = '$cleanHost:2408';

      // Ensure client IPv4 has CIDR notation
      String clientIpv4 = addresses['v4'] as String? ?? '172.16.0.2/32';
      if (!clientIpv4.contains('/')) {
        clientIpv4 = '$clientIpv4/32';
      }

      final reg = WarpRegistration(
        id: data['id'] as String? ?? '',
        token: data['token'] as String? ?? '',
        clientPrivateKey: privateKey,
        clientPublicKey: publicKey,
        serverPublicKey: peerPublicKey,
        clientIpv4: clientIpv4,
        clientIpv6: addresses['v6'] as String? ?? '',
        endpoint: fullEndpoint,
      );

      await _saveRegistration(reg);
      return reg;
    } catch (e, _) {
      return null;
    }
  }

  /// Convert WARP registration to a ServerConfig for a specific endpoint
  static ServerConfig toServerConfig(
    WarpRegistration reg, {
    String? overrideEndpoint,
    String? label,
    String? region,
  }) {
    final endpoint = overrideEndpoint ?? reg.endpoint;
    final city = label ?? 'WARP (Auto)';
    final id = overrideEndpoint != null
        ? 'warp-${overrideEndpoint.replaceAll(':', '-').replaceAll('.', '_')}'
        : 'warp-auto';

    return ServerConfig(
      id: id,
      country: region ?? 'Cloudflare',
      city: city,
      countryCode: 'warp',
      serverPublicKey: reg.serverPublicKey,
      endpoint: endpoint,
      clientPrivateKey: reg.clientPrivateKey,
      clientAddress: reg.clientIpv4,
      allowedIPs: const ['0.0.0.0/0', '::/0'],
      dnsServers: const ['1.1.1.1', '1.0.0.1'],
      mtu: 1400,
      persistentKeepalive: 15,
      estimatedPingMs: 15,
    );
  }

  /// Generate multiple ServerConfig entries from a single registration
  /// by using different WARP endpoints. Returns immediately with estimated pings.
  /// Actual pings should be measured later via refreshPings().
  static List<ServerConfig> toMultipleServerConfigs(
    WarpRegistration reg,
  ) {
    return WarpEndpoints.endpoints.map((warpEndpoint) {
      return ServerConfig(
        id: 'warp-${warpEndpoint.host.replaceAll('.', '_')}',
        country: 'Cloudflare',
        city: '${warpEndpoint.label} (${warpEndpoint.region})',
        countryCode: 'warp',
        serverPublicKey: reg.serverPublicKey,
        endpoint: warpEndpoint.endpointString,
        clientPrivateKey: reg.clientPrivateKey,
        clientAddress: reg.clientIpv4,
        allowedIPs: const ['0.0.0.0/0', '::/0'],
        dnsServers: const ['1.1.1.1', '1.0.0.1'],
        mtu: 1400,
        persistentKeepalive: 15,
        estimatedPingMs: 50,
      );
    }).toList();
  }

  /// Clear stored WARP registration
  static Future<void> clearRegistration() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }
}
