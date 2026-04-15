import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/server_config.dart';
import '../../data/models/vpn_status.dart';
import '../../providers/navigation_provider.dart';
import '../../providers/server_provider.dart';
import '../../providers/vpn_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/connection_hub.dart';
import '../widgets/server_avatar.dart';
import '../widgets/speed_stats_card.dart';
import '../widgets/server_tile.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedServer = ref.watch(selectedServerProvider);
    final servers = ref.watch(serverListProvider);
    final warpState = ref.watch(warpProvider);
    final vpnState = ref.watch(vpnStateProvider);
    final l = AppLocalizations.of(context);

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
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.screenPadding,
              ),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.xs),
                  if (warpState.status == WarpStatus.registering)
                    _buildWarpBanner(
                      context,
                      l.settingUpTunnel,
                      Icons.hourglass_bottom_rounded,
                      AppColors.warningOrange,
                    ),
                  if (warpState.status == WarpStatus.failed)
                    _buildWarpBanner(
                      context,
                      l.resolve(warpState.error ?? '@warpFailed'),
                      Icons.error_outline_rounded,
                      AppColors.errorRed,
                      onRetry: () => ref.read(warpProvider.notifier).register(),
                    ),
                  const ConnectionHub(),
                  const SizedBox(height: AppSpacing.sm),
                  const ConnectionTimerDisplay(),
                  const SizedBox(height: AppSpacing.lg),
                  const SpeedStatsCard(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildLocationCard(context, ref, selectedServer, vpnState),
                  const SizedBox(height: AppSpacing.xl),
                  if (topServers.length > 1)
                    _buildFastestServers(context, ref, topServers),
                  SizedBox(
                    height: AppSpacing.bottomNavHeight + AppSpacing.lg,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWarpBanner(
    BuildContext context,
    String message,
    IconData icon,
    Color color, {
    VoidCallback? onRetry,
  }) {
    final l = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
              ),
            ),
          ),
          if (onRetry != null)
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  HapticFeedback.mediumImpact();
                  onRetry();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: color.withValues(alpha: 0.15),
                  ),
                  child: Text(
                    l.retry,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(
    BuildContext context,
    WidgetRef ref,
    ServerConfig selectedServer,
    VpnState vpnState,
  ) {
    final isConnected = vpnState.isConnected;
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadiusLarge),
        onTap: () {
          HapticFeedback.selectionClick();
          ref.read(currentTabIndexProvider.notifier).state = 1;
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadiusLarge),
            gradient: isConnected
                ? LinearGradient(
                    colors: [
                      AppColors.neonTurquoise.withValues(alpha: 0.1),
                      AppColors.electricBlue.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  )
                : null,
            color: isConnected ? null : AppColors.cardBg,
            border: Border.all(
              color: isConnected
                  ? AppColors.neonTurquoise.withValues(alpha: 0.3)
                  : AppColors.cardBorder,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    ServerAvatar(server: selectedServer, size: 40),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            selectedServer.country,
                            style: theme.textTheme.titleSmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            l.resolve(selectedServer.city),
                            style: theme.textTheme.bodyMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isConnected)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: AppColors.successGreen.withValues(alpha: 0.15),
                      ),
                      child: Text(
                        l.active,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.successGreen,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(width: AppSpacing.xs),
                  PingBadge(pingMs: selectedServer.estimatedPingMs),
                  const SizedBox(width: AppSpacing.sm),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFastestServers(
    BuildContext context,
    WidgetRef ref,
    List<ServerConfig> servers,
  ) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(l.quickConnect, style: theme.textTheme.titleMedium),
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  ref.read(currentTabIndexProvider.notifier).state = 1;
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  child: Text(
                    l.seeAll,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.neonTurquoise,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: servers.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              final server = servers[index];
              final isSelected =
                  ref.watch(selectedServerProvider).id == server.id;
              return Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      HapticFeedback.selectionClick();
                      ref.read(selectedServerProvider.notifier).state = server;
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 110,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: isSelected
                            ? AppColors.neonTurquoise.withValues(alpha: 0.1)
                            : AppColors.cardBg,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.neonTurquoise.withValues(alpha: 0.4)
                              : AppColors.cardBorder,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ServerAvatar(server: server, size: 28),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            l.resolve(server.city),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${server.estimatedPingMs} ms',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.neonTurquoise.withValues(
                                alpha: 0.8,
                              ),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
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
}
