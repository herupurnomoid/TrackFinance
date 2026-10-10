import 'package:flutter/material.dart';

/// Model Rincian Kategori untuk Struktur Transaksi
class ReportCategoryItem {
  final String name;
  final double percentage;
  final int amount;
  final IconData icon;
  final Color iconColor;
  final Color containerColor;
  final Color badgeTextColor;
  final Color sliceColor;

  const ReportCategoryItem({
    required this.name,
    required this.percentage,
    required this.amount,
    required this.icon,
    required this.iconColor,
    required this.containerColor,
    required this.badgeTextColor,
    required this.sliceColor,
  });
}

/// Model Titik Harian untuk Grafik Batang Tren Keuangan
class ReportDailyTrendItem {
  final String dayStr; // '01', '02', '05', dsb.
  final String fullDateStr; // '01 Okt'
  final int expense; // nominal pengeluaran
  final int income; // nominal pemasukan

  const ReportDailyTrendItem({
    required this.dayStr,
    required this.fullDateStr,
    required this.expense,
    required this.income,
  });
}

/// Data Store untuk Laporan Keuangan
class ReportDataStore {
  ReportDataStore._();

  /// Format nominal mata uang Rupiah
  static String formatCurrency(int amount, {bool showSign = false, bool isIncome = false}) {
    final absAmount = amount.abs();
    final str = absAmount.toString();
    final buffer = StringBuffer();
    int count = 0;

    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }

    final formatted = buffer.toString().split('').reversed.join('');
    if (!showSign) {
      return 'Rp $formatted';
    }
    return isIncome ? '+Rp $formatted' : '-Rp $formatted';
  }

  /// Data Harian Oktober 2026 (Sesuai Referensi Visual)
  static const List<ReportDailyTrendItem> oktoberDailyTrends = [
    ReportDailyTrendItem(
      dayStr: '01',
      fullDateStr: '01 Okt',
      expense: 21000,
      income: 4500000,
    ),
    ReportDailyTrendItem(
      dayStr: '02',
      fullDateStr: '02 Okt',
      expense: 97000,
      income: 0,
    ),
    ReportDailyTrendItem(
      dayStr: '05',
      fullDateStr: '05 Okt',
      expense: 11466,
      income: 400000,
    ),
    ReportDailyTrendItem(
      dayStr: '06',
      fullDateStr: '06 Okt',
      expense: 102000,
      income: 0,
    ),
    ReportDailyTrendItem(
      dayStr: '07',
      fullDateStr: '07 Okt',
      expense: 17000,
      income: 100000,
    ),
  ];

  /// Kategori Pengeluaran (Keluar) Oktober 2026: Total Rp 248.466
  static const List<ReportCategoryItem> expenseCategoriesOktober = [
    ReportCategoryItem(
      name: 'Makanan & Minuman',
      percentage: 39.0,
      amount: 97000,
      icon: Icons.restaurant_rounded,
      iconColor: Color(0xFFBA1A1A),
      containerColor: Color(0xFFFFDAD6),
      badgeTextColor: Color(0xFF93000A),
      sliceColor: Color(0xFFDC2626),
    ),
    ReportCategoryItem(
      name: 'Transportasi',
      percentage: 29.3,
      amount: 72666,
      icon: Icons.directions_car_rounded,
      iconColor: Color(0xFFBA1A1A),
      containerColor: Color(0xFFFFDAD6),
      badgeTextColor: Color(0xFF93000A),
      sliceColor: Color(0xFFEF4444),
    ),
    ReportCategoryItem(
      name: 'Belanja',
      percentage: 27.7,
      amount: 68800,
      icon: Icons.shopping_bag_rounded,
      iconColor: Color(0xFFBA1A1A),
      containerColor: Color(0xFFFFDAD6),
      badgeTextColor: Color(0xFF93000A),
      sliceColor: Color(0xFFF87171),
    ),
    ReportCategoryItem(
      name: 'Tagihan',
      percentage: 4.0,
      amount: 10000,
      icon: Icons.receipt_long_rounded,
      iconColor: Color(0xFFBA1A1A),
      containerColor: Color(0xFFFFDAD6),
      badgeTextColor: Color(0xFF93000A),
      sliceColor: Color(0xFFFCA5A5),
    ),
  ];

  /// Kategori Pemasukan (Masuk) Oktober 2026: Total Rp 5.000.000
  static const List<ReportCategoryItem> incomeCategoriesOktober = [
    ReportCategoryItem(
      name: 'Gaji',
      percentage: 90.0,
      amount: 4500000,
      icon: Icons.payments_rounded,
      iconColor: Color(0xFF15803D),
      containerColor: Color(0xFFDCFCE7),
      badgeTextColor: Color(0xFF006329),
      sliceColor: Color(0xFF15803D),
    ),
    ReportCategoryItem(
      name: 'Freelance',
      percentage: 8.0,
      amount: 400000,
      icon: Icons.laptop_mac_rounded,
      iconColor: Color(0xFF16A34A),
      containerColor: Color(0xFFDCFCE7),
      badgeTextColor: Color(0xFF006329),
      sliceColor: Color(0xFF16A34A),
    ),
    ReportCategoryItem(
      name: 'Hadiah',
      percentage: 2.0,
      amount: 100000,
      icon: Icons.card_giftcard_rounded,
      iconColor: Color(0xFF4ADE80),
      containerColor: Color(0xFFDCFCE7),
      badgeTextColor: Color(0xFF006329),
      sliceColor: Color(0xFF4ADE80),
    ),
  ];
}
