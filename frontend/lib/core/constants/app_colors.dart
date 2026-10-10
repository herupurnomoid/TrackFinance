import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Background & Surface
  static const Color background = Color(0xFFF9F9F9);
  static const Color surface = Color(0xFFF9F9F9);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF3F3F4);
  static const Color surfaceContainer = Color(0xFFEEEEEE);
  static const Color surfaceContainerHigh = Color(0xFFE8E8E8);
  static const Color surfaceContainerHighest = Color(0xFFE2E2E2);

  // Text Colors
  static const Color onSurface = Color(0xFF1A1C1C);
  static const Color onSurfaceVariant = Color(0xFF3E484D);
  static const Color secondary = Color(0xFF546065);

  // Brand & Accent Colors (Cyan / Teal palette)
  static const Color primary = Color(0xFF006780);
  static const Color primaryContainer = Color(0xFF65D0F4);
  static const Color primaryFixed = Color(0xFFB7EAFF);
  static const Color primaryFixedDim = Color(0xFF69D4F8);

  static const Color tertiary = Color(0xFF006684);
  static const Color tertiaryContainer = Color(0xFF59D0FF);
  static const Color tertiaryFixed = Color(0xFFBEE9FF);

  static const Color secondaryContainer = Color(0xFFD8E5EA);
  static const Color onSecondaryContainer = Color(0xFF5A666B);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Status & Transaction Colors
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color onErrorContainer = Color(0xFF93000A);
  static const Color expense = Color(0xFFF43F5E); // rose-500
  static const Color income = Color(0xFF10B981);  // emerald-500

  static const Color outline = Color(0xFF6E797E);
  static const Color outlineVariant = Color(0xFFBDC8CE);

  // Shadows
  static const Color clayShadow = Color(0x7365D0F4); // rgba(101, 208, 244, 0.45)
  static const Color clayDepth = Color(0x29006780);  // rgba(0, 103, 128, 0.16)
  static const Color buttonShadow = Color(0x4765D0F4); // rgba(101, 208, 244, 0.28)
  static const Color darkSubtleShadow = Color(0x140D2C3A); // rgba(13, 44, 58, 0.08)

  // Modern Tactile Finance (Blue & Slate Palette from DESIGN.md)
  static const Color tactilePrimary = Color(0xFF2563EB); // Vibrant Primary Blue
  static const Color tactilePrimaryDark = Color(0xFF1E40AF); // Royal Dark Blue
  static const Color tactileNavy = Color(0xFF00174B); // Deep Navy Shadow Base
  static const Color tactileNavySecondary = Color(0xFF001453);
  static const Color tactilePale = Color(0xFFDBEAFE); // Soft Accent Pale Blue
  static const Color tactileTextPrimary = Color(0xFF0F172A); // Slate 900
  static const Color tactileTextSecondary = Color(0xFF64748B); // Slate 500
  static const Color tactileBorder = Color(0xFFE2E8F0); // Neutral Crisp Border
  static const Color tactileBackground = Color(0xFFF1F5F9); // Slate 100 App Canvas
  static const Color tactileSurfaceLow = Color(0xFFF8FAFC); // Slate 50
  static const Color tactileGreen = Color(0xFF16A34A); // Income Green
  static const Color tactileGreenLight = Color(0xFFDCFCE7); // Income Tint Container
}
