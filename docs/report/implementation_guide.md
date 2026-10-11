# 🛠️ Panduan Implementasi Teknis: Fitur Laporan (Reports)

Dokumen ini memandu langkah-demi-langkah implementasi kode Flutter untuk mengintegrasikan **Fitur Laporan Keuangan & Analisis Finansial** dengan data riil dari **Cloud Firestore SDK**.

---

## 🎯 Target Implementasi
1. Membuat domain model komprehensif `MonthlyReportData`.
2. Membuat service layer `ReportRepository` yang mengagregasi data transaksi bulanan, menghitung tren harian, persentase kategori, dan metrik kesehatan finansial.
3. Menghubungkan antarmuka [`ReportScreen`](file:///Users/heru/Development/TrackFinance/frontend/lib/features/report/presentation/screens/report_screen.dart) dengan `ReportRepository` agar seluruh grafik dan kartu bersifat dinamis sesuai bulan yang dipilih.
4. Menghubungkan modal pemilih bulan [`ReportMonthPickerModal`](file:///Users/heru/Development/TrackFinance/frontend/lib/features/report/presentation/widgets/report_month_picker_modal.dart) dengan kueri data baru.

---

## 📂 Langkah 1: Buat Model `MonthlyReportData`

Buat file baru di [frontend/lib/features/report/data/monthly_report_model.dart](file:///Users/heru/Development/TrackFinance/frontend/lib/features/report/data/monthly_report_model.dart):

```dart
import 'report_data_model.dart';

class MonthlyReportData {
  final String monthKey; // 'YYYY-MM'
  final int year;
  final int monthIndex; // 0-based: 0 = Jan, 9 = Okt
  final int totalIncome;
  final int totalExpense;
  final int netCashflow;
  final double savingsRate;
  final int healthScore;
  final String healthStatus;
  final String healthRecommendation;
  final List<ReportDailyTrendItem> dailyTrends;
  final List<ReportCategoryItem> expenseCategories;
  final List<ReportCategoryItem> incomeCategories;

  const MonthlyReportData({
    required this.monthKey,
    required this.year,
    required this.monthIndex,
    required this.totalIncome,
    required this.totalExpense,
    required this.netCashflow,
    required this.savingsRate,
    required this.healthScore,
    required this.healthStatus,
    required this.healthRecommendation,
    required this.dailyTrends,
    required this.expenseCategories,
    required this.incomeCategories,
  });

  bool get isEmpty => totalIncome == 0 && totalExpense == 0;

  // Nilai default untuk bulan kosong (Empty State)
  factory MonthlyReportData.empty(int year, int monthIndex) {
    final monthKey = '$year-${(monthIndex + 1).toString().padLeft(2, '0')}';
    return MonthlyReportData(
      monthKey: monthKey,
      year: year,
      monthIndex: monthIndex,
      totalIncome: 0,
      totalExpense: 0,
      netCashflow: 0,
      savingsRate: 0.0,
      healthScore: 0,
      healthStatus: 'Belum Ada Data',
      healthRecommendation: 'Belum ada transaksi tercatat pada bulan ini.',
      dailyTrends: const [],
      expenseCategories: const [],
      incomeCategories: const [],
    );
  }
}
```

---

## 📂 Langkah 2: Buat `ReportRepository`

Buat file baru di [frontend/lib/features/report/data/report_repository.dart](file:///Users/heru/Development/TrackFinance/frontend/lib/features/report/data/report_repository.dart):

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'monthly_report_model.dart';
import 'report_data_model.dart';

class ReportRepository {
  final FirebaseFirestore _firestore;

  ReportRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static final ReportRepository instance = ReportRepository();

  static const List<String> _monthsShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];

  /// Mengambil data laporan bulanan lengkap
  Future<MonthlyReportData> getMonthlyReport(
    String uid, {
    required int year,
    required int monthIndex,
  }) async {
    final monthKey = '$year-${(monthIndex + 1).toString().padLeft(2, '0')}';

    // 1. Ambil seluruh transaksi pada bulan tersebut
    final txSnapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .where('monthKey', isEqualTo: monthKey)
        .orderBy('date', descending: false)
        .get();

    if (txSnapshot.docs.isEmpty) {
      return MonthlyReportData.empty(year, monthIndex);
    }

    int totalIncome = 0;
    int totalExpense = 0;

    // Pemetaan Harian (Hari 1 s/d 31)
    final Map<int, ({int expense, int income})> dailyAggregates = {};

    // Pemetaan Kategori
    final Map<String, ({String name, int amount, int count, int iconCode, int color})> expenseCatMap = {};
    final Map<String, ({String name, int amount, int count, int iconCode, int color})> incomeCatMap = {};

    for (final doc in txSnapshot.docs) {
      final data = doc.data();
      final isExp = (data['type'] as String? ?? 'expense') == 'expense';
      final amount = (data['amount'] as num? ?? 0).toInt();
      final day = data['day'] as int? ?? 1;
      final catName = data['categoryName'] as String? ?? 'Lainnya';
      final iconCode = data['categoryIconCode'] as int? ?? Icons.category_rounded.codePoint;
      final color = data['categoryColor'] as int? ?? 0xFF2563EB;

      // Akumulasi total
      if (isExp) {
        totalExpense += amount;
      } else {
        totalIncome += amount;
      }

      // Akumulasi harian
      final currentDaily = dailyAggregates[day] ?? (expense: 0, income: 0);
      dailyAggregates[day] = (
        expense: currentDaily.expense + (isExp ? amount : 0),
        income: currentDaily.income + (!isExp ? amount : 0),
      );

      // Akumulasi per kategori
      final targetMap = isExp ? expenseCatMap : incomeCatMap;
      final currentCat = targetMap[catName];
      if (currentCat != null) {
        targetMap[catName] = (
          name: catName,
          amount: currentCat.amount + amount,
          count: currentCat.count + 1,
          iconCode: iconCode,
          color: color,
        );
      } else {
        targetMap[catName] = (
          name: catName,
          amount: amount,
          count: 1,
          iconCode: iconCode,
          color: color,
        );
      }
    }

    // 2. Susun Daily Trend Items
    final monthLabel = _monthsShort[monthIndex];
    final sortedDays = dailyAggregates.keys.toList()..sort();
    final List<ReportDailyTrendItem> dailyTrends = sortedDays.map((d) {
      final dayStr = d.toString().padLeft(2, '0');
      return ReportDailyTrendItem(
        dayStr: dayStr,
        fullDateStr: '$dayStr $monthLabel',
        expense: dailyAggregates[d]!.expense,
        income: dailyAggregates[d]!.income,
      );
    }).toList();

    // 3. Susun Category Items (Persentase & Palet Warna)
    List<ReportCategoryItem> buildCategoryList(
      Map<String, ({String name, int amount, int count, int iconCode, int color})> map,
      int total,
      bool isExpense,
    ) {
      if (total <= 0) return [];
      final sortedEntries = map.values.toList()..sort((a, b) => b.amount.compareTo(a.amount));
      
      final colorSlices = isExpense
          ? [const Color(0xFFDC2626), const Color(0xFFEF4444), const Color(0xFFF87171), const Color(0xFFFCA5A5)]
          : [const Color(0xFF16A34A), const Color(0xFF22C55E), const Color(0xFF4ADE80), const Color(0xFF86EFAC)];

      return sortedEntries.asMap().entries.map((entry) {
        final i = entry.key;
        final item = entry.value;
        final pct = (item.amount / total) * 100;
        final sliceColor = colorSlices[i % colorSlices.length];

        return ReportCategoryItem(
          name: item.name,
          percentage: double.parse(pct.toStringAsFixed(1)),
          amount: item.amount,
          icon: IconData(item.iconCode, fontFamily: 'MaterialIcons'),
          iconColor: isExpense ? const Color(0xFFBA1A1A) : const Color(0xFF16A34A),
          containerColor: isExpense ? const Color(0xFFFFDAD6) : const Color(0xFFDCFCE7),
          badgeTextColor: isExpense ? const Color(0xFF93000A) : const Color(0xFF15803D),
          sliceColor: sliceColor,
        );
      }).toList();
    }

    final expenseCategories = buildCategoryList(expenseCatMap, totalExpense, true);
    final incomeCategories = buildCategoryList(incomeCatMap, totalIncome, false);

    // 4. Hitung Metrik Kesehatan Finansial
    final netCashflow = totalIncome - totalExpense;
    final double savingsRate = totalIncome > 0
        ? double.parse(((netCashflow / totalIncome) * 100).toStringAsFixed(1))
        : 0.0;

    int healthScore = 75;
    String healthStatus = 'Sehat';
    String recommendation = 'Kondisi keuangan terkendali dengan baik.';

    if (totalIncome > 0) {
      if (savingsRate >= 40) {
        healthScore = 95;
        healthStatus = 'Sangat Sehat';
        recommendation = 'Kondisi keuangan sangat prima. Pertahankan rasio tabungan dan alokasikan ke investasi.';
      } else if (savingsRate >= 20) {
        healthScore = 82;
        healthStatus = 'Sehat';
        recommendation = 'Pengeluaran terkendali. Anda menyisihkan lebih dari 20% pemasukan bulan ini.';
      } else if (savingsRate >= 0) {
        healthScore = 65;
        healthStatus = 'Waspada';
        recommendation = 'Arus kas tipis. Kurangi pengeluaran sekunder untuk memperbesar alokasi tabungan.';
      } else {
        healthScore = 35;
        healthStatus = 'Kritis / Defisit';
        recommendation = 'Pengeluaran melebihi pemasukan bulan ini! Evaluasi pos pengeluaran terbesar Anda.';
      }
    }

    return MonthlyReportData(
      monthKey: monthKey,
      year: year,
      monthIndex: monthIndex,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netCashflow: netCashflow,
      savingsRate: savingsRate,
      healthScore: healthScore,
      healthStatus: healthStatus,
      healthRecommendation: recommendation,
      dailyTrends: dailyTrends,
      expenseCategories: expenseCategories,
      incomeCategories: incomeCategories,
    );
  }
}
```

---

## 📂 Langkah 3: Integrasi ke `ReportScreen`

Di file [frontend/lib/features/report/presentation/screens/report_screen.dart](file:///Users/heru/Development/TrackFinance/frontend/lib/features/report/presentation/screens/report_screen.dart):

1. **State & Load Data dari Repository**:
```dart
MonthlyReportData? _reportData;

Future<void> _loadReportData() async {
  final uid = widget.user?.uid;
  if (uid == null) return;

  setState(() => _isLoading = true);

  final data = await ReportRepository.instance.getMonthlyReport(
    uid,
    year: _currentYear,
    monthIndex: _currentMonthIndex,
  );

  if (mounted) {
    setState(() {
      _reportData = data;
      _isLoading = false;
    });
    _fadeController.forward(from: 0.0);
  }
}

@override
void initState() {
  super.initState();
  _loadReportData();
}
```

2. **Perbarui Pemilihan Bulan di `ReportMonthPickerModal`**:
```dart
void _openMonthPickerModal() {
  ReportMonthPickerModal.show(
    context,
    initialYear: _currentYear,
    initialMonthIndex: _currentMonthIndex,
    onApply: (year, monthIndex) {
      setState(() {
        _currentYear = year;
        _currentMonthIndex = monthIndex;
      });
      _loadReportData(); // Kueri data laporan untuk bulan baru
    },
  );
}
```

3. **Pasok Data Dinamis ke Kartu UI**:
```dart
// Kartu Kesehatan Finansial
ReportHealthCard(
  isExpenseMode: _isExpenseMode,
  score: _reportData?.healthScore ?? 85,
  incomeTotal: _reportData?.totalIncome ?? 0,
  expenseTotal: _reportData?.totalExpense ?? 0,
  recommendation: _reportData?.healthRecommendation,
)

// Kartu Tren Harian
ReportTrendCard(
  isExpenseMode: _isExpenseMode,
  dailyTrends: _reportData?.dailyTrends ?? [],
)

// Kartu Struktur Donut Kategori
ReportStructureCard(
  isExpenseMode: _isExpenseMode,
  totalAmount: _isExpenseMode
      ? (_reportData?.totalExpense ?? 0)
      : (_reportData?.totalIncome ?? 0),
  categories: _isExpenseMode
      ? (_reportData?.expenseCategories ?? [])
      : (_reportData?.incomeCategories ?? []),
)
```

---

## 🧪 Langkah 4: Pengujian & Validasi

Jalankan test suite untuk memvalidasi engine analitik laporan:
```bash
cd frontend
flutter test
```
Pastikan pemilihan bulan yang berbeda menampilkan visualisasi yang akurat sesuai riwayat transaksi yang tersimpan di Cloud Firestore.
