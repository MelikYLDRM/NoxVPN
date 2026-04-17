import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models/server_config.dart';
import '../services/ping_service.dart';
import '../services/vpn_engine.dart';
import '../services/warp_service.dart';
import 'vpn_provider.dart';

// ---------- WARP Registration ----------

enum WarpStatus { idle, registering, registered, failed }

class WarpState {
  final WarpStatus status;
  final List<ServerConfig> servers;
  final String? error;

  const WarpState({
    this.status = WarpStatus.idle,
    this.servers = const [],
    this.error,
  });

  /// Legacy accessor for backward compatibility
  ServerConfig? get server => servers.isNotEmpty ? servers.first : null;

  WarpState copyWith({
    WarpStatus? status,
    List<ServerConfig>? servers,
    String? error,
  }) {
    return WarpState(
      status: status ?? this.status,
      servers: servers ?? this.servers,
      error: error,
    );
  }
}

class WarpNotifier extends StateNotifier<WarpState> {
  final VpnEngine _engine;

  WarpNotifier(this._engine) : super(const WarpState()) {
    _init();
  }

  Future<void> _init() async {
    final existing = await WarpService.loadRegistration();
    if (existing != null) {
      if (existing.endpoint.endsWith(':0') ||
          !existing.endpoint.contains(':')) {
        await WarpService.clearRegistration();
        await register();
        return;
      }

      // Generate multiple server configs immediately (no ping wait)
      final servers = WarpService.toMultipleServerConfigs(existing);
      if (servers.isNotEmpty) {
        state = WarpState(status: WarpStatus.registered, servers: servers);
        // Measure pings in background
        refreshPings();
        return;
      }

      // Fallback: single server
      final server = WarpService.toServerConfig(existing);
      state = WarpState(
        status: WarpStatus.registered,
        servers: [server],
      );
      refreshPings();
      return;
    }
    await register();
  }

  Future<void> register() async {
    state = state.copyWith(status: WarpStatus.registering, error: null);

    final reg = await WarpService.register(
      generateKeyPair: () => _engine.generateKeyPair(),
    );

    if (reg != null) {
      final servers = WarpService.toMultipleServerConfigs(reg);
      if (servers.isNotEmpty) {
        state = WarpState(status: WarpStatus.registered, servers: servers);
      } else {
        final server = WarpService.toServerConfig(reg);
        state = WarpState(
          status: WarpStatus.registered,
          servers: [server],
        );
      }
      // Measure pings in background after showing servers immediately
      refreshPings();
    } else {
      state = const WarpState(status: WarpStatus.failed, error: '@warpFailed');
    }
  }

  /// Refresh ping for all WARP endpoints
  Future<void> refreshPings() async {
    if (state.servers.isEmpty) return;

    final updated = await Future.wait(
      state.servers.map((server) async {
        final ping = await PingService.ping(server.endpoint);
        return ping > 0 ? server.copyWith(estimatedPingMs: ping) : server;
      }),
    );

    if (mounted) {
      updated.sort((a, b) => a.estimatedPingMs.compareTo(b.estimatedPingMs));
      state = state.copyWith(servers: updated);
    }
  }
}

final warpProvider = StateNotifierProvider<WarpNotifier, WarpState>((ref) {
  final engine = ref.watch(vpnEngineProvider);
  return WarpNotifier(engine);
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
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getStringList('imported_servers');
      if (json == null) return;
      state = json.map((s) {
        final map = jsonDecode(s) as Map<String, dynamic>;
        return ServerConfig.fromJson(map);
      }).toList();

      _measurePings();
    } catch (_) {
      // Gracefully handle corrupt data
    }
  }

  Future<void> _measurePings() async {
    if (state.isEmpty) return;

    // Parallel ping measurement
    final futures = state.map((server) async {
      final ping = await PingService.ping(server.endpoint);
      return ping > 0 ? server.copyWith(estimatedPingMs: ping) : server;
    });

    final updated = await Future.wait(futures);
    if (mounted) {
      state = updated;
    }
  }

  Future<void> refreshPings() async {
    await _measurePings();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final json = state.map((s) => jsonEncode(s.toJson())).toList();
    await prefs.setStringList('imported_servers', json);
  }

  Future<void> addServer(ServerConfig server) async {
    final ping = await PingService.ping(server.endpoint);
    final updated = ping > 0 ? server.copyWith(estimatedPingMs: ping) : server;
    state = [...state, updated];
    await _save();
  }

  Future<void> removeServer(String id) async {
    state = state.where((s) => s.id != id).toList();
    await _save();
  }
}

