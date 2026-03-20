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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.bgDark, AppColors.bgBlack],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: IndexedStack(
          index: currentIndex,
          children: const [
            HomeScreen(),
            ServerListScreen(),
            SettingsScreen(),
            ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: const FloatingBottomNav(),
    );
  }
}
