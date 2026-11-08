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

  /// Warna teks nominal pemasukan tanpa kontainer yang diadaptasi sesuai
  /// kontras kecerahan & rona langit tiap waktu agar selalu jelas terlihat.
  Color get incomeAmountColor {
    switch (this) {
      case DashboardTimeOfDay.pagi:
        // Mint musim semi hangat yang kontras terhadap langit biru-sian fajar
        return const Color(0xFFBBF7D0);
      case DashboardTimeOfDay.siang:
        // Mint es berluminesensi tinggi di atas langit biru terang & awan putih
        return const Color(0xFFD1FAE5);
      case DashboardTimeOfDay.sore:
        // Mint giok sejuk komplementer terhadap langit senja jingga-tembaga
        return const Color(0xFFA7F3D0);
      case DashboardTimeOfDay.malam:
        // Zamrud bercahaya lembut di atas langit malam obsidian gelap
        return const Color(0xFF6EE7B7);
    }
  }

  /// Warna teks nominal pengeluaran tanpa kontainer yang diadaptasi sesuai
  /// kontras kecerahan & rona langit tiap waktu agar tidak menyatu dengan latar.
  Color get expenseAmountColor {
    switch (this) {
      case DashboardTimeOfDay.pagi:
        // Merah muda fajar cerah yang kontras hangat di atas langit biru pagi
        return const Color(0xFFFFD6DF);
      case DashboardTimeOfDay.siang:
        // Rose es berluminesensi tinggi agar tajam di atas langit siang cerah
        return const Color(0xFFFFE4E8);
      case DashboardTimeOfDay.sore:
        // Rose mutiara sejuk (tanpa unsur jingga) agar tidak tenggelam di warna senja
        return const Color(0xFFFFE4EC);
      case DashboardTimeOfDay.malam:
        // Rose cahaya bulan yang kontras anggun di atas langit malam gelap
        return const Color(0xFFFDA4AF);
    }
  }

  /// Lapisan bayangan optik teks pemasukan tanpa kontainer sesuai tema waktu
  List<Shadow> get incomeAmountShadows {
    switch (this) {
      case DashboardTimeOfDay.pagi:
        return const [
          Shadow(
            color: Color(0xE0041E34),
            blurRadius: 3.5,
            offset: Offset(0, 1.5),
          ),
          Shadow(
            color: Color(0x99041E34),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ];
      case DashboardTimeOfDay.siang:
        return const [
          Shadow(
            color: Color(0xEB071D49),
            blurRadius: 3.5,
            offset: Offset(0, 1.5),
          ),
          Shadow(
            color: Color(0xB3071D49),
            blurRadius: 11,
            offset: Offset(0, 3),
          ),
          Shadow(
            color: Color(0x8A071D49),
            blurRadius: 1.2,
            offset: Offset(0, 0.5),
          ),
        ];
      case DashboardTimeOfDay.sore:
        return const [
          Shadow(
            color: Color(0xEB260714),
            blurRadius: 3.5,
            offset: Offset(0, 1.5),
          ),
          Shadow(
            color: Color(0xB81C050E),
            blurRadius: 11,
            offset: Offset(0, 3),
          ),
          Shadow(
            color: Color(0x851C050E),
            blurRadius: 1.2,
            offset: Offset(0, 0.5),
          ),
        ];
      case DashboardTimeOfDay.malam:
        return const [
          Shadow(
            color: Color(0xEB020617),
            blurRadius: 4,
            offset: Offset(0, 1.5),
          ),
          Shadow(
            color: Color(0x5910B981),
            blurRadius: 12,
            offset: Offset(0, 0),
          ),
        ];
    }
  }

  /// Lapisan bayangan optik teks pengeluaran tanpa kontainer sesuai tema waktu
  List<Shadow> get expenseAmountShadows {
    switch (this) {
      case DashboardTimeOfDay.pagi:
        return const [
          Shadow(
            color: Color(0xE0041E34),
            blurRadius: 3.5,
            offset: Offset(0, 1.5),
          ),
          Shadow(
            color: Color(0x99041E34),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ];
      case DashboardTimeOfDay.siang:
        return const [
          Shadow(
            color: Color(0xEB1A1245),
            blurRadius: 3.5,
            offset: Offset(0, 1.5),
          ),
          Shadow(
            color: Color(0xB3071D49),
            blurRadius: 11,
            offset: Offset(0, 3),
          ),
          Shadow(
            color: Color(0x8A1A1245),
            blurRadius: 1.2,
            offset: Offset(0, 0.5),
          ),
        ];
      case DashboardTimeOfDay.sore:
        return const [
          Shadow(
            color: Color(0xEB2D0618),
            blurRadius: 3.5,
            offset: Offset(0, 1.5),
          ),
          Shadow(
            color: Color(0xB81C050E),
            blurRadius: 11,
            offset: Offset(0, 3),
          ),
          Shadow(
            color: Color(0x852D0618),
            blurRadius: 1.2,
            offset: Offset(0, 0.5),
          ),
        ];
      case DashboardTimeOfDay.malam:
        return const [
          Shadow(
            color: Color(0xEB020617),
            blurRadius: 4,
            offset: Offset(0, 1.5),
          ),
          Shadow(
            color: Color(0x59F43F5E),
            blurRadius: 12,
            offset: Offset(0, 0),
          ),
        ];
    }
  }
}
