import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/navigation_provider.dart';
import '../widgets/floating_bottom_nav.dart';
import 'home_screen.dart';
import 'server_list_screen.dart';
import 'settings_screen.dart';
import 'profile_screen.dart';

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(currentTabIndexProvider);

    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.bgGradient),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeIn,
          transitionBuilder: (child, animation) {
            return FadeTransition(opacity: animation, child: child);
          },
          child: _buildPage(currentIndex),
        ),
      ),
      bottomNavigationBar: const FloatingBottomNav(),
    );
  }

  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const HomeScreen(key: ValueKey('home'));
      case 1:
        return const ServerListScreen(key: ValueKey('servers'));
      case 2:
        return const SettingsScreen(key: ValueKey('settings'));
      case 3:
        return const ProfileScreen(key: ValueKey('profile'));
      default:
        return const HomeScreen(key: ValueKey('home'));
    }
  }
}
