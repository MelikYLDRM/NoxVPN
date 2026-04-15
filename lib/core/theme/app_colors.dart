import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary
  static const Color neonTurquoise = Color(0xFF00F2FE);
  static const Color electricBlue = Color(0xFF0072FF);

  // Backgrounds
  static const Color bgDark = Color(0xFF0A0E21);
  static const Color bgBlack = Color(0xFF000000);
  static const Color surface = Color(0xFF111529);

  // Glass
  static const Color cardGlass = Color(0x1AFFFFFF);
  static const Color cardGlassBorder = Color(0x33FFFFFF);

  // Text
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF8F9BB3);

  // Semantic
  static const Color errorRed = Color(0xFFFF4757);
  static const Color warningOrange = Color(0xFFFF9F43);
  static const Color successGreen = Color(0xFF2ED573);

  // Subtle
  static const Color divider = Color(0x14FFFFFF);
  static const Color cardBg = Color(0x0DFFFFFF);
  static const Color cardBorder = Color(0x14FFFFFF);
  static const Color iconBg = Color(0x0DFFFFFF);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [neonTurquoise, electricBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient bgGradient = LinearGradient(
    colors: [bgDark, bgBlack],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient warpGradient = LinearGradient(
    colors: [Color(0xFFF48120), Color(0xFFF6821F)],
  );
}
