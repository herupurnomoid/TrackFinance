import 'package:flutter/material.dart';

enum TransactionType { income, expense }

class DashboardTransaction {
  final String id;
  final String dateStr;
  final String dateKey; // YYYY-MM-DD
  final int year;
  final int month; // 0-based: 0 = Jan, 9 = Okt
  final int day;
  final String category;
  final String meta;
  final int amount; // positive for income, negative for expense
  final TransactionType type;
  final IconData icon;

  const DashboardTransaction({
    required this.id,
    required this.dateStr,
    required this.dateKey,
    required this.year,
    required this.month,
    required this.day,
    required this.category,
    required this.meta,
    required this.amount,
    required this.type,
    required this.icon,
  });

  bool get isIncome => type == TransactionType.income;

  DashboardTransaction copyWith({
    String? id,
    String? dateStr,
    String? dateKey,
    int? year,
    int? month,
    int? day,
    String? category,
    String? meta,
    int? amount,
    TransactionType? type,
    IconData? icon,
  }) {
    return DashboardTransaction(
      id: id ?? this.id,
      dateStr: dateStr ?? this.dateStr,
      dateKey: dateKey ?? this.dateKey,
      year: year ?? this.year,
      month: month ?? this.month,
      day: day ?? this.day,
      category: category ?? this.category,
      meta: meta ?? this.meta,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      icon: icon ?? this.icon,
    );
  }
}

class DashboardDataStore {
  DashboardDataStore._();

