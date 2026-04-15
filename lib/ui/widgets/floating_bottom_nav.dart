import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/app_localizations.dart';
import 'glass_card.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/navigation_provider.dart';

class FloatingBottomNav extends ConsumerWidget {
  const FloatingBottomNav({super.key});

  static const List<IconData> _icons = [
    Icons.home_rounded,
    Icons.public_rounded,
    Icons.tune_rounded,
    Icons.person_rounded,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final labels = [l.navHome, l.navServers, l.navSettings, l.navAbout];
    final currentIndex = ref.watch(currentTabIndexProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 12),
        borderRadius: BorderRadius.circular(28),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_icons.length, (index) {
            bool isSelected = currentIndex == index;
            return Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  HapticFeedback.selectionClick();
                  ref.read(currentTabIndexProvider.notifier).state = index;
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  padding: EdgeInsets.symmetric(
                    horizontal: isSelected ? 16 : 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: isSelected ? AppColors.primaryGradient : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.neonTurquoise.withValues(
                                alpha: 0.4,
                              ),
                              blurRadius: 12,
                              spreadRadius: 1,
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _icons[index],
                        color: isSelected
                            ? Colors.white
                            : AppColors.textSecondary,
                        size: 22,
                      ),
                      if (isSelected) ...[
                        const SizedBox(width: 6),
                        Text(
                          labels[index],
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
