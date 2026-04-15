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
  final ServerConfig? server;
  final String? error;

  const WarpState({this.status = WarpStatus.idle, this.server, this.error});

  WarpState copyWith({
    WarpStatus? status,
    ServerConfig? server,
    String? error,
  }) {
    return WarpState(
      status: status ?? this.status,
      server: server ?? this.server,
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
      final server = WarpService.toServerConfig(existing);
      final ping = await PingService.ping(server.endpoint);
      state = WarpState(
        status: WarpStatus.registered,
        server: ping > 0 ? server.copyWith(estimatedPingMs: ping) : server,
      );
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
      final server = WarpService.toServerConfig(reg);
      final ping = await PingService.ping(server.endpoint);
      state = WarpState(
        status: WarpStatus.registered,
        server: ping > 0 ? server.copyWith(estimatedPingMs: ping) : server,
      );
    } else {
      state = const WarpState(
        status: WarpStatus.failed,
        error: '@warpFailed',
      );
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
      state =
          json.map((s) {
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

// ---------- Combined Server List ----------

final serverListProvider = Provider<List<ServerConfig>>((ref) {
  final warp = ref.watch(warpProvider);
  final imported = ref.watch(importedServersProvider);

  final servers = <ServerConfig>[];

  if (warp.server != null) {
    servers.add(warp.server!);
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

  return servers;
});

final selectedServerProvider = StateProvider<ServerConfig>((ref) {
  final servers = ref.watch(serverListProvider);
  return servers.first;
});

final groupedServersProvider = Provider<Map<String, List<ServerConfig>>>((ref) {
  final servers = ref.watch(serverListProvider);
  final grouped = <String, List<ServerConfig>>{};
  for (final s in servers) {
    grouped.putIfAbsent(s.country, () => []).add(s);
  }
  return grouped;
});