  static const List<String> monthsName = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static const List<String> monthsShort = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  static const List<DashboardTransaction> initialTransactions = [
    // 2025 Transactions
    DashboardTransaction(
      id: 'tx-2025-1',
      dateStr: '15 November 2025',
      dateKey: '2025-11-15',
      year: 2025,
      month: 10,
      day: 15,
      category: 'Gaji & Pendapatan',
      meta: '09.30 · bonus tahunan & gaji freelance',
      amount: 3200000,
      type: TransactionType.income,
      icon: Icons.work_outline_rounded,
    ),
    DashboardTransaction(
      id: 'tx-2025-2',
      dateStr: '20 November 2025',
      dateKey: '2025-11-20',
      year: 2025,
      month: 10,
      day: 20,
      category: 'Belanja Elektronik',
      meta: '14.15 · periferal gadget & monitor',
      amount: -1100000,
      type: TransactionType.expense,
      icon: Icons.devices_other_rounded,
    ),
    DashboardTransaction(
      id: 'tx-2025-3',
      dateStr: '10 Desember 2025',
      dateKey: '2025-12-10',
      year: 2025,
      month: 11,
      day: 10,
      category: 'Belanja Bulanan & Kebutuhan',
      meta: '11.00 · groceries bulanan keluarga',
      amount: -500000,
      type: TransactionType.expense,
      icon: Icons.shopping_bag_outlined,
    ),
    DashboardTransaction(
      id: 'tx-2025-4',
      dateStr: '28 Desember 2025',
      dateKey: '2025-12-28',
      year: 2025,
      month: 11,
      day: 28,
      category: 'Hiburan & Liburan',
      meta: '19.00 · tiket rekreasi akhir tahun',
      amount: -250000,
      type: TransactionType.expense,
      icon: Icons.confirmation_number_outlined,
    ),

    // Juli 2026
    DashboardTransaction(
      id: 'tx-juli-1',
      dateStr: '15 Juli 2026',
      dateKey: '2026-07-15',
      year: 2026,
      month: 6,
      day: 15,
      category: 'Dividen & Freelance',
      meta: '10.00 · dividen investasi & freelance',
      amount: 1128571,
      type: TransactionType.income,
      icon: Icons.trending_up_rounded,
    ),
    DashboardTransaction(
      id: 'tx-juli-2',
      dateStr: '18 Juli 2026',
      dateKey: '2026-07-18',
      year: 2026,
      month: 6,
      day: 18,
      category: 'Belanja & Utilitas',
      meta: '14.30 · tagihan listrik & supermarket',
      amount: -632500,
      type: TransactionType.expense,
      icon: Icons.receipt_long_rounded,
    ),

    // Agustus 2026
    DashboardTransaction(
      id: 'tx-agu-1',
      dateStr: '12 Agustus 2026',
      dateKey: '2026-08-12',
      year: 2026,
      month: 7,
      day: 12,
      category: 'Cashback & Penjualan',
      meta: '11.15 · cashback & jual barang bekas',
      amount: 450000,
      type: TransactionType.income,
      icon: Icons.savings_outlined,
    ),
    DashboardTransaction(
      id: 'tx-agu-2',
      dateStr: '20 Agustus 2026',
      dateKey: '2026-08-20',
      year: 2026,
      month: 7,
      day: 20,
      category: 'Servis & Belanja',
      meta: '16.40 · servis motor berkala & belanja',
      amount: -1435659,
      type: TransactionType.expense,
      icon: Icons.build_outlined,
    ),

    // September 2026
    DashboardTransaction(
      id: 'tx-sep-1',
      dateStr: '28 September 2026',
      dateKey: '2026-09-28',
      year: 2026,
      month: 8,
      day: 28,
      category: 'Gaji Utama',
      meta: '10.00 · gaji bulanan kantor',
      amount: 6500000,
      type: TransactionType.income,
      icon: Icons.account_balance_wallet_outlined,
    ),
    DashboardTransaction(
      id: 'tx-sep-2',
      dateStr: '28 September 2026',
      dateKey: '2026-09-28',
      year: 2026,
      month: 8,
      day: 28,
      category: 'Belanja Bulanan',
      meta: '15.20 · supermarket',
      amount: -450000,
      type: TransactionType.expense,
      icon: Icons.shopping_cart_outlined,
    ),

    // 07 Oktober 2026
    DashboardTransaction(
      id: 'tx-okt-1',
      dateStr: '07 Oktober 2026',
      dateKey: '2026-10-07',
      year: 2026,
      month: 9,
      day: 7,
      category: 'Makanan & Minuman',
      meta: '16.03 · kopi',
      amount: -14000,
      type: TransactionType.expense,
      icon: Icons.coffee_rounded,
    ),
    DashboardTransaction(
      id: 'tx-okt-2',
      dateStr: '07 Oktober 2026',
      dateKey: '2026-10-07',
      year: 2026,
      month: 9,
      day: 7,
      category: 'Transportasi',
      meta: '12.45 · bensin motor',
      amount: -35000,
      type: TransactionType.expense,
      icon: Icons.directions_bike_rounded,
    ),
    DashboardTransaction(
      id: 'tx-okt-3',
      dateStr: '07 Oktober 2026',
      dateKey: '2026-10-07',
      year: 2026,
      month: 9,
      day: 7,
      category: 'Gaji & Pendapatan',
      meta: '09.15 · bonus proyek freelance',
      amount: 1500000,
      type: TransactionType.income,
      icon: Icons.payments_outlined,
    ),
    DashboardTransaction(
      id: 'tx-okt-4',
      dateStr: '07 Oktober 2026',
      dateKey: '2026-10-07',
      year: 2026,
      month: 9,
      day: 7,
      category: 'Belanja',
      meta: '08.10 · kebutuhan sabun & detergen',
      amount: -68000,
      type: TransactionType.expense,
      icon: Icons.shopping_bag_outlined,
    ),

    // 06 Oktober 2026
    DashboardTransaction(
      id: 'tx-okt-5',
      dateStr: '06 Oktober 2026',
      dateKey: '2026-10-06',
      year: 2026,
      month: 9,
      day: 6,
      category: 'Makanan & Minuman',
      meta: '19.30 · makan malam nasi goreng',
      amount: -25000,
      type: TransactionType.expense,
      icon: Icons.restaurant_rounded,
    ),
    DashboardTransaction(
      id: 'tx-okt-6',
      dateStr: '06 Oktober 2026',
      dateKey: '2026-10-06',
      year: 2026,
      month: 9,
      day: 6,
      category: 'Tagihan & Pulsa',
      meta: '14.05 · paket internet bulanan',
      amount: -100000,
      type: TransactionType.expense,
      icon: Icons.wifi_rounded,
    ),
    DashboardTransaction(
      id: 'tx-okt-7',
      dateStr: '06 Oktober 2026',
      dateKey: '2026-10-06',
      year: 2026,
      month: 9,
      day: 6,
      category: 'Pemasukan Lain',
      meta: '10.00 · cashback belanja e-wallet',
      amount: 25000,
      type: TransactionType.income,
      icon: Icons.redeem_rounded,
    ),

    // 03 Oktober 2026
    DashboardTransaction(
      id: 'tx-okt-8',
      dateStr: '03 Oktober 2026',
      dateKey: '2026-10-03',
      year: 2026,
      month: 9,
      day: 3,
      category: 'Belanja Mart',
      meta: '11.20 · minimarket & camilan',
      amount: -84666,
      type: TransactionType.expense,
      icon: Icons.storefront_rounded,
    ),

    // 02 Oktober 2026
    DashboardTransaction(
      id: 'tx-okt-9',
      dateStr: '02 Oktober 2026',
      dateKey: '2026-10-02',
      year: 2026,
      month: 9,
      day: 2,
      category: 'Makanan & Minuman',
      meta: '07.45 · sarapan pagi bubur',
      amount: -35000,
      type: TransactionType.expense,
      icon: Icons.bakery_dining_rounded,
    ),
  ];

  static String formatCurrency(int amount, {bool showSign = false}) {
    final absVal = amount.abs().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );

    if (showSign) {
      if (amount >= 0) return '+Rp$absVal';
      return '-Rp$absVal';
    }

    final prefix = amount < 0 ? '-' : '';
    return '${prefix}Rp $absVal';
  }

  static int getMinTransactionYear(List<DashboardTransaction> transactions) {
    if (transactions.isEmpty) return 2026;
    return transactions.map((t) => t.year).reduce((a, b) => a < b ? a : b);
  }

  static int getMaxTransactionYear(List<DashboardTransaction> transactions) {
    if (transactions.isEmpty) return 2026;
    return transactions.map((t) => t.year).reduce((a, b) => a > b ? a : b);
  }
}
