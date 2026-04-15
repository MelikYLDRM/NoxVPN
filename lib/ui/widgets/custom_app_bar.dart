import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/vpn_status.dart';
import '../../providers/vpn_provider.dart';

class CustomAppBar extends ConsumerWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final vpnState = ref.watch(vpnStateProvider);
    final isConnected = vpnState.isConnected;
    final theme = Theme.of(context);

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Status indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: isConnected
                    ? AppColors.successGreen.withValues(alpha: 0.15)
                    : vpnState.status == VpnConnectionStatus.error
                    ? AppColors.errorRed.withValues(alpha: 0.15)
                    : AppColors.cardBg,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isConnected
                          ? AppColors.successGreen
                          : vpnState.status == VpnConnectionStatus.error
                          ? AppColors.errorRed
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isConnected ? l.protected_ : l.notProtected,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isConnected
                          ? AppColors.successGreen
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            // App name
            Text(
              l.appName,
              style: theme.textTheme.titleSmall?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
            // Shield icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.cardBg,
              ),
              child: Icon(
                isConnected ? Icons.shield : Icons.shield_outlined,
                color: isConnected
                    ? AppColors.neonTurquoise
                    : AppColors.textSecondary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
