import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/server_provider.dart';
import '../widgets/server_tile.dart';

class ServerListScreen extends ConsumerStatefulWidget {
  const ServerListScreen({super.key});

  @override
  ConsumerState<ServerListScreen> createState() => _ServerListScreenState();
}

class _ServerListScreenState extends ConsumerState<ServerListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String val) {
    setState(() => _searchQuery = val);
  }

  @override
  Widget build(BuildContext context) {
    final allServers = ref.watch(serverListProvider);
    final selectedServer = ref.watch(selectedServerProvider);
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);

    final filteredServers = _searchQuery.isEmpty
        ? allServers
        : allServers.where((s) {
            final q = _searchQuery.toLowerCase();
            return s.city.toLowerCase().contains(q) ||
                s.country.toLowerCase().contains(q);
          }).toList();

    final grouped = <String, List<dynamic>>{};
    for (final s in filteredServers) {
      grouped.putIfAbsent(s.country, () => []).add(s);
    }

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
              vertical: AppSpacing.lg,
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.public_rounded,
                  color: AppColors.neonTurquoise,
                  size: 28,
                ),
                const SizedBox(width: AppSpacing.md),
                Text(l.navServers, style: theme.textTheme.titleLarge),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.neonTurquoise.withValues(alpha: 0.1),
                  ),
                  child: Text(
                    '${allServers.length}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.neonTurquoise,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenPadding,
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
                color: AppColors.cardBg,
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: theme.textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: l.searchServers,
                  hintStyle: theme.textTheme.bodyMedium,
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: AppColors.textSecondary,
                            size: 18,
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _onSearchChanged('');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (filteredServers.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      color: AppColors.textSecondary,
                      size: 48,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      l.noServersFound,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.screenPadding,
                ),
                children: [
                  ...grouped.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            top: AppSpacing.lg,
                            bottom: AppSpacing.sm,
                          ),
                          child: Text(
                            entry.key.toUpperCase(),
                            style: theme.textTheme.labelSmall,
                          ),
                        ),
                        ...entry.value.map((server) {
                          final isImported =
                              server.id != 'warp-auto' &&
                              server.id != 'warp-loading';
                          return Dismissible(
                            key: Key(server.id),
                            direction: isImported
                                ? DismissDirection.endToStart
                                : DismissDirection.none,
                            confirmDismiss: (_) async {
                              HapticFeedback.mediumImpact();
                              return await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text(l.removeServer),
                                  content: Text(
                                    l.removeServerConfirm(server.city),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, false),
                                      child: Text(
                                        l.cancel,
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(ctx, true),
                                      child: Text(
                                        l.remove,
                                        style: const TextStyle(
                                          color: AppColors.errorRed,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            onDismissed: (_) {
                              ref
                                  .read(importedServersProvider.notifier)
                                  .removeServer(server.id);
                            },
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(
                                right: AppSpacing.xl,
                              ),
                              margin: const EdgeInsets.only(
                                bottom: AppSpacing.sm,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.cardRadius,
                                ),
                                color: AppColors.errorRed.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                              child: const Icon(
                                Icons.delete_outline,
                                color: AppColors.errorRed,
                              ),
                            ),
                            child: ServerTile(
                              server: server,
                              isSelected: selectedServer.id == server.id,
                              onTap: () {
                                HapticFeedback.selectionClick();
                                ref
                                    .read(selectedServerProvider.notifier)
                                    .state = server;
                                ref
                                    .read(currentTabIndexProvider.notifier)
                                    .state = 0;
                              },
                            ),
                          );
                        }),
                      ],
                    );
                  }),
                  SizedBox(
                    height: AppSpacing.bottomNavHeight + AppSpacing.lg,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
