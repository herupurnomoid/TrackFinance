import 'package:cloud_firestore/cloud_firestore.dart';
import '../../category/data/category_model.dart';
import '../../transaction/data/monthly_summary_model.dart';
import '../../transaction/data/transaction_model.dart';
import 'monthly_report_model.dart';
import 'report_analysis_engine.dart';

/// Repository Service untuk Analisis dan Laporan Keuangan Bulanan (REP-05)
class ReportRepository {
  final FirebaseFirestore _firestore;

  ReportRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static final ReportRepository instance = ReportRepository();

  /// Mengambil data laporan bulanan lengkap
  ///
  /// Menggabungkan:
  /// 1. Pembacaan dokumen agregasi `users/{uid}/monthly_summaries/{monthKey}`
  /// 2. Kueri detail riwayat transaksi `users/{uid}/transactions` where monthKey == monthKey
  /// 3. Subkoleksi `users/{uid}/categories` untuk pemetaan warna & ikon
  ///
  /// Mendukung pemanggilan fleksibel via `monthKey` (misal '2026-10')
  /// atau kombinasi `year` dan `monthIndex` (0-based: 0 = Jan, 9 = Okt).
  Future<MonthlyReportData> getMonthlyReport(
    String uid, {
    String? monthKey,
    int? year,
    int? monthIndex,
  }) async {
    final trimmedUid = uid.trim();

    // 1. Normalisasi parameter year, monthIndex, dan monthKey
    int effectiveYear = year ?? 0;
    int effectiveMonthIndex = monthIndex ?? 0;
    String effectiveMonthKey = monthKey?.trim() ?? '';

    if (effectiveMonthKey.isNotEmpty && (effectiveYear == 0 || monthIndex == null)) {
      final parts = effectiveMonthKey.split('-');
      if (parts.length >= 2) {
        effectiveYear = int.tryParse(parts[0]) ?? DateTime.now().year;
        final m = int.tryParse(parts[1]) ?? DateTime.now().month;
        effectiveMonthIndex = (m - 1).clamp(0, 11);
      }
    } else if (effectiveYear != 0 && monthIndex != null) {
      effectiveMonthKey =
          '$effectiveYear-${(effectiveMonthIndex + 1).toString().padLeft(2, '0')}';
    } else {
      final now = DateTime.now();
      effectiveYear = now.year;
      effectiveMonthIndex = now.month - 1;
      effectiveMonthKey =
          '$effectiveYear-${now.month.toString().padLeft(2, '0')}';
    }

    if (trimmedUid.isEmpty) {
      return MonthlyReportData.empty(effectiveYear, effectiveMonthIndex);
    }

    // 2. Eksekusi pembacaan dokumen secara paralel
    final summaryRef = _firestore
        .collection('users')
        .doc(trimmedUid)
        .collection('monthly_summaries')
        .doc(effectiveMonthKey);

    final categoriesRef = _firestore
        .collection('users')
        .doc(trimmedUid)
        .collection('categories');

    // Kueri transaksi dengan fallback jika indeks komposit belum terpasang
    Future<QuerySnapshot<Map<String, dynamic>>?> fetchTransactions() async {
      try {
        return await _firestore
            .collection('users')
            .doc(trimmedUid)
            .collection('transactions')
            .where('monthKey', isEqualTo: effectiveMonthKey)
            .orderBy('date', descending: false)
            .get();
      } catch (_) {
        try {
          return await _firestore
              .collection('users')
              .doc(trimmedUid)
              .collection('transactions')
              .where('monthKey', isEqualTo: effectiveMonthKey)
              .get();
        } catch (_) {
          return null;
        }
      }
    }

    final results = await Future.wait([
      summaryRef.get().catchError((_) => null as dynamic),
      fetchTransactions(),
      categoriesRef.get().catchError((_) => null as dynamic),
    ]);

    final summaryDoc = results[0] as DocumentSnapshot<Map<String, dynamic>>?;
    final txSnapshot = results[1] as QuerySnapshot<Map<String, dynamic>>?;
    final catSnapshot = results[2] as QuerySnapshot<Map<String, dynamic>>?;

    // 3. Bangun categoryLookup dari subkoleksi categories
    final Map<String, CategoryItem> categoryLookup = {};
    if (catSnapshot != null && catSnapshot.docs.isNotEmpty) {
      for (final doc in catSnapshot.docs) {
        try {
          final cat = CategoryItem.fromFirestore(doc);
          categoryLookup[cat.id] = cat;
          if (cat.name.isNotEmpty) {
            categoryLookup[cat.name] = cat;
          }
        } catch (_) {}
      }
    }

    // 4. Parse daftar dokumen transaksi
    final txDocs = txSnapshot?.docs ?? [];
    final transactions = txDocs
        .map((d) {
          try {
            return TransactionModel.fromFirestore(d);
          } catch (_) {
            return null;
          }
        })
        .whereType<TransactionModel>()
        .toList();

    // 5. Evaluasi Dokumen Ringkasan Bulanan (monthly_summaries)
    MonthlySummaryModel? summaryModel;
    if (summaryDoc != null && summaryDoc.exists && summaryDoc.data() != null) {
      try {
        summaryModel = MonthlySummaryModel.fromFirestore(summaryDoc);
      } catch (_) {}
    }

    // 6. Tangani Kondisi Bulan Kosong
    if (transactions.isEmpty) {
      if (summaryModel != null &&
          (summaryModel.totalIncome > 0 || summaryModel.totalExpense > 0)) {
        final healthMetrics = FinancialHealthEngine.calculate(
          totalIncome: summaryModel.totalIncome,
          totalExpense: summaryModel.totalExpense,
        );
        return MonthlyReportData(
          monthKey: effectiveMonthKey,
          year: effectiveYear,
          monthIndex: effectiveMonthIndex,
          totalIncome: summaryModel.totalIncome,
          totalExpense: summaryModel.totalExpense,
          netCashflow: summaryModel.netCashflow,
          savingsRate: healthMetrics.savingsRate,
          healthScore: healthMetrics.healthScore,
          healthStatus: healthMetrics.healthStatus,
          healthRecommendation: healthMetrics.healthRecommendation,
          dailyTrends: const [],
          expenseCategories: const [],
          incomeCategories: const [],
        );
      }
      return MonthlyReportData.empty(effectiveYear, effectiveMonthIndex);
    }

    // 7. Hitung Total Akumulasi Transaksi
    int totalIncome = 0;
    int totalExpense = 0;

    for (final tx in transactions) {
      if (tx.isExpense) {
        totalExpense += tx.amount.abs();
      } else {
        totalIncome += tx.amount.abs();
      }
    }

    // Sinkronkan dengan data summaryModel jika tersedia
    if (summaryModel != null && (totalIncome == 0 && totalExpense == 0)) {
      totalIncome = summaryModel.totalIncome;
      totalExpense = summaryModel.totalExpense;
    }

    final int netCashflow = totalIncome - totalExpense;

    // 8. Susun Tren Harian (REP-03)
    final dailyTrends = DailyTrendGenerator.generate(
      transactions: transactions,
      monthIndex: effectiveMonthIndex,
    );

    // 9. Susun Proporsi Kategori Pengeluaran & Pemasukan (REP-04)
    final expenseCategories = CategoryProportionGenerator.generate(
      transactions: transactions,
      isExpense: true,
      totalAmount: totalExpense,
      categoryLookup: categoryLookup,
    );

    final incomeCategories = CategoryProportionGenerator.generate(
      transactions: transactions,
      isExpense: false,
      totalAmount: totalIncome,
      categoryLookup: categoryLookup,
    );

    // 10. Hitung Metrik Kesehatan Finansial (REP-02)
    final healthMetrics = FinancialHealthEngine.calculate(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
    );

    return MonthlyReportData(
      monthKey: effectiveMonthKey,
      year: effectiveYear,
      monthIndex: effectiveMonthIndex,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netCashflow: netCashflow,
      savingsRate: healthMetrics.savingsRate,
      healthScore: healthMetrics.healthScore,
      healthStatus: healthMetrics.healthStatus,
      healthRecommendation: healthMetrics.healthRecommendation,
      dailyTrends: dailyTrends,
      expenseCategories: expenseCategories,
      incomeCategories: incomeCategories,
    );
  }

