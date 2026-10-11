import 'package:flutter/foundation.dart';
import 'report_data_model.dart';

/// Model komprehensif data laporan bulanan (Domain Model Analisis Laporan - REP-01)
class MonthlyReportData {
  final String monthKey; // Format: 'YYYY-MM' (contoh: '2026-10')
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

  /// Mengembalikan true bila tidak ada aktivitas arus kas pada bulan ini
  bool get isEmpty => totalIncome == 0 && totalExpense == 0;

  /// Helper getter apakah terjadi surplus (arus kas positif)
  bool get isSurplus => netCashflow > 0;

  /// Helper getter apakah terjadi defisit (pengeluaran > pemasukan)
  bool get isDeficit => netCashflow < 0;

  /// Nilai default untuk bulan kosong (Empty State)
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

  MonthlyReportData copyWith({
    String? monthKey,
    int? year,
    int? monthIndex,
    int? totalIncome,
    int? totalExpense,
    int? netCashflow,
    double? savingsRate,
    int? healthScore,
    String? healthStatus,
    String? healthRecommendation,
    List<ReportDailyTrendItem>? dailyTrends,
    List<ReportCategoryItem>? expenseCategories,
    List<ReportCategoryItem>? incomeCategories,
  }) {
    return MonthlyReportData(
      monthKey: monthKey ?? this.monthKey,
      year: year ?? this.year,
      monthIndex: monthIndex ?? this.monthIndex,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      netCashflow: netCashflow ?? this.netCashflow,
      savingsRate: savingsRate ?? this.savingsRate,
      healthScore: healthScore ?? this.healthScore,
      healthStatus: healthStatus ?? this.healthStatus,
      healthRecommendation: healthRecommendation ?? this.healthRecommendation,
      dailyTrends: dailyTrends ?? this.dailyTrends,
      expenseCategories: expenseCategories ?? this.expenseCategories,
      incomeCategories: incomeCategories ?? this.incomeCategories,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthlyReportData &&
          runtimeType == other.runtimeType &&
          monthKey == other.monthKey &&
          year == other.year &&
          monthIndex == other.monthIndex &&
          totalIncome == other.totalIncome &&
          totalExpense == other.totalExpense &&
          netCashflow == other.netCashflow &&
          savingsRate == other.savingsRate &&
          healthScore == other.healthScore &&
          healthStatus == other.healthStatus &&
          healthRecommendation == other.healthRecommendation &&
          listEquals(dailyTrends, other.dailyTrends) &&
          listEquals(expenseCategories, other.expenseCategories) &&
          listEquals(incomeCategories, other.incomeCategories);

  @override
  int get hashCode =>
      monthKey.hashCode ^
      year.hashCode ^
      monthIndex.hashCode ^
      totalIncome.hashCode ^
      totalExpense.hashCode ^
      netCashflow.hashCode ^
      savingsRate.hashCode ^
      healthScore.hashCode ^
      healthStatus.hashCode ^
      healthRecommendation.hashCode;

  @override
  String toString() {
    return 'MonthlyReportData(monthKey: $monthKey, income: $totalIncome, expense: $totalExpense, net: $netCashflow, score: $healthScore, status: $healthStatus)';
  }
}
