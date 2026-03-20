import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/server_config.dart';
import '../services/warp_service.dart';
import '../services/wireguard_platform_channel.dart';

// ---------- WARP Registration ----------

enum WarpStatus { idle, registering, registered, failed }

class WarpState {
  final WarpStatus status;
  final ServerConfig? server;
  final String? error;

  const WarpState({
    this.status = WarpStatus.idle,
    this.server,
    this.error,
  });

  WarpState copyWith({WarpStatus? status, ServerConfig? server, String? error}) {
    return WarpState(
      status: status ?? this.status,
      server: server ?? this.server,
      error: error,
    );
  }
}

class WarpNotifier extends StateNotifier<WarpState> {
  WarpNotifier() : super(const WarpState()) {
    _init();
  }

  Future<void> _init() async {
    // Check if already registered
    final existing = await WarpService.loadRegistration();
    if (existing != null) {
      // Validate the cached registration - check for bad endpoint port
      if (existing.endpoint.endsWith(':0') || !existing.endpoint.contains(':')) {
        // Bad cached data, clear and re-register
        await WarpService.clearRegistration();
        await register();
        return;
      }
      state = WarpState(
        status: WarpStatus.registered,
        server: WarpService.toServerConfig(existing),
      );
      return;
    }
    // Auto-register
    await register();
  }

  Future<void> register() async {
    state = state.copyWith(status: WarpStatus.registering, error: null);

    final reg = await WarpService.register(
      generateKeyPair: () => WireGuardPlatformChannel().generateKeyPair(),
    );

    if (reg != null) {
      state = WarpState(
        status: WarpStatus.registered,
        server: WarpService.toServerConfig(reg),
      );
    } else {
      state = const WarpState(
        status: WarpStatus.failed,
        error: 'WARP registration failed. Check internet connection.',
      );
    }
  }
}

final warpProvider = StateNotifierProvider<WarpNotifier, WarpState>((ref) {
  return WarpNotifier();
});

// ---------- Imported Servers ----------

final importedServersProvider =
    StateNotifierProvider<ImportedServersNotifier, List<ServerConfig>>((ref) {
  return ImportedServersNotifier();
});

class ImportedServersNotifier extends StateNotifier<List<ServerConfig>> {
  ImportedServersNotifier() : super([]) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getStringList('imported_servers');
    if (json == null) return;
    state = json.map((s) {
      final map = jsonDecode(s) as Map<String, dynamic>;
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
    }).toList();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final json = state.map((s) {
      return jsonEncode({
        'id': s.id,
        'country': s.country,
        'city': s.city,
        'countryCode': s.countryCode,
        'serverPublicKey': s.serverPublicKey,
        'endpoint': s.endpoint,
        'presharedKey': s.presharedKey,
        'allowedIPs': s.allowedIPs,
        'persistentKeepalive': s.persistentKeepalive,
        'clientPrivateKey': s.clientPrivateKey,
        'clientAddress': s.clientAddress,
        'dnsServers': s.dnsServers,
        'mtu': s.mtu,
        'estimatedPingMs': s.estimatedPingMs,
      });
    }).toList();
    await prefs.setStringList('imported_servers', json);
  }

  Future<void> addServer(ServerConfig server) async {
    state = [...state, server];
    await _save();
  }

  Future<void> removeServer(String id) async {
    state = state.where((s) => s.id != id).toList();
    await _save();
  }
}

// ---------- Combined Server List ----------

final serverListProvider = Provider<List<ServerConfig>>((ref) {
  final warp = ref.watch(warpProvider);
  final imported = ref.watch(importedServersProvider);

  final servers = <ServerConfig>[];

  // WARP server at top
  if (warp.server != null) {
    servers.add(warp.server!);
  } else {
    // Show placeholder while WARP is loading/registering
    String statusText;
    switch (warp.status) {
      case WarpStatus.idle:
      case WarpStatus.registering:
        statusText = 'WARP (Registering...)';
      case WarpStatus.failed:
        statusText = 'WARP (Tap to Retry)';
      case WarpStatus.registered:
        statusText = 'WARP (Auto)';
    }
    servers.add(ServerConfig(
      id: 'warp-loading',
      country: 'Cloudflare',
      city: statusText,
      countryCode: 'warp',
      serverPublicKey: '',
      endpoint: '',
      clientAddress: '',
      estimatedPingMs: 0,
    ));
  }

  // Imported servers next
  servers.addAll(imported);

  return servers;
});

final selectedServerProvider = StateProvider<ServerConfig>((ref) {
  final servers = ref.watch(serverListProvider);
  return servers.first;
});

final groupedServersProvider =
    Provider<Map<String, List<ServerConfig>>>((ref) {
  final servers = ref.watch(serverListProvider);
  final grouped = <String, List<ServerConfig>>{};
  for (final s in servers) {
    grouped.putIfAbsent(s.country, () => []).add(s);
  }
  return grouped;
});
