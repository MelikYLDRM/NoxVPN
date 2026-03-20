import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/server_config.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/server_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/connection_hub.dart';
import '../widgets/glass_card.dart';
import '../widgets/speed_stats_card.dart';
import '../widgets/server_tile.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedServer = ref.watch(selectedServerProvider);
    final servers = ref.watch(serverListProvider);
    final warpState = ref.watch(warpProvider);

    // Sort servers by ping for "Fastest Servers"
    final fastestServers = [...servers]
      ..sort((a, b) => a.estimatedPingMs.compareTo(b.estimatedPingMs));
    final topServers = fastestServers.take(5).toList();

    return Column(
      children: [
        const CustomAppBar(),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 5),
                  // WARP status banner
                  if (warpState.status == WarpStatus.registering)
                    _buildWarpBanner(
                      'Setting up Cloudflare WARP...',
                      Icons.hourglass_bottom,
                      Colors.orangeAccent,
                    ),
                  if (warpState.status == WarpStatus.failed)
                    _buildWarpBanner(
                      warpState.error ?? 'WARP registration failed',
                      Icons.error_outline,
                      Colors.redAccent,
                      onRetry: () =>
                          ref.read(warpProvider.notifier).register(),
                    ),
                  const ConnectionHub(),
                  const SizedBox(height: 10),
                  const ConnectionTimerDisplay(),
                  const SizedBox(height: 15),
                  const SpeedStatsCard(),
                  const SizedBox(height: 15),
                  _buildLocationCard(ref, selectedServer),
                  const SizedBox(height: 20),
                  _buildFastestServers(ref, topServers),
                  const SizedBox(height: 90),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWarpBanner(
    String message,
    IconData icon,
    Color color, {
    VoidCallback? onRetry,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontSize: 13),
            ),
          ),
          if (onRetry != null)
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: color.withValues(alpha: 0.2),
                ),
                child: Text(
                  'Retry',
                  style: TextStyle(
                      color: color, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(WidgetRef ref, ServerConfig selectedServer) {
    return GestureDetector(
      onTap: () {
        ref.read(currentTabIndexProvider.notifier).state = 1;
      },
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _buildServerAvatar(selectedServer, 40),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedServer.country,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      selectedServer.city,
                      style: TextStyle(color: Colors.grey[400], fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                const Icon(
                  Icons.wifi,
                  color: AppColors.neonTurquoise,
                  size: 20,
                ),
                const SizedBox(width: 5),
                PingBadge(pingMs: selectedServer.estimatedPingMs),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right, color: Colors.grey[600], size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFastestServers(WidgetRef ref, List<ServerConfig> servers) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fastest Servers',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: servers.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final server = servers[index];
              return GestureDetector(
                onTap: () {
                  ref.read(selectedServerProvider.notifier).state = server;
                },
                child: Container(
                  width: 130,
                  margin: const EdgeInsets.only(right: 15),
                  child: GlassCard(
                    padding: const EdgeInsets.all(15),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildServerAvatar(server, 30),
                        const SizedBox(height: 10),
                        Text(
                          server.city,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${server.estimatedPingMs} ms',
                          style: TextStyle(
                            color: AppColors.neonTurquoise.withValues(alpha: 0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildServerAvatar(ServerConfig server, double size) {
    if (server.countryCode == 'warp') {
      return Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [Color(0xFFF48120), Color(0xFFF6821F)],
          ),
        ),
        child: Icon(Icons.cloud, color: Colors.white, size: size * 0.55),
      );
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.blue.withValues(alpha: 0.2),
        image: DecorationImage(
          image: NetworkImage(server.flagUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
