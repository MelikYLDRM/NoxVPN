import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/format_utils.dart';
import '../../providers/vpn_provider.dart';

class SpeedStatsCard extends ConsumerWidget {
  const SpeedStatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vpnState = ref.watch(vpnStateProvider);
    if (!vpnState.isConnected) return const SizedBox.shrink();

    final statsAsync = ref.watch(connectionStatsProvider);

    return statsAsync.when(
      data: (stats) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withValues(alpha: 0.07),
          border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatColumn(
              icon: Icons.arrow_downward_rounded,
              label: 'Download',
              value: FormatUtils.formatSpeed(stats.downloadSpeedBps),
              color: AppColors.neonTurquoise,
            ),
            Container(
              width: 1,
              height: 40,
              color: Colors.white.withValues(alpha: 0.1),
            ),
            _buildStatColumn(
              icon: Icons.arrow_upward_rounded,
              label: 'Upload',
              value: FormatUtils.formatSpeed(stats.uploadSpeedBps),
              color: AppColors.electricBlue,
            ),
          ],
        ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatColumn({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
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

    return Text(
      FormatUtils.formatDuration(_elapsed),
      style: TextStyle(
        color: Colors.grey[400],
        fontSize: 14,
        fontWeight: FontWeight.w500,
        letterSpacing: 2,
      ),
    );
  }
}
