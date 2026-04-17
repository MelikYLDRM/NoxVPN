import 'package:flutter/material.dart';

import '../../core/l10n/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/server_config.dart';
import 'server_avatar.dart';

class ServerTile extends StatelessWidget {
  final ServerConfig server;
  final bool isSelected;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteToggle;

  const ServerTile({
    super.key,
    required this.server,
    required this.isSelected,
    this.isFavorite = false,
    required this.onTap,
    this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l = AppLocalizations.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.cardRadius),
            color: isSelected
                ? AppColors.neonTurquoise.withValues(alpha: 0.1)
                : AppColors.cardBg,
            border: Border.all(
              color: isSelected
                  ? AppColors.neonTurquoise.withValues(alpha: 0.4)
                  : AppColors.cardBorder,
            ),
          ),
          child: Row(
            children: [
              ServerAvatar(server: server),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l.resolve(server.city),
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(server.country, style: theme.textTheme.bodySmall),
                  ],
                ),
              ),
              PingBadge(pingMs: server.estimatedPingMs),
              if (onFavoriteToggle != null) ...[
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onFavoriteToggle,
                  child: Icon(
                    isFavorite
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: isFavorite
                        ? Colors.amber
                        : AppColors.textSecondary.withValues(alpha: 0.5),
                    size: 22,
                  ),
                ),
              ],
              const SizedBox(width: AppSpacing.sm),
              if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: AppColors.neonTurquoise,
                  size: 22,
                )
              else
                Icon(
                  Icons.circle_outlined,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                  size: 22,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class PingBadge extends StatelessWidget {
  final int pingMs;

  const PingBadge({super.key, required this.pingMs});

  Color get _color {
    if (pingMs < 50) return Colors.greenAccent;
    if (pingMs < 100) return Colors.yellowAccent;
    if (pingMs < 200) return Colors.orangeAccent;
    return Colors.redAccent;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$pingMs ms',
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: _color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
