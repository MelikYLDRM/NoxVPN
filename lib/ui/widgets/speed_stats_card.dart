import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/format_utils.dart';
import '../../providers/vpn_provider.dart';

class SpeedStatsCard extends ConsumerWidget {
  const SpeedStatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final vpnState = ref.watch(vpnStateProvider);
    if (!vpnState.isConnected) return const SizedBox.shrink();

    final statsAsync = ref.watch(connectionStatsProvider);

    return statsAsync.when(
      data: (stats) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xxl,
          vertical: 18,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.cardRadiusLarge),
          gradient: LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.08),
              Colors.white.withValues(alpha: 0.04),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(
                  context,
                  icon: Icons.arrow_downward_rounded,
                  label: l.download,
                  value: FormatUtils.formatSpeed(stats.downloadSpeedBps),
                  color: AppColors.neonTurquoise,
                ),
                Container(
                  width: 1,
                  height: 45,
                  color: AppColors.divider,
                ),
                _buildStatColumn(
                  context,
                  icon: Icons.arrow_upward_rounded,
                  label: l.upload,
                  value: FormatUtils.formatSpeed(stats.uploadSpeedBps),
                  color: AppColors.electricBlue,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Divider(color: AppColors.divider, height: 1),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildDataColumn(
                  context,
                  label: l.totalDown,
                  value: FormatUtils.formatBytes(stats.downloadBytes),
                ),
                _buildDataColumn(
                  context,
                  label: l.totalUp,
                  value: FormatUtils.formatBytes(stats.uploadBytes),
                ),
              ],
            ),
          ],
        ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatColumn(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.15),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(fontSize: 17),
        ),
        const SizedBox(height: 2),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(fontSize: 11)),
      ],
    );
  }

  Widget _buildDataColumn(
    BuildContext context, {
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.labelMedium?.copyWith(fontSize: 13),
        ),
        const SizedBox(height: 2),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(fontSize: 10)),
      ],
    );
  }
}

class ConnectionTimerDisplay extends ConsumerStatefulWidget {
  const ConnectionTimerDisplay({super.key});

  @override
  ConsumerState<ConnectionTimerDisplay> createState() =>
      _ConnectionTimerDisplayState();
}

class _ConnectionTimerDisplayState
    extends ConsumerState<ConnectionTimerDisplay> {
  Timer? _timer;
  Duration _elapsed = Duration.zero;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer(DateTime since) {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _elapsed = DateTime.now().difference(since);
        });
      }
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _elapsed = Duration.zero;
  }

  @override
  Widget build(BuildContext context) {
    final vpnState = ref.watch(vpnStateProvider);

    if (vpnState.isConnected && vpnState.connectedSince != null) {
      if (_timer == null || !_timer!.isActive) {
        _startTimer(vpnState.connectedSince!);
      }
    } else {
      _stopTimer();
    }

    if (!vpnState.isConnected) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppColors.neonTurquoise.withValues(alpha: 0.1),
      ),
      child: Text(
        FormatUtils.formatDuration(_elapsed),
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: AppColors.neonTurquoise,
          letterSpacing: 3,
        ),
      ),
    );
  }
}
