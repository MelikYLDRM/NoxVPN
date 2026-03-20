import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'core/theme/app_colors.dart';
import 'ui/screens/main_shell.dart';

void main() {
  runApp(const ProviderScope(child: NovaVPNApp()));
}

class NovaVPNApp extends StatelessWidget {
  const NovaVPNApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nox VPN',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: AppColors.neonTurquoise,
        scaffoldBackgroundColor: AppColors.bgDark,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ).apply(bodyColor: Colors.white, displayColor: Colors.white),
      ),
      home: const MainShell(),
    );
  }
}
