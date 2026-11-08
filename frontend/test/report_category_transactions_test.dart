import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_finance/features/category/presentation/widgets/category_3d_icon.dart';
import 'package:track_finance/features/dashboard/data/dashboard_transaction_model.dart';
import 'package:track_finance/features/report/data/report_data_model.dart';
import 'package:track_finance/features/report/presentation/screens/report_category_transactions_screen.dart';
import 'package:track_finance/features/report/presentation/screens/report_screen.dart';
import 'package:track_finance/features/report/presentation/widgets/report_structure_card.dart';
import 'package:track_finance/features/transaction/presentation/screens/add_transaction_screen.dart';

void main() {
  group('ReportCategoryTransactionsScreen & StructureCard Tests', () {
    const testCategory = ReportCategoryItem(
      id: 'exp-1',
      name: 'Makanan & Minuman',
      percentage: 39.0,
      amount: 97000,
      icon: Icons.restaurant_rounded,
      iconColor: Color(0xFFBA1A1A),
      containerColor: Color(0xFFFFDAD6),
      badgeTextColor: Color(0xFF93000A),
      sliceColor: Color(0xFFDC2626),
    );

    const testTransactions = [
      DashboardTransaction(
        id: 'tx-1',
        dateStr: '07 Oktober 2026',
        dateKey: '2026-10-07',
        year: 2026,
        month: 9,
        day: 7,
        category: 'Makanan & Minuman',
        meta: '16.03 · Kopi Latte',
        amount: -14000,
        type: TransactionType.expense,
        icon: Icons.restaurant_rounded,
      ),
      DashboardTransaction(
        id: 'tx-2',
        dateStr: '06 Oktober 2026',
        dateKey: '2026-10-06',
        year: 2026,
        month: 9,
        day: 6,
        category: 'Makanan & Minuman',
        meta: '19.30 · Makan Malam Nasi Goreng',
        amount: -25000,
        type: TransactionType.expense,
        icon: Icons.restaurant_rounded,
      ),
    ];

    testWidgets(
        'ReportStructureCard triggers onCategoryTap when category item is clicked',
        (tester) async {
      ReportCategoryItem? tappedCategory;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReportStructureCard(
              isExpenseTab: true,
              isEmpty: false,
              totalAmount: 97000,
              onTabChanged: (_) {},
              categoryItems: const [testCategory],
              onCategoryTap: (cat) {
                tappedCategory = cat;
              },
            ),
          ),
        ),
      );

      // Verifikasi nama kategori tampil
      expect(find.text('Makanan & Minuman'), findsOneWidget);

      // Klik item baris kategori
      await tester.tap(find.text('Makanan & Minuman'));
      await tester.pumpAndSettle();

      // Verifikasi callback dipanggil
      expect(tappedCategory, isNotNull);
      expect(tappedCategory!.id, equals('exp-1'));
      expect(tappedCategory!.name, equals('Makanan & Minuman'));
    });

    testWidgets(
        'ReportCategoryTransactionsScreen renders header, hero summary card, and transaction list',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ReportCategoryTransactionsScreen(
            categoryItem: testCategory,
            year: 2026,
            monthIndex: 9, // Oktober
            isExpense: true,
            initialTransactions: testTransactions,
          ),
        ),
      );

      // Verifikasi Header
      expect(find.text('Oktober 2026'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);

      // Verifikasi Hero Category Card
      expect(find.byType(Category3DIcon), findsOneWidget);
      expect(find.text('Pengeluaran'), findsOneWidget);
      expect(find.text('39.0% porsi'), findsOneWidget);
      expect(find.text('Total Pengeluaran'), findsOneWidget);
      expect(find.text('Rp 97.000'), findsOneWidget);
      expect(find.text('2 Transaksi'), findsOneWidget);

      // Verifikasi Header Section Transaksi
      expect(find.text('Daftar Transaksi'), findsOneWidget);

      // Verifikasi Daftar Transaksi per Tanggal
      expect(find.text('07 Oktober 2026'), findsOneWidget);
      expect(find.text('06 Oktober 2026'), findsOneWidget);
      expect(find.text('16.03 · Kopi Latte'), findsOneWidget);
      expect(find.text('19.30 · Makan Malam Nasi Goreng'), findsOneWidget);
      expect(find.text('-Rp14.000'), findsNWidgets(2)); // Subtotal tanggal + Nominal kartu
      expect(find.text('-Rp25.000'), findsNWidgets(2)); // Subtotal tanggal + Nominal kartu
    });

    testWidgets(
        'ReportCategoryTransactionsScreen displays empty state when no transactions',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ReportCategoryTransactionsScreen(
            categoryItem: testCategory,
            year: 2026,
            monthIndex: 9,
            isExpense: true,
            initialTransactions: [],
          ),
        ),
      );

      expect(find.text('Belum Ada Transaksi'), findsOneWidget);
      expect(
        find.textContaining('Tidak ada catatan transaksi untuk kategori ini'),
        findsOneWidget,
      );
    });

    testWidgets(
        'Tapping back button in ReportCategoryTransactionsScreen pops screen',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ReportCategoryTransactionsScreen(
                      categoryItem: testCategory,
                      year: 2026,
                      monthIndex: 9,
                      isExpense: true,
                      initialTransactions: testTransactions,
                    ),
                  ),
                );
              },
              child: const Text('Open Details'),
            ),
          ),
        ),
      );

      // Buka halaman rincian kategori
      await tester.tap(find.text('Open Details'));
      await tester.pumpAndSettle();
      expect(find.byType(ReportCategoryTransactionsScreen), findsOneWidget);

      // Tekan tombol kembali
      final backButton = find.byIcon(Icons.arrow_back_rounded);
      expect(backButton, findsOneWidget);
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      // Halaman berhasil pop kembali
      expect(find.byType(ReportCategoryTransactionsScreen), findsNothing);
      expect(find.text('Open Details'), findsOneWidget);
    });

    testWidgets('Tapping transaction opens AddTransactionScreen in edit mode',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ReportCategoryTransactionsScreen(
            categoryItem: testCategory,
            year: 2026,
            monthIndex: 9,
            isExpense: true,
            initialTransactions: testTransactions,
          ),
        ),
      );

      // Tap transaksi kopi
      await tester.tap(find.text('16.03 · Kopi Latte'));
      await tester.pumpAndSettle();

      // Membuka AddTransactionScreen
      expect(find.byType(AddTransactionScreen), findsOneWidget);
      expect(find.text('Edit Transaksi'), findsOneWidget);
    });

    testWidgets(
        'Navigation from ReportScreen to ReportCategoryTransactionsScreen works when tapping category in ReportStructureCard',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ReportScreen(
            initialYear: 2026,
            initialMonthIndex: 9, // Oktober 2026 (ada demo data)
            initialIsLoading: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final categoryFinder = find.descendant(
        of: find.byType(ReportStructureCard),
        matching: find.text('Makanan & Minuman'),
      );

      await tester.scrollUntilVisible(
        categoryFinder,
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(categoryFinder, findsOneWidget);

      // Tap kategori Makanan & Minuman di dalam kartu struktur
      await tester.tap(categoryFinder);
      await tester.pumpAndSettle();

      // Verifikasi ReportCategoryTransactionsScreen terbuka
      expect(find.byType(ReportCategoryTransactionsScreen), findsOneWidget);
      expect(find.text('Oktober 2026'), findsOneWidget);
      expect(find.text('Daftar Transaksi'), findsOneWidget);
    });
  });
}