// ---------- Favorites ----------

final favoriteServersProvider =
    StateNotifierProvider<FavoriteServersNotifier, Set<String>>((ref) {
      return FavoriteServersNotifier();
    });

class FavoriteServersNotifier extends StateNotifier<Set<String>> {
  FavoriteServersNotifier() : super({}) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList('favorite_servers');
    if (favs != null) {
      state = favs.toSet();
    }
  }

  Future<void> toggle(String serverId) async {
    final updated = Set<String>.from(state);
    if (updated.contains(serverId)) {
      updated.remove(serverId);
    } else {
      updated.add(serverId);
    }
    state = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favorite_servers', updated.toList());
  }

  bool isFavorite(String serverId) => state.contains(serverId);
}

// ---------- Combined Server List ----------

final serverListProvider = Provider<List<ServerConfig>>((ref) {
  final warp = ref.watch(warpProvider);
  final imported = ref.watch(importedServersProvider);
  final favorites = ref.watch(favoriteServersProvider);

  final servers = <ServerConfig>[];

  if (warp.servers.isNotEmpty) {
    servers.addAll(warp.servers);
  } else {
    String statusKey;
    switch (warp.status) {
      case WarpStatus.idle:
      case WarpStatus.registering:
        statusKey = '@warpRegistering';
      case WarpStatus.failed:
        statusKey = '@warpTapToRetry';
      case WarpStatus.registered:
        statusKey = '@warpAuto';
    }
    servers.add(
      ServerConfig(
        id: 'warp-loading',
        country: 'Cloudflare',
        city: statusKey,
        countryCode: 'warp',
        serverPublicKey: '',
        endpoint: '',
        clientAddress: '',
        estimatedPingMs: 0,
      ),
    );
  }

  servers.addAll(imported);

  // Sort: favorites first, then by ping
  servers.sort((a, b) {
    final aFav = favorites.contains(a.id) ? 0 : 1;
    final bFav = favorites.contains(b.id) ? 0 : 1;
    if (aFav != bFav) return aFav.compareTo(bFav);
    return a.estimatedPingMs.compareTo(b.estimatedPingMs);
  });

  return servers;
});

final selectedServerProvider = StateProvider<ServerConfig>((ref) {
  final servers = ref.watch(serverListProvider);
  return servers.first;
});

/// Best server by lowest ping
final bestServerProvider = Provider<ServerConfig?>((ref) {
  final servers = ref.watch(serverListProvider);
  if (servers.isEmpty) return null;

  final valid = servers
      .where((s) => s.serverPublicKey.isNotEmpty && s.estimatedPingMs > 0)
      .toList();

  if (valid.isEmpty) return servers.first;

  valid.sort((a, b) => a.estimatedPingMs.compareTo(b.estimatedPingMs));
  return valid.first;
});

final groupedServersProvider = Provider<Map<String, List<ServerConfig>>>((ref) {
  final servers = ref.watch(serverListProvider);
  final grouped = <String, List<ServerConfig>>{};
  for (final s in servers) {
    grouped.putIfAbsent(s.country, () => []).add(s);
  }
  return grouped;
});

// ---------- Periodic Ping Refresh ----------

final pingRefreshProvider = Provider<void>((ref) {
  Timer? timer;

  timer = Timer.periodic(const Duration(minutes: 5), (_) {
    ref.read(warpProvider.notifier).refreshPings();
    ref.read(importedServersProvider.notifier).refreshPings();
  });

  ref.onDispose(() {
    timer?.cancel();
  });
});