  /// Convenience method untuk mengambil laporan berdasarkan `monthKey` string ('YYYY-MM')
  Future<MonthlyReportData> getMonthlyReportByKey(
    String uid,
    String monthKey,
  ) {
    return getMonthlyReport(uid, monthKey: monthKey);
  }

  /// Stream realtime untuk memantau pembaruan laporan bulanan (REP-06)
  Stream<MonthlyReportData> watchMonthlyReport(
    String uid,
    String monthKey,
  ) {
    final trimmedUid = uid.trim();
    final effectiveMonthKey = monthKey.trim();

    int effectiveYear = DateTime.now().year;
    int effectiveMonthIndex = DateTime.now().month - 1;
    if (effectiveMonthKey.contains('-')) {
      final parts = effectiveMonthKey.split('-');
      if (parts.length >= 2) {
        effectiveYear = int.tryParse(parts[0]) ?? effectiveYear;
        final m = int.tryParse(parts[1]) ?? (effectiveMonthIndex + 1);
        effectiveMonthIndex = (m - 1).clamp(0, 11);
      }
    }

    if (trimmedUid.isEmpty) {
      return Stream.value(
        MonthlyReportData.empty(effectiveYear, effectiveMonthIndex),
      );
    }

    final txStream = _firestore
        .collection('users')
        .doc(trimmedUid)
        .collection('transactions')
        .where('monthKey', isEqualTo: effectiveMonthKey)
        .snapshots();

    return txStream.asyncMap((snapshot) async {
      final transactions = snapshot.docs
          .map((d) {
            try {
              return TransactionModel.fromFirestore(d);
            } catch (_) {
              return null;
            }
          })
          .whereType<TransactionModel>()
          .toList();

      Map<String, CategoryItem> categoryLookup = {};
      try {
        final catSnap = await _firestore
            .collection('users')
            .doc(trimmedUid)
            .collection('categories')
            .get();
        for (final doc in catSnap.docs) {
          try {
            final cat = CategoryItem.fromFirestore(doc);
            categoryLookup[cat.id] = cat;
            if (cat.name.isNotEmpty) {
              categoryLookup[cat.name] = cat;
            }
          } catch (_) {}
        }
      } catch (_) {}

      if (transactions.isEmpty) {
        try {
          final summaryDoc = await _firestore
              .collection('users')
              .doc(trimmedUid)
              .collection('monthly_summaries')
              .doc(effectiveMonthKey)
              .get();
          if (summaryDoc.exists && summaryDoc.data() != null) {
            final summary = MonthlySummaryModel.fromFirestore(summaryDoc);
            if (summary.totalIncome > 0 || summary.totalExpense > 0) {
              final metrics = FinancialHealthEngine.calculate(
                totalIncome: summary.totalIncome,
                totalExpense: summary.totalExpense,
              );
              return MonthlyReportData(
                monthKey: effectiveMonthKey,
                year: effectiveYear,
                monthIndex: effectiveMonthIndex,
                totalIncome: summary.totalIncome,
                totalExpense: summary.totalExpense,
                netCashflow: summary.netCashflow,
                savingsRate: metrics.savingsRate,
                healthScore: metrics.healthScore,
                healthStatus: metrics.healthStatus,
                healthRecommendation: metrics.healthRecommendation,
                dailyTrends: const [],
                expenseCategories: const [],
                incomeCategories: const [],
              );
            }
          }
        } catch (_) {}
        return MonthlyReportData.empty(effectiveYear, effectiveMonthIndex);
      }

      int totalIncome = 0;
      int totalExpense = 0;
      for (final tx in transactions) {
        if (tx.isExpense) {
          totalExpense += tx.amount.abs();
        } else {
          totalIncome += tx.amount.abs();
        }
      }

      final netCashflow = totalIncome - totalExpense;
      final dailyTrends = DailyTrendGenerator.generate(
        transactions: transactions,
        monthIndex: effectiveMonthIndex,
      );
      final expenseCategories = CategoryProportionGenerator.generate(
        transactions: transactions,
        isExpense: true,
        totalAmount: totalExpense,
        categoryLookup: categoryLookup,
      );
      final incomeCategories = CategoryProportionGenerator.generate(
        transactions: transactions,
        isExpense: false,
        totalAmount: totalIncome,
        categoryLookup: categoryLookup,
      );
      final healthMetrics = FinancialHealthEngine.calculate(
        totalIncome: totalIncome,
        totalExpense: totalExpense,
      );

      return MonthlyReportData(
        monthKey: effectiveMonthKey,
        year: effectiveYear,
        monthIndex: effectiveMonthIndex,
        totalIncome: totalIncome,
        totalExpense: totalExpense,
        netCashflow: netCashflow,
        savingsRate: healthMetrics.savingsRate,
        healthScore: healthMetrics.healthScore,
        healthStatus: healthMetrics.healthStatus,
        healthRecommendation: healthMetrics.healthRecommendation,
        dailyTrends: dailyTrends,
        expenseCategories: expenseCategories,
        incomeCategories: incomeCategories,
      );
    });
  }

  /// Convenience stream untuk memantau berdasarkan periode tahun & index bulan
  Stream<MonthlyReportData> watchMonthlyReportByPeriod(
    String uid, {
    required int year,
    required int monthIndex,
  }) {
    final monthKey = '$year-${(monthIndex + 1).toString().padLeft(2, '0')}';
    return watchMonthlyReport(uid, monthKey);
  }
}
