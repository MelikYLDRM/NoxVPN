import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/server_provider.dart';
import '../widgets/server_tile.dart';

class ServerListScreen extends ConsumerWidget {
  const ServerListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupedServers = ref.watch(groupedServersProvider);
    final selectedServer = ref.watch(selectedServerProvider);

    return SafeArea(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                const Icon(
                  Icons.public,
                  color: AppColors.neonTurquoise,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Servers',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${ref.watch(serverListProvider).length} locations',
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
              ],
            ),
          ),

          // Server list
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: groupedServers.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 16, bottom: 10),
                      child: Text(
                        entry.key,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                    ...entry.value.map((server) {
                      return ServerTile(
                        server: server,
                        isSelected: selectedServer.id == server.id,
                        onTap: () {
                          ref.read(selectedServerProvider.notifier).state =
                              server;
                          // Switch back to home tab
                          ref.read(currentTabIndexProvider.notifier).state = 0;
                        },
                      );
                    }),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 90),
        ],
      ),
    );
  }
}
