import 'package:flutter/material.dart';
import '../../category/data/category_model.dart';
import '../../transaction/data/transaction_model.dart';
import 'report_data_model.dart';

/// Data kelas hasil kalkulasi metrik kesehatan finansial (REP-02)
class FinancialHealthMetrics {
  final double savingsRate;
  final int healthScore;
  final String healthStatus;
  final String healthRecommendation;

  const FinancialHealthMetrics({
    required this.savingsRate,
    required this.healthScore,
    required this.healthStatus,
    required this.healthRecommendation,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FinancialHealthMetrics &&
          runtimeType == other.runtimeType &&
          savingsRate == other.savingsRate &&
          healthScore == other.healthScore &&
          healthStatus == other.healthStatus &&
          healthRecommendation == other.healthRecommendation;

  @override
  int get hashCode =>
      savingsRate.hashCode ^
      healthScore.hashCode ^
      healthStatus.hashCode ^
      healthRecommendation.hashCode;

  @override
  String toString() =>
      'FinancialHealthMetrics(score: $healthScore, status: $healthStatus, savingsRate: $savingsRate%)';
}

/// Engine Kalkulator Skor Kesehatan Finansial (REP-02)
class FinancialHealthEngine {
  FinancialHealthEngine._();

  static const String recommendationSurplusTinggi =
      'Kondisi keuangan sangat prima. Pertahankan rasio tabungan dan alokasikan ke instrumen investasi.';
  static const String recommendationSurplusSehat =
      'Pengeluaran terkendali dengan baik. Anda menyisihkan lebih dari 20% pemasukan bulan ini.';
  static const String recommendationWaspada =
      'Arus kas tipis. Kurangi pos pengeluaran hiburan dan belanja harian untuk memperbesar dana darurat.';
  static const String recommendationDefisit =
      'Pengeluaran melebihi pemasukan bulan ini. Tinjau kembali anggaran belanja dan tunda pengeluaran non-primer.';
  static const String recommendationEmpty =
      'Belum ada transaksi tercatat pada bulan ini.';

  /// Menghitung metrik kesehatan finansial berdasarkan perbandingan arus kas:
  /// - Savings Rate: ((Total Pemasukan - Total Pengeluaran) / Total Pemasukan) * 100%
  /// - Skor (0 - 100)
  /// - Label Status ('Sangat Sehat', 'Sehat', 'Waspada', 'Kritis / Defisit', 'Belum Ada Data')
  /// - Rekomendasi finansial dinamis
  static FinancialHealthMetrics calculate({
    required int totalIncome,
    required int totalExpense,
  }) {
    // 1. Kondisi Kosong (Tidak ada transaksi)
    if (totalIncome == 0 && totalExpense == 0) {
      return const FinancialHealthMetrics(
        savingsRate: 0.0,
        healthScore: 0,
        healthStatus: 'Belum Ada Data',
        healthRecommendation: recommendationEmpty,
      );
    }

    final netCashflow = totalIncome - totalExpense;

    // 2. Kondisi Defisit Tanpa Pemasukan (Total Income 0, Expense > 0)
    if (totalIncome <= 0 && totalExpense > 0) {
      return const FinancialHealthMetrics(
        savingsRate: -100.0,
        healthScore: 35,
        healthStatus: 'Kritis / Defisit',
        healthRecommendation: recommendationDefisit,
      );
    }

    // 3. Kondisi Normal Berdasarkan Rasio Tabungan
    final double rawSavingsRate = (netCashflow / totalIncome) * 100;
    final double savingsRate = double.parse(rawSavingsRate.toStringAsFixed(1));

    if (savingsRate >= 40.0) {
      return FinancialHealthMetrics(
        savingsRate: savingsRate,
        healthScore: 95,
        healthStatus: 'Sangat Sehat',
        healthRecommendation: recommendationSurplusTinggi,
      );
    } else if (savingsRate >= 20.0) {
      return FinancialHealthMetrics(
        savingsRate: savingsRate,
        healthScore: 82,
        healthStatus: 'Sehat',
        healthRecommendation: recommendationSurplusSehat,
      );
    } else if (savingsRate >= 0.0) {
      return FinancialHealthMetrics(
        savingsRate: savingsRate,
        healthScore: 65,
        healthStatus: 'Waspada',
        healthRecommendation: recommendationWaspada,
      );
    } else {
      return FinancialHealthMetrics(
        savingsRate: savingsRate,
        healthScore: 35,
        healthStatus: 'Kritis / Defisit',
        healthRecommendation: recommendationDefisit,
      );
    }
  }
}

/// Generator Tren Arus Kas Harian (REP-03)
class DailyTrendGenerator {
  DailyTrendGenerator._();

  static const List<String> monthsShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  /// Mengelompokkan transaksi bulanan berdasarkan hari (1..31)
  /// dan mengurutkannya secara kronologis menaik (ASC).
  static List<ReportDailyTrendItem> generate({
    required List<TransactionModel> transactions,
    required int monthIndex,
  }) {
    if (transactions.isEmpty) return const [];

    final safeMonthIndex = monthIndex.clamp(0, monthsShort.length - 1);
    final monthLabel = monthsShort[safeMonthIndex];

    final Map<int, ({int expense, int income})> dailyAggregates = {};

    for (final tx in transactions) {
      final day = tx.day > 0 ? tx.day : tx.date.day;
      final current = dailyAggregates[day] ?? (expense: 0, income: 0);
      final amount = tx.amount.abs();

      if (tx.isExpense) {
        dailyAggregates[day] = (
          expense: current.expense + amount,
          income: current.income,
        );
      } else {
        dailyAggregates[day] = (
          expense: current.expense,
          income: current.income + amount,
        );
      }
    }

    final sortedDays = dailyAggregates.keys.toList()..sort();

    return sortedDays.map((d) {
      final dayStr = d.toString().padLeft(2, '0');
      final entry = dailyAggregates[d]!;
      return ReportDailyTrendItem(
        dayStr: dayStr,
        fullDateStr: '$dayStr $monthLabel',
        expense: entry.expense,
        income: entry.income,
      );
    }).toList();
  }
}

/// Generator Proporsi & Persentase Kategori Donut Chart (REP-04)
class CategoryProportionGenerator {
  CategoryProportionGenerator._();

  static const List<Color> expenseSlicePalette = [
    Color(0xFFDC2626), // Merah gelap
    Color(0xFFEF4444), // Merah standar
    Color(0xFFF87171), // Merah sedang
    Color(0xFFFCA5A5), // Merah pastel
    Color(0xFFB91C1C), // Merah marun
    Color(0xFF991B1B), // Merah tua
  ];

  static const List<Color> incomeSlicePalette = [
    Color(0xFF15803D), // Hijau emerald tua
    Color(0xFF16A34A), // Hijau daun
    Color(0xFF22C55E), // Hijau terang
    Color(0xFF4ADE80), // Hijau mint muda
    Color(0xFF86EFAC), // Hijau pastel
    Color(0xFF166534), // Hijau pekat
  ];

  /// Menghitung persentase kontribusi per kategori, mengurutkan dari nominal terbesar,
  /// serta memetakan palet warna harmonis dan ikon dari subkoleksi `categories`.
  static List<ReportCategoryItem> generate({
    required List<TransactionModel> transactions,
    required bool isExpense,
    int? totalAmount,
    Map<String, CategoryItem>? categoryLookup,
  }) {
    final filtered = transactions.where((t) => t.isExpense == isExpense).toList();
    if (filtered.isEmpty) return const [];

    final Map<String, ({String id, String name, int amount, int count, int iconCode, int color})> catGroupMap = {};

    for (final tx in filtered) {
      final key = tx.categoryId.isNotEmpty ? tx.categoryId : tx.categoryName;
      final current = catGroupMap[key];
      final amount = tx.amount.abs();

      // Lookup data kategori riil jika tersedia
      final matchedCategory = categoryLookup != null
          ? (categoryLookup[tx.categoryId] ?? categoryLookup[tx.categoryName])
          : null;

      final name = matchedCategory?.name ??
          (tx.categoryName.isNotEmpty ? tx.categoryName : 'Lainnya');
      final iconCode = matchedCategory?.icon.codePoint ??
          (tx.categoryIconCode != 0
              ? tx.categoryIconCode
              : (isExpense
                  ? Icons.restaurant_rounded.codePoint
                  : Icons.payments_rounded.codePoint));
      final color = matchedCategory != null
          ? matchedCategory.color.toARGB32()
          : (isExpense ? 0xFFDC2626 : 0xFF16A34A);

      if (current != null) {
        catGroupMap[key] = (
          id: key,
          name: name,
          amount: current.amount + amount,
          count: current.count + 1,
          iconCode: iconCode,
          color: color,
        );
      } else {
        catGroupMap[key] = (
          id: key,
          name: name,
          amount: amount,
          count: 1,
          iconCode: iconCode,
          color: color,
        );
      }
    }

    final int effectiveTotal = (totalAmount != null && totalAmount > 0)
        ? totalAmount
        : catGroupMap.values.fold<int>(0, (sum, item) => sum + item.amount);

    if (effectiveTotal <= 0) return const [];

    // Urutkan berdasarkan nominal terbesar ke terkecil
    final sortedCategories = catGroupMap.values.toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    final slicePalette = isExpense ? expenseSlicePalette : incomeSlicePalette;

    return sortedCategories.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;

      final pct = (item.amount / effectiveTotal) * 100;
      final double percentage = double.parse(pct.toStringAsFixed(1));
      final Color sliceColor = slicePalette[index % slicePalette.length];

      return ReportCategoryItem(
        name: item.name,
        percentage: percentage,
        amount: item.amount,
        // ignore: non_const_argument_for_const_parameter
        icon: IconData(item.iconCode, fontFamily: 'MaterialIcons'),
        iconColor: isExpense ? const Color(0xFFBA1A1A) : const Color(0xFF15803D),
        containerColor: isExpense ? const Color(0xFFFFDAD6) : const Color(0xFFDCFCE7),
        badgeTextColor: isExpense ? const Color(0xFF93000A) : const Color(0xFF006329),
        sliceColor: sliceColor,
      );
    }).toList();
  }
}
