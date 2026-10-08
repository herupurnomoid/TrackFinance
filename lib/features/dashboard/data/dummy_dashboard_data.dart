import 'package:flutter/material.dart';

class TransactionItem {
  final String id;
  final String title;
  final String subtitle;
  final String amount;
  final bool isIncome;
  final IconData icon;
  final bool isPrimaryIcon;

  const TransactionItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isIncome,
    required this.icon,
    this.isPrimaryIcon = false,
  });
}

class TransactionDateGroup {
  final String date;
  final List<TransactionItem> items;

  const TransactionDateGroup({required this.date, required this.items});
}

class CashflowDataPoint {
  final String day;
  final double incomePercentage; // 0.0 - 1.0
  final double expensePercentage; // 0.0 - 1.0
  final bool isHighlighted;

  const CashflowDataPoint({
    required this.day,
    required this.incomePercentage,
    required this.expensePercentage,
    this.isHighlighted = false,
  });
}

class CategoryBreakdownItem {
  final String name;
  final String amount;
  final int percentage;
  final Color color;

  const CategoryBreakdownItem({
    required this.name,
    required this.amount,
    required this.percentage,
    required this.color,
  });
}

class DummyDashboardData {
  static const String totalIncome = 'Rp 9.800.000';
  static const String totalExpense = 'Rp 4.250.000';
  static const String topExpenseTitle = 'Makanan & Minuman';
  static const String topExpenseCount = '38 transaksi';
  static const String topExpenseAmount = 'Rp 1.785.000';
  static const String healthStatus = 'Sangat Sehat';
  static const String healthScore = 'Skor 85 / 100';
  static const String healthNote = 'Rasio belanja 43% aman';

  static const List<CashflowDataPoint> chartPoints = [
    CashflowDataPoint(
      day: '18 Mei',
      incomePercentage: 0.55,
      expensePercentage: 0.35,
    ),
    CashflowDataPoint(
      day: '20 Mei',
      incomePercentage: 0.40,
      expensePercentage: 0.60,
    ),
    CashflowDataPoint(
      day: '22 Mei',
      incomePercentage: 0.80,
      expensePercentage: 0.45,
    ),
    CashflowDataPoint(
      day: '24 Mei',
      incomePercentage: 0.30,
      expensePercentage: 0.50,
    ),
    CashflowDataPoint(
      day: '28 Mei',
      incomePercentage: 0.95,
      expensePercentage: 0.40,
      isHighlighted: true,
    ),
  ];

  static const List<CategoryBreakdownItem> expenseCategories = [
    CategoryBreakdownItem(
      name: 'Makanan & Minuman',
      amount: 'Rp 1.785.000',
      percentage: 42,
      color: Color(0xFF65D0F4), // primaryContainer
    ),
    CategoryBreakdownItem(
      name: 'Belanja & Kebutuhan',
      amount: 'Rp 1.020.000',
      percentage: 24,
      color: Color(0xFF006780), // primary
    ),
    CategoryBreakdownItem(
      name: 'Transportasi',
      amount: 'Rp 765.000',
      percentage: 18,
      color: Color(0xFFB7EAFF), // primaryFixed
    ),
    CategoryBreakdownItem(
      name: 'Tagihan & Utilitas',
      amount: 'Rp 467.500',
      percentage: 11,
      color: Color(0xFFD8E5EA), // secondaryContainer
    ),
    CategoryBreakdownItem(
      name: 'Hiburan & Rekreasi',
      amount: 'Rp 212.500',
      percentage: 5,
      color: Color(0xFFE2E2E2), // surfaceContainerHighest
    ),
  ];

  static const List<TransactionDateGroup> transactionGroups = [
    TransactionDateGroup(
      date: '17 Oktober 2026',
      items: [
        TransactionItem(
          id: 'tx-1',
          title: 'Belanja Bulanan',
          subtitle: '14:20 WIB • Supermarket Grand Galaxy',
          amount: '-Rp 650.000',
          isIncome: false,
          icon: Icons.north_east_rounded,
        ),
        TransactionItem(
          id: 'tx-2',
          title: 'Pendapatan Freelance',
          subtitle: '11:00 WIB • Transfer Masuk Klien',
          amount: '+Rp 2.500.000',
          isIncome: true,
          icon: Icons.south_west_rounded,
        ),
      ],
    ),
    TransactionDateGroup(
      date: '16 Oktober 2026',
      items: [
        TransactionItem(
          id: 'tx-3',
          title: 'Makanan & Minuman',
          subtitle: '19:10 WIB • Restoran Ramen Express',
          amount: '-Rp 245.000',
          isIncome: false,
          icon: Icons.north_east_rounded,
        ),
        TransactionItem(
          id: 'tx-4',
          title: 'Transportasi',
          subtitle: '08:45 WIB • Bensin Pertamax',
          amount: '-Rp 350.000',
          isIncome: false,
          icon: Icons.north_east_rounded,
        ),
      ],
    ),
    TransactionDateGroup(
      date: '15 Oktober 2026',
      items: [
        TransactionItem(
          id: 'tx-5',
          title: 'Utilitas',
          subtitle: '11:00 WIB • Tagihan Listrik PLN',
          amount: '-Rp 467.500',
          isIncome: false,
          icon: Icons.north_east_rounded,
        ),
        TransactionItem(
          id: 'tx-6',
          title: 'Pendapatan Tambahan',
          subtitle: '09:30 WIB • Bonus Kinerja Proyek',
          amount: '+Rp 1.200.000',
          isIncome: true,
          icon: Icons.south_west_rounded,
        ),
      ],
    ),
  ];

  // Flattened transactions for backward compatibility with widgets
  static List<TransactionItem> get recentTransactions {
    final list = <TransactionItem>[];
    for (final group in transactionGroups) {
      list.addAll(group.items);
    }
    return list;
  }
}
