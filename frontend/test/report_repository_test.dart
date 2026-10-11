import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_finance/features/category/data/category_model.dart';
import 'package:track_finance/features/report/data/monthly_report_model.dart';
import 'package:track_finance/features/report/data/report_analysis_engine.dart';
import 'package:track_finance/features/report/data/report_data_model.dart';
import 'package:track_finance/features/report/data/report_repository.dart';
import 'package:track_finance/features/report/presentation/widgets/report_health_card.dart';
import 'package:track_finance/features/report/presentation/widgets/report_structure_card.dart';
import 'package:track_finance/features/report/presentation/widgets/report_trend_card.dart';
import 'package:track_finance/features/transaction/data/monthly_summary_model.dart';
import 'package:track_finance/features/transaction/data/transaction_model.dart';

void main() {
  group('REP-01: MonthlyReportData Domain Model Tests', () {
    test('MonthlyReportData.empty creates valid empty state model', () {
      final emptyReport = MonthlyReportData.empty(2026, 9); // Oktober 2026

      expect(emptyReport.monthKey, equals('2026-10'));
      expect(emptyReport.year, equals(2026));
      expect(emptyReport.monthIndex, equals(9));
      expect(emptyReport.totalIncome, equals(0));
      expect(emptyReport.totalExpense, equals(0));
      expect(emptyReport.netCashflow, equals(0));
      expect(emptyReport.savingsRate, equals(0.0));
      expect(emptyReport.healthScore, equals(0));
      expect(emptyReport.healthStatus, equals('Belum Ada Data'));
      expect(emptyReport.isEmpty, isTrue);
      expect(emptyReport.isSurplus, isFalse);
      expect(emptyReport.isDeficit, isFalse);
      expect(emptyReport.dailyTrends, isEmpty);
      expect(emptyReport.expenseCategories, isEmpty);
      expect(emptyReport.incomeCategories, isEmpty);
    });

    test('MonthlyReportData handles populated data and surplus/deficit helpers', () {
      const surplusReport = MonthlyReportData(
        monthKey: '2026-10',
        year: 2026,
        monthIndex: 9,
        totalIncome: 5000000,
        totalExpense: 2000000,
        netCashflow: 3000000,
        savingsRate: 60.0,
        healthScore: 95,
        healthStatus: 'Sangat Sehat',
        healthRecommendation: 'Pertahankan rasio tabungan.',
        dailyTrends: [],
        expenseCategories: [],
        incomeCategories: [],
      );

      expect(surplusReport.isEmpty, isFalse);
      expect(surplusReport.isSurplus, isTrue);
      expect(surplusReport.isDeficit, isFalse);

      final deficitReport = surplusReport.copyWith(
        totalIncome: 1000000,
        totalExpense: 3000000,
        netCashflow: -2000000,
        savingsRate: -200.0,
        healthScore: 35,
        healthStatus: 'Kritis / Defisit',
      );

      expect(deficitReport.isSurplus, isFalse);
      expect(deficitReport.isDeficit, isTrue);
      expect(deficitReport.totalExpense, equals(3000000));
      expect(deficitReport.healthScore, equals(35));
    });

    test('MonthlyReportData equality and toString work properly', () {
      final r1 = MonthlyReportData.empty(2026, 8);
      final r2 = MonthlyReportData.empty(2026, 8);
      final r3 = MonthlyReportData.empty(2026, 9);

      expect(r1, equals(r2));
      expect(r1.hashCode, equals(r2.hashCode));
      expect(r1 == r3, isFalse);
      expect(r1.toString(), contains('MonthlyReportData(monthKey: 2026-09'));
    });
  });

  group('REP-02: FinancialHealthEngine Tests', () {
    test('Calculates empty state when totalIncome == 0 and totalExpense == 0', () {
      final metrics = FinancialHealthEngine.calculate(
        totalIncome: 0,
        totalExpense: 0,
      );

      expect(metrics.savingsRate, equals(0.0));
      expect(metrics.healthScore, equals(0));
      expect(metrics.healthStatus, equals('Belum Ada Data'));
      expect(metrics.healthRecommendation, contains('Belum ada transaksi'));
    });

    test('Calculates critical deficit when totalIncome == 0 and totalExpense > 0', () {
      final metrics = FinancialHealthEngine.calculate(
        totalIncome: 0,
        totalExpense: 500000,
      );

      expect(metrics.savingsRate, equals(-100.0));
      expect(metrics.healthScore, equals(35));
      expect(metrics.healthStatus, equals('Kritis / Defisit'));
      expect(metrics.healthRecommendation, contains('Pengeluaran melebihi pemasukan'));
    });

    test('Calculates "Sangat Sehat" when savingsRate >= 40%', () {
      // Income: 10.000.000, Expense: 4.000.000 -> Savings Rate = 60%
      final metrics = FinancialHealthEngine.calculate(
        totalIncome: 10000000,
        totalExpense: 4000000,
      );

      expect(metrics.savingsRate, equals(60.0));
      expect(metrics.healthScore, equals(95));
      expect(metrics.healthStatus, equals('Sangat Sehat'));
      expect(metrics.healthRecommendation, contains('Kondisi keuangan sangat prima'));
    });

    test('Calculates "Sehat" when 20% <= savingsRate < 40%', () {
      // Income: 10.000.000, Expense: 7.500.000 -> Savings Rate = 25%
      final metrics = FinancialHealthEngine.calculate(
        totalIncome: 10000000,
        totalExpense: 7500000,
      );

      expect(metrics.savingsRate, equals(25.0));
      expect(metrics.healthScore, equals(82));
      expect(metrics.healthStatus, equals('Sehat'));
      expect(metrics.healthRecommendation, contains('Pengeluaran terkendali'));
    });

    test('Calculates "Waspada" when 0% <= savingsRate < 20%', () {
      // Income: 10.000.000, Expense: 9.000.000 -> Savings Rate = 10%
      final metrics = FinancialHealthEngine.calculate(
        totalIncome: 10000000,
        totalExpense: 9000000,
      );

      expect(metrics.savingsRate, equals(10.0));
      expect(metrics.healthScore, equals(65));
      expect(metrics.healthStatus, equals('Waspada'));
      expect(metrics.healthRecommendation, contains('Arus kas tipis'));
    });

    test('Calculates "Kritis / Defisit" when savingsRate < 0%', () {
      // Income: 5.000.000, Expense: 7.000.000 -> Savings Rate = -40%
      final metrics = FinancialHealthEngine.calculate(
        totalIncome: 5000000,
        totalExpense: 7000000,
      );

      expect(metrics.savingsRate, equals(-40.0));
      expect(metrics.healthScore, equals(35));
      expect(metrics.healthStatus, equals('Kritis / Defisit'));
      expect(metrics.healthRecommendation, contains('Pengeluaran melebihi pemasukan'));
    });
  });

  group('REP-03: DailyTrendGenerator Tests', () {
    test('Returns empty list when transaction list is empty', () {
      final trends = DailyTrendGenerator.generate(
        transactions: [],
        monthIndex: 9,
      );

      expect(trends, isEmpty);
    });

    test('Correctly aggregates multiple transactions on the same day and orders chronologically', () {
      final txs = [
        TransactionModel(
          id: 'tx1',
          type: 'expense',
          amount: 25000,
          categoryId: 'exp-1',
          categoryName: 'Makanan',
          categoryIconCode: Icons.restaurant.codePoint,
          notes: '',
          timeStr: '10.00',
          date: DateTime(2026, 10, 5),
          dateKey: '2026-10-05',
          monthKey: '2026-10',
          year: 2026,
          month: 9,
          day: 5,
        ),
        TransactionModel(
          id: 'tx2',
          type: 'income',
          amount: 400000,
          categoryId: 'inc-1',
          categoryName: 'Freelance',
          categoryIconCode: Icons.work.codePoint,
          notes: '',
          timeStr: '12.00',
          date: DateTime(2026, 10, 5),
          dateKey: '2026-10-05',
          monthKey: '2026-10',
          year: 2026,
          month: 9,
          day: 5,
        ),
        TransactionModel(
          id: 'tx3',
          type: 'expense',
          amount: 50000,
          categoryId: 'exp-2',
          categoryName: 'Transportasi',
          categoryIconCode: Icons.directions_car.codePoint,
          notes: '',
          timeStr: '08.00',
          date: DateTime(2026, 10, 2),
          dateKey: '2026-10-02',
          monthKey: '2026-10',
          year: 2026,
          month: 9,
          day: 2,
        ),
      ];

      final trends = DailyTrendGenerator.generate(
        transactions: txs,
        monthIndex: 9, // Oktober
      );

      expect(trends.length, equals(2));
      // Tanggal 2 muncul duluan
      expect(trends[0].dayStr, equals('02'));
      expect(trends[0].fullDateStr, equals('02 Okt'));
      expect(trends[0].expense, equals(50000));
      expect(trends[0].income, equals(0));

      // Tanggal 5 menggabungkan pemasukan dan pengeluaran
      expect(trends[1].dayStr, equals('05'));
      expect(trends[1].fullDateStr, equals('05 Okt'));
      expect(trends[1].expense, equals(25000));
      expect(trends[1].income, equals(400000));
    });
  });

  group('REP-04: CategoryProportionGenerator Tests', () {
    test('Returns empty list when no matching transaction type exists', () {
      final txs = [
        TransactionModel(
          id: 'tx1',
          type: 'income',
          amount: 1000000,
          categoryId: 'inc-1',
          categoryName: 'Gaji',
          categoryIconCode: Icons.payments.codePoint,
          notes: '',
          timeStr: '10.00',
          date: DateTime(2026, 10, 1),
          dateKey: '2026-10-01',
          monthKey: '2026-10',
          year: 2026,
          month: 9,
          day: 1,
        ),
      ];

      final expenseCategories = CategoryProportionGenerator.generate(
        transactions: txs,
        isExpense: true,
      );

      expect(expenseCategories, isEmpty);
    });

    test('Calculates percentages, sorts descending, and formats palette correctly', () {
      final txs = [
        TransactionModel(
          id: 'tx1',
          type: 'expense',
          amount: 40000,
          categoryId: 'exp-2',
          categoryName: 'Transportasi',
          categoryIconCode: Icons.directions_car.codePoint,
          notes: '',
          timeStr: '08.00',
          date: DateTime(2026, 10, 1),
          dateKey: '2026-10-01',
          monthKey: '2026-10',
          year: 2026,
          month: 9,
          day: 1,
        ),
        TransactionModel(
          id: 'tx2',
          type: 'expense',
          amount: 60000,
          categoryId: 'exp-1',
          categoryName: 'Makanan & Minuman',
          categoryIconCode: Icons.restaurant.codePoint,
          notes: '',
          timeStr: '12.00',
          date: DateTime(2026, 10, 2),
          dateKey: '2026-10-02',
          monthKey: '2026-10',
          year: 2026,
          month: 9,
          day: 2,
        ),
      ];

      final categories = CategoryProportionGenerator.generate(
        transactions: txs,
        isExpense: true,
        totalAmount: 100000,
      );

      expect(categories.length, equals(2));
      // Peringkat 1: Makanan & Minuman (60.000 = 60.0%)
      expect(categories[0].name, equals('Makanan & Minuman'));
      expect(categories[0].amount, equals(60000));
      expect(categories[0].percentage, equals(60.0));
      expect(categories[0].sliceColor, equals(const Color(0xFFDC2626)));

      // Peringkat 2: Transportasi (40.000 = 40.0%)
      expect(categories[1].name, equals('Transportasi'));
      expect(categories[1].amount, equals(40000));
      expect(categories[1].percentage, equals(40.0));
      expect(categories[1].sliceColor, equals(const Color(0xFFEF4444)));
    });

    test('Maps custom category icons and colors using categoryLookup', () {
      final txs = [
        TransactionModel(
          id: 'tx1',
          type: 'expense',
          amount: 100000,
          categoryId: 'custom-cat-1',
          categoryName: 'Hobi',
          categoryIconCode: Icons.category.codePoint,
          notes: '',
          timeStr: '10.00',
          date: DateTime(2026, 10, 1),
          dateKey: '2026-10-01',
          monthKey: '2026-10',
          year: 2026,
          month: 9,
          day: 1,
        ),
      ];

      final categoryLookup = {
        'custom-cat-1': const CategoryItem(
          id: 'custom-cat-1',
          name: 'Hobi & Game',
          icon: Icons.sports_esports_rounded,
          isExpense: true,
          color: Color(0xFF9333EA),
        ),
      };

      final items = CategoryProportionGenerator.generate(
        transactions: txs,
        isExpense: true,
        categoryLookup: categoryLookup,
      );

      expect(items.length, equals(1));
      expect(items.first.name, equals('Hobi & Game'));
      expect(items.first.icon, equals(Icons.sports_esports_rounded));
    });
  });

  group('REP-05: ReportRepository Integration Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late ReportRepository repository;
    const testUid = 'user_rep_test_123';

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repository = ReportRepository(firestore: fakeFirestore);
    });

    test('Returns empty report when uid is empty or whitespace', () async {
      final report = await repository.getMonthlyReport('', year: 2026, monthIndex: 9);
      expect(report.isEmpty, isTrue);
      expect(report.monthKey, equals('2026-10'));
    });

    test('Returns empty report when no transactions and no summary exist', () async {
      final report = await repository.getMonthlyReport(
        testUid,
        monthKey: '2026-10',
      );

      expect(report.isEmpty, isTrue);
      expect(report.totalIncome, equals(0));
      expect(report.totalExpense, equals(0));
      expect(report.healthScore, equals(0));
      expect(report.healthStatus, equals('Belum Ada Data'));
    });

    test('Successfully aggregates transactions, monthly_summaries, and categories into MonthlyReportData', () async {
      // 1. Seed monthly_summary doc
      final summary = MonthlySummaryModel(
        monthKey: '2026-10',
        year: 2026,
        month: 9,
        totalIncome: 5000000,
        totalExpense: 200000,
        netCashflow: 4800000,
        transactionCount: 2,
      );
      await fakeFirestore
          .collection('users')
          .doc(testUid)
          .collection('monthly_summaries')
          .doc('2026-10')
          .set(summary.toFirestore());

      // 2. Seed subcollection categories
      final catExpense = const CategoryItem(
        id: 'cat-exp-1',
        name: 'Makanan Resto',
        icon: Icons.restaurant_rounded,
        isExpense: true,
        color: Color(0xFFDC2626),
      );
      await fakeFirestore
          .collection('users')
          .doc(testUid)
          .collection('categories')
          .doc('cat-exp-1')
          .set(catExpense.toMap());

      // 3. Seed transactions
      final tx1 = TransactionModel(
        id: 'tx_1',
        type: 'income',
        amount: 5000000,
        categoryId: 'cat-inc-1',
        categoryName: 'Gaji',
        categoryIconCode: Icons.payments_rounded.codePoint,
        notes: 'Gaji bulanan',
        timeStr: '09.00',
        date: DateTime(2026, 10, 1),
        dateKey: '2026-10-01',
        monthKey: '2026-10',
        year: 2026,
        month: 9,
        day: 1,
      );
      final tx2 = TransactionModel(
        id: 'tx_2',
        type: 'expense',
        amount: 200000,
        categoryId: 'cat-exp-1',
        categoryName: 'Makanan Resto',
        categoryIconCode: Icons.restaurant_rounded.codePoint,
        notes: 'Makan malam',
        timeStr: '19.00',
        date: DateTime(2026, 10, 5),
        dateKey: '2026-10-05',
        monthKey: '2026-10',
        year: 2026,
        month: 9,
        day: 5,
      );

      await fakeFirestore
          .collection('users')
          .doc(testUid)
          .collection('transactions')
          .doc(tx1.id)
          .set(tx1.toFirestore());

      await fakeFirestore
          .collection('users')
          .doc(testUid)
          .collection('transactions')
          .doc(tx2.id)
          .set(tx2.toFirestore());

      // 4. Panggil repository getMonthlyReport
      final report = await repository.getMonthlyReport(
        testUid,
        year: 2026,
        monthIndex: 9,
      );

      expect(report.isEmpty, isFalse);
      expect(report.monthKey, equals('2026-10'));
      expect(report.totalIncome, equals(5000000));
      expect(report.totalExpense, equals(200000));
      expect(report.netCashflow, equals(4800000));
      // Savings rate: (4.800.000 / 5.000.000) * 100 = 96%
      expect(report.savingsRate, equals(96.0));
      expect(report.healthScore, equals(95));
      expect(report.healthStatus, equals('Sangat Sehat'));

      // Daily trends
      expect(report.dailyTrends.length, equals(2));
      expect(report.dailyTrends[0].dayStr, equals('01'));
      expect(report.dailyTrends[0].income, equals(5000000));
      expect(report.dailyTrends[1].dayStr, equals('05'));
      expect(report.dailyTrends[1].expense, equals(200000));

      // Category items
      expect(report.expenseCategories.length, equals(1));
      expect(report.expenseCategories.first.name, equals('Makanan Resto'));
      expect(report.expenseCategories.first.amount, equals(200000));
      expect(report.expenseCategories.first.percentage, equals(100.0));

      expect(report.incomeCategories.length, equals(1));
      expect(report.incomeCategories.first.name, equals('Gaji'));
      expect(report.incomeCategories.first.amount, equals(5000000));

      // 5. Test convenience getMonthlyReportByKey
      final reportByKey = await repository.getMonthlyReportByKey(testUid, '2026-10');
      expect(reportByKey.totalIncome, equals(report.totalIncome));
      expect(reportByKey.totalExpense, equals(report.totalExpense));
    });

    test('Fallback to monthly_summaries when transactions list is empty but summary exists', () async {
      final summary = MonthlySummaryModel(
        monthKey: '2026-10',
        year: 2026,
        month: 9,
        totalIncome: 3000000,
        totalExpense: 1500000,
        netCashflow: 1500000,
        transactionCount: 5,
      );
      await fakeFirestore
          .collection('users')
          .doc(testUid)
          .collection('monthly_summaries')
          .doc('2026-10')
          .set(summary.toFirestore());

      final report = await repository.getMonthlyReport(
        testUid,
        monthKey: '2026-10',
      );

      expect(report.isEmpty, isFalse);
      expect(report.totalIncome, equals(3000000));
      expect(report.totalExpense, equals(1500000));
      expect(report.netCashflow, equals(1500000));
      expect(report.savingsRate, equals(50.0));
      expect(report.healthScore, equals(95));
      expect(report.healthStatus, equals('Sangat Sehat'));
    });
  });

  // ===========================================================================
  // REP-06: REALTIME STREAM LAPORAN TESTS
  // ===========================================================================
  group('REP-06: watchMonthlyReport Realtime Stream Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late ReportRepository repository;
    const testUid = 'user_stream_test_999';

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repository = ReportRepository(firestore: fakeFirestore);
    });

    test('watchMonthlyReport emits empty report when uid is blank', () async {
      final stream = repository.watchMonthlyReport('', '2026-10');
      final first = await stream.first;
      expect(first.isEmpty, isTrue);
    });

    test('watchMonthlyReport emits dynamic updates when new transactions are added', () async {
      final stream = repository.watchMonthlyReport(testUid, '2026-10');

      // 1. Awalnya belum ada data
      final initialFuture = stream.first;
      final initialData = await initialFuture;
      expect(initialData.isEmpty, isTrue);

      // 2. Tambah transaksi income
      final tx1 = TransactionModel(
        id: 'tx_stream_1',
        type: 'income',
        amount: 4000000,
        categoryId: 'inc-1',
        categoryName: 'Gaji',
        categoryIconCode: Icons.payments.codePoint,
        notes: '',
        timeStr: '10.00',
        date: DateTime(2026, 10, 1),
        dateKey: '2026-10-01',
        monthKey: '2026-10',
        year: 2026,
        month: 9,
        day: 1,
      );

      final nextEmission = stream.skip(1).first;
      await fakeFirestore
          .collection('users')
          .doc(testUid)
          .collection('transactions')
          .doc(tx1.id)
          .set(tx1.toFirestore());

      final updatedData = await nextEmission;
      expect(updatedData.isEmpty, isFalse);
      expect(updatedData.totalIncome, equals(4000000));
      expect(updatedData.totalExpense, equals(0));
      expect(updatedData.savingsRate, equals(100.0));
      expect(updatedData.healthStatus, equals('Sangat Sehat'));
    });
  });

  // ===========================================================================
  // REP-07: PENANGANAN MODE BULAN KOSONG TESTS
  // ===========================================================================
  group('REP-07: Penanganan Mode Bulan Kosong Tests', () {
    test('Empty state calculates without zero division error and reports isEmpty correctly', () {
      final emptyReport = MonthlyReportData.empty(2026, 4); // Mei 2026
      expect(emptyReport.isEmpty, isTrue);
      expect(emptyReport.totalIncome, equals(0));
      expect(emptyReport.totalExpense, equals(0));
      expect(emptyReport.savingsRate, equals(0.0));
      expect(emptyReport.healthScore, equals(0));

      final metrics = FinancialHealthEngine.calculate(
        totalIncome: 0,
        totalExpense: 0,
      );
      expect(metrics.savingsRate, equals(0.0));
      expect(metrics.healthScore, equals(0));
      expect(metrics.healthStatus, equals('Belum Ada Data'));

      final expenseProportions = CategoryProportionGenerator.generate(
        transactions: [],
        isExpense: true,
      );
      expect(expenseProportions, isEmpty);

      final dailyTrends = DailyTrendGenerator.generate(
        transactions: [],
        monthIndex: 4,
      );
      expect(dailyTrends, isEmpty);
    });
  });

  // ===========================================================================
  // REP-09: INTEGRASI REPORT HEALTH CARD TESTS
  // ===========================================================================
  group('REP-09: ReportHealthCard Widget Integration Tests', () {
    testWidgets('ReportHealthCard renders real score, status, and dynamic recommendation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ReportHealthCard(
              isEmpty: false,
              isExpenseMode: false,
              score: 85,
              savingsRate: 35.0,
              healthStatus: 'Sehat',
              recommendation: 'Kondisi keuangan terkendali dengan sangat baik.',
            ),
          ),
        ),
      );

      expect(find.text('Indikator Kesehatan'), findsOneWidget);
      expect(find.text('Sehat'), findsOneWidget);
      expect(find.text('Skor: 85'), findsOneWidget);
      expect(find.text('Kondisi keuangan terkendali dengan sangat baik.'), findsOneWidget);
    });

    testWidgets('ReportHealthCard renders critical deficit with proper badge and score', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ReportHealthCard(
              isEmpty: false,
              isExpenseMode: true,
              score: 35,
              savingsRate: -30.0,
              healthStatus: 'Kritis / Defisit',
              recommendation: 'Pengeluaran melebihi pemasukan bulan ini.',
            ),
          ),
        ),
      );

      expect(find.text('Kritis / Defisit'), findsOneWidget);
      expect(find.text('Skor: 35'), findsOneWidget);
      expect(find.text('Pengeluaran melebihi pemasukan bulan ini.'), findsOneWidget);
    });
  });

  // ===========================================================================
  // REP-10: INTEGRASI REPORT TREND CARD TESTS
  // ===========================================================================
  group('REP-10: ReportTrendCard Dynamic Scaling and Tooltip Tests', () {
    testWidgets('ReportTrendCard renders dynamic daily trends and interactive tooltip', (tester) async {
      const customTrends = [
        ReportDailyTrendItem(
          dayStr: '03',
          fullDateStr: '03 Nov',
          expense: 50000,
          income: 0,
        ),
        ReportDailyTrendItem(
          dayStr: '08',
          fullDateStr: '08 Nov',
          expense: 25000,
          income: 150000,
        ),
      ];

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ReportTrendCard(
              isEmpty: false,
              isExpenseMode: true,
              expenseTotal: 75000,
              incomeTotal: 150000,
              dailyTrends: customTrends,
            ),
          ),
        ),
      );

      expect(find.text('Tren Keuangan'), findsOneWidget);
      expect(find.text('03'), findsOneWidget);
      expect(find.text('08'), findsOneWidget);

      // Tap on second bar (index 1) to trigger tooltip
      await tester.tap(find.text('08'));
      await tester.pump();

      expect(find.text('08 Nov'), findsOneWidget);
    });
  });

  // ===========================================================================
  // REP-11: INTEGRASI REPORT STRUCTURE CARD TESTS
  // ===========================================================================
  group('REP-11: ReportStructureCard Widget Integration Tests', () {
    testWidgets('ReportStructureCard renders real category list and donut total', (tester) async {
      const customExpenseCategories = [
        ReportCategoryItem(
          name: 'Makanan Resto',
          percentage: 75.0,
          amount: 150000,
          icon: Icons.restaurant_rounded,
          iconColor: Color(0xFFBA1A1A),
          containerColor: Color(0xFFFFDAD6),
          badgeTextColor: Color(0xFF93000A),
          sliceColor: Color(0xFFDC2626),
        ),
        ReportCategoryItem(
          name: 'Bensin & Tol',
          percentage: 25.0,
          amount: 50000,
          icon: Icons.local_gas_station_rounded,
          iconColor: Color(0xFFBA1A1A),
          containerColor: Color(0xFFFFDAD6),
          badgeTextColor: Color(0xFF93000A),
          sliceColor: Color(0xFFEF4444),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReportStructureCard(
              isEmpty: false,
              isExpenseTab: true,
              totalAmount: 200000,
              onTabChanged: (_) {},
              categoryItems: customExpenseCategories,
            ),
          ),
        ),
      );

      expect(find.text('Struktur Transaksi'), findsOneWidget);
      expect(find.text('Pengeluaran'), findsWidgets);
      expect(find.text('Rp 200.000'), findsOneWidget);
      expect(find.text('Makanan Resto'), findsOneWidget);
      expect(find.text('75.0%'), findsOneWidget);
      expect(find.text('Rp 150.000'), findsOneWidget);
      expect(find.text('Bensin & Tol'), findsOneWidget);
      expect(find.text('25.0%'), findsOneWidget);
      expect(find.text('Rp 50.000'), findsOneWidget);
    });

    testWidgets('ReportStructureCard shows graceful placeholder when category items are empty', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReportStructureCard(
              isEmpty: false,
              isExpenseTab: true,
              totalAmount: 0,
              onTabChanged: (_) {},
              categoryItems: const [],
            ),
          ),
        ),
      );

      expect(find.text('Belum ada transaksi pengeluaran'), findsOneWidget);
    });
  });

  // ===========================================================================
  // REP-12: TOGGLE TAB KELUAR & MASUK TESTS
  // ===========================================================================
  group('REP-12: Segmented Toggle Tab Keluar & Masuk Tests', () {
    testWidgets('Tapping Masuk and Keluar triggers onTabChanged callback', (tester) async {
      bool? lastTabState;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReportStructureCard(
              isEmpty: false,
              isExpenseTab: true, // Saat ini Keluar
              totalAmount: 200000,
              onTabChanged: (isExpense) {
                lastTabState = isExpense;
              },
            ),
          ),
        ),
      );

      // Tap tab Masuk
      await tester.tap(find.text('Masuk'));
      await tester.pumpAndSettle();

      expect(lastTabState, isFalse);
    });
  });

  // ===========================================================================
  // REP-13: OPTIMASI KUERI & OFFLINE CACHE TESTS
  // ===========================================================================
  group('REP-13: Optimasi Kueri & Offline Cache Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late ReportRepository repository;
    const testUid = 'user_query_opt_777';

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repository = ReportRepository(firestore: fakeFirestore);
    });

    test('Query retrieves transactions ordered chronologically by monthKey and date ASC', () async {
      final txOlder = TransactionModel(
        id: 'tx_old',
        type: 'expense',
        amount: 20000,
        categoryId: 'exp-1',
        categoryName: 'Makan',
        categoryIconCode: Icons.restaurant.codePoint,
        notes: '',
        timeStr: '08.00',
        date: DateTime(2026, 10, 1),
        dateKey: '2026-10-01',
        monthKey: '2026-10',
        year: 2026,
        month: 9,
        day: 1,
      );

      final txNewer = TransactionModel(
        id: 'tx_new',
        type: 'expense',
        amount: 35000,
        categoryId: 'exp-1',
        categoryName: 'Makan',
        categoryIconCode: Icons.restaurant.codePoint,
        notes: '',
        timeStr: '19.00',
        date: DateTime(2026, 10, 15),
        dateKey: '2026-10-15',
        monthKey: '2026-10',
        year: 2026,
        month: 9,
        day: 15,
      );

      await fakeFirestore
          .collection('users')
          .doc(testUid)
          .collection('transactions')
          .doc(txNewer.id)
          .set(txNewer.toFirestore());

      await fakeFirestore
          .collection('users')
          .doc(testUid)
          .collection('transactions')
          .doc(txOlder.id)
          .set(txOlder.toFirestore());

      final report = await repository.getMonthlyReport(testUid, monthKey: '2026-10');

      expect(report.dailyTrends.length, equals(2));
      // Tanggal 1 harus sebelum tanggal 15 (ASC order)
      expect(report.dailyTrends[0].dayStr, equals('01'));
      expect(report.dailyTrends[1].dayStr, equals('15'));
    });
  });

  // ===========================================================================
  // REP-14: PENGUJIAN UNIT & WIDGET TESTS KOMPREHENSIF
  // ===========================================================================
  group('REP-14: Comprehensive Verification Tests', () {
    test('Category proportions percentages distribute logically and handle single category as 100%', () {
      final txs = [
        TransactionModel(
          id: 'tx1',
          type: 'income',
          amount: 5000000,
          categoryId: 'inc-1',
          categoryName: 'Gaji Pokok',
          categoryIconCode: Icons.payments.codePoint,
          notes: '',
          timeStr: '09.00',
          date: DateTime(2026, 10, 1),
          dateKey: '2026-10-01',
          monthKey: '2026-10',
          year: 2026,
          month: 9,
          day: 1,
        ),
      ];

      final items = CategoryProportionGenerator.generate(
        transactions: txs,
        isExpense: false,
        totalAmount: 5000000,
      );

      expect(items.length, equals(1));
      expect(items.first.percentage, equals(100.0));
      expect(items.first.name, equals('Gaji Pokok'));
    });

    test('Financial health score correctly transitions through all 5 statuses', () {
      // 1. Belum Ada Data
      expect(FinancialHealthEngine.calculate(totalIncome: 0, totalExpense: 0).healthStatus, equals('Belum Ada Data'));

      // 2. Sangat Sehat (>= 40%)
      expect(FinancialHealthEngine.calculate(totalIncome: 100, totalExpense: 50).healthStatus, equals('Sangat Sehat'));

      // 3. Sehat (20% - 39%)
      expect(FinancialHealthEngine.calculate(totalIncome: 100, totalExpense: 75).healthStatus, equals('Sehat'));

      // 4. Waspada (0% - 19%)
      expect(FinancialHealthEngine.calculate(totalIncome: 100, totalExpense: 95).healthStatus, equals('Waspada'));

      // 5. Kritis / Defisit (< 0%)
      expect(FinancialHealthEngine.calculate(totalIncome: 100, totalExpense: 120).healthStatus, equals('Kritis / Defisit'));
    });
  });
}
