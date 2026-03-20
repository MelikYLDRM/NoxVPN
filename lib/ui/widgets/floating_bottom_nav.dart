import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'glass_card.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/navigation_provider.dart';

class FloatingBottomNav extends ConsumerWidget {
  const FloatingBottomNav({super.key});

  static const List<IconData> _icons = [
    Icons.home_filled,
    Icons.public,
    Icons.settings,
    Icons.person_outline,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentTabIndexProvider);

    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 24),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 16),
        borderRadius: BorderRadius.circular(30),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_icons.length, (index) {
            bool isSelected = currentIndex == index;
            return GestureDetector(
              onTap: () {
                ref.read(currentTabIndexProvider.notifier).state = index;
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.neonTurquoise.withValues(alpha: 0.5),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ]
                      : [],
                  gradient: isSelected
                      ? const LinearGradient(
                          colors: [
                            AppColors.neonTurquoise,
                            AppColors.electricBlue,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                ),
                child: Icon(
                  _icons[index],
                  color: isSelected ? Colors.white : AppColors.textGrey,
                  size: 26,
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
