import 'package:flutter/material.dart';

/// Enum merepresentasikan 4 waktu dalam sehari untuk animasi background header
enum DashboardTimeOfDay {
  pagi,
  siang,
  sore,
  malam;

  /// Deteksi otomatis berdasarkan jam saat ini
  /// - Pagi:  04:00 - 10:59
  /// - Siang: 11:00 - 14:59
  /// - Sore:  15:00 - 17:59
  /// - Malam: 18:00 - 03:59
  static DashboardTimeOfDay fromDateTime([DateTime? dt]) {
    final hour = (dt ?? DateTime.now()).hour;
    if (hour >= 4 && hour < 11) {
      return DashboardTimeOfDay.pagi;
    } else if (hour >= 11 && hour < 15) {
      return DashboardTimeOfDay.siang;
    } else if (hour >= 15 && hour < 18) {
      return DashboardTimeOfDay.sore;
    } else {
      return DashboardTimeOfDay.malam;
    }
  }

  /// Teks sapaan ramah sesuai waktu
  String get greeting {
    switch (this) {
      case DashboardTimeOfDay.pagi:
        return 'Selamat pagi,';
      case DashboardTimeOfDay.siang:
        return 'Selamat siang,';
      case DashboardTimeOfDay.sore:
        return 'Selamat sore,';
      case DashboardTimeOfDay.malam:
        return 'Selamat malam,';
    }
  }

  /// Nama label singkat
  String get label {
    switch (this) {
      case DashboardTimeOfDay.pagi:
        return 'Pagi';
      case DashboardTimeOfDay.siang:
        return 'Siang';
      case DashboardTimeOfDay.sore:
        return 'Sore';
      case DashboardTimeOfDay.malam:
        return 'Malam';
    }
  }

  /// Nama lengkap waktu
  String get title {
    switch (this) {
      case DashboardTimeOfDay.pagi:
        return 'Pagi Hari';
      case DashboardTimeOfDay.siang:
        return 'Siang Hari';
      case DashboardTimeOfDay.sore:
        return 'Sore Hari';
      case DashboardTimeOfDay.malam:
        return 'Malam Hari';
    }
  }

  /// Rentang jam
  String get timeRange {
    switch (this) {
      case DashboardTimeOfDay.pagi:
        return '04:00 – 10:59';
      case DashboardTimeOfDay.siang:
        return '11:00 – 14:59';
      case DashboardTimeOfDay.sore:
        return '15:00 – 17:59';
      case DashboardTimeOfDay.malam:
        return '18:00 – 03:59';
    }
  }

  /// Emoji representatif
  String get emoji {
    switch (this) {
      case DashboardTimeOfDay.pagi:
        return '🌅';
      case DashboardTimeOfDay.siang:
        return '☀️';
      case DashboardTimeOfDay.sore:
        return '🌇';
      case DashboardTimeOfDay.malam:
        return '🌙';
    }
  }

  /// Deskripsi nuansa animasi
  String get description {
    switch (this) {
      case DashboardTimeOfDay.pagi:
        return 'Matahari terbit keemasan, awan fajar & kicau burung';
      case DashboardTimeOfDay.siang:
        return 'Langit biru cerah, kilau matahari & awan berarak';
      case DashboardTimeOfDay.sore:
        return 'Nuansa senja tembaga, matahari tenggelam & kawanan burung';
      case DashboardTimeOfDay.malam:
        return 'Langit malam berbintang, bulan sabit & bintang jatuh';
    }
  }

  /// Warna gradient latar belakang langit
  List<Color> get skyGradientColors {
    switch (this) {
      case DashboardTimeOfDay.pagi:
        return const [
          Color(0xFF1E3A8A), // Deep Morning Navy
          Color(0xFF1D4ED8), // Royal Azure
          Color(0xFF2563EB), // Sky Blue
          Color(0xFF0284C7), // Morning Cyan
          Color(0xFF0369A1), // Soft Horizon Blue
        ];
      case DashboardTimeOfDay.siang:
        return const [
          Color(0xFF1D4ED8), // Vibrant Royal Blue
          Color(0xFF2563EB), // Vibrant Primary Blue
          Color(0xFF3B82F6), // Bright Azure
          Color(0xFF60A5FA), // Crisp Daylight Sky
        ];
      case DashboardTimeOfDay.sore:
        return const [
          Color(0xFF2E1065), // Deep Twilight Violet
          Color(0xFF581C87), // Rich Purple Dusk
          Color(0xFF9A3412), // Deep Rust Orange
          Color(0xFFC2410C), // Sunset Amber-Orange
          Color(0xFFD97706), // Warm Horizon Gold
        ];
      case DashboardTimeOfDay.malam:
        return const [
          Color(0xFF050B18), // Deep Midnight Obsidian
          Color(0xFF0F172A), // Slate Navy
          Color(0xFF172554), // Deep Cobalt
          Color(0xFF1E293B), // Midnight Blue
        ];
    }
  }

  /// Warna teratas untuk overscroll pull-to-refresh
  Color get pullToRefreshTopColor {
    return skyGradientColors.first;
  }
}
