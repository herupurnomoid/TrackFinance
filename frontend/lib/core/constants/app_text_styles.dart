import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle headlineWelcome = GoogleFonts.plusJakartaSans(
    fontSize: 30,
    height: 38 / 30,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.8,
    color: AppColors.onSurface,
  );

  static TextStyle bodyDescription = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurfaceVariant,
  );

  static TextStyle buttonGoogle = GoogleFonts.plusJakartaSans(
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    color: AppColors.onSurface,
  );

  static TextStyle securityNote = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
    color: AppColors.secondary,
  );

  // Dashboard Styles
  static TextStyle headlineLg = GoogleFonts.plusJakartaSans(
    fontSize: 26,
    height: 34 / 26,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: AppColors.onSurface,
  );

  static TextStyle headlineMd = GoogleFonts.plusJakartaSans(
    fontSize: 20,
    height: 28 / 20,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    color: AppColors.onSurface,
  );

  static TextStyle headlineSm = GoogleFonts.plusJakartaSans(
    fontSize: 17,
    height: 24 / 17,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: AppColors.onSurface,
  );

  static TextStyle labelLg = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    height: 18 / 14,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.1,
    color: AppColors.onSurface,
  );

  static TextStyle labelMd = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.2,
    color: AppColors.secondary,
  );

  static TextStyle labelSm = GoogleFonts.plusJakartaSans(
    fontSize: 10,
    height: 14 / 10,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.4,
    color: AppColors.primary,
  );

  static TextStyle bodySm = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w500,
    color: AppColors.secondary,
  );

  static TextStyle bodyMd = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w500,
    color: AppColors.onSurface,
  );
}
