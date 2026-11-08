import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_finance/features/dashboard/data/dashboard_transaction_model.dart';
import 'package:track_finance/features/dashboard/presentation/widgets/animated_amount_text.dart';
import 'package:track_finance/features/dashboard/presentation/widgets/dashboard_shortcuts_row.dart';
import 'package:track_finance/features/dashboard/presentation/widgets/dashboard_tactile_header.dart';
import 'package:track_finance/features/dashboard/presentation/widgets/dashboard_transactions_view.dart';
import 'package:track_finance/features/dashboard/presentation/widgets/dashboard_search_and_filter.dart';
import 'package:track_finance/features/dashboard/presentation/widgets/header_time_theme.dart';

void main() {
  group('Dashboard 3D Shortcuts & Arrows Unit/Widget Tests', () {
    testWidgets('DashboardShortcutsRow renders 4 3D icons without container & triggers callbacks', (tester) async {
      bool addTapped = false;
      bool categoryTapped = false;
      bool exportTapped = false;
      bool reportTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardShortcutsRow(
              onAdd: () => addTapped = true,
              onCategory: () => categoryTapped = true,
              onExportImport: () => exportTapped = true,
              onReports: () => reportTapped = true,
            ),
          ),
        ),
      );

      // Verify labels exist
      expect(find.text('Tambah'), findsOneWidget);
      expect(find.text('Kategori'), findsOneWidget);
      expect(find.text('Ekspor/Impor'), findsOneWidget);
      expect(find.text('Laporan'), findsOneWidget);

      // Verify 4 Image widgets are rendered with correct 3D asset paths
      final imageWidgets = tester.widgetList<Image>(find.byType(Image)).toList();
      expect(imageWidgets.length, equals(4));

      final assetNames = imageWidgets.map((img) {
        final provider = img.image;
        if (provider is ResizeImage) {
          return (provider.imageProvider as AssetImage).assetName;
        }
        return (provider as AssetImage).assetName;
      }).toList();

      expect(assetNames, contains('assets/icons/3d/nav_add.webp'));
      expect(assetNames, contains('assets/icons/3d/nav_category.webp'));
      expect(assetNames, contains('assets/icons/3d/nav_export.webp'));
      expect(assetNames, contains('assets/icons/3d/nav_report.webp'));

      // Test tapping each shortcut item
      await tester.tap(find.text('Tambah'));
      expect(addTapped, isTrue);

      await tester.tap(find.text('Kategori'));
      expect(categoryTapped, isTrue);

      await tester.tap(find.text('Ekspor/Impor'));
      expect(exportTapped, isTrue);

      await tester.tap(find.text('Laporan'));
      expect(reportTapped, isTrue);
    });

    testWidgets('DashboardTactileHeader renders side-by-side 3D income/expense arrows + nominals without labels or containers', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardTactileHeader(
              userName: 'Heru',
              periodLabel: 'November 2026',
              totalIncomeValue: 100000,
              totalExpenseValue: 1000000,
              onOpenPicker: () {},
              onPrev: () {},
              onNext: () {},
              timeOfDay: DashboardTimeOfDay.siang,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      // Teks "Pemasukan" dan "Pengeluaran" dihilangkan
      expect(find.text('Pemasukan'), findsNothing);
      expect(find.text('Pengeluaran'), findsNothing);

      // Angka nominal tetap tampil
      expect(find.text('Rp 100.000'), findsOneWidget);
      expect(find.text('Rp 1.000.000'), findsOneWidget);

      final imageWidgets = tester.widgetList<Image>(find.byType(Image)).toList();
      final assetNames = imageWidgets.map((img) {
        final provider = img.image;
        if (provider is ResizeImage) {
          return (provider.imageProvider as AssetImage).assetName;
        }
        return (provider as AssetImage).assetName;
      }).toList();

      expect(assetNames, contains('assets/icons/3d/income_arrow.webp'));
      expect(assetNames, contains('assets/icons/3d/expense_arrow.webp'));

      // Verifikasi tata letak berdampingan (side-by-side 2 kolom):
      // Ikon panah pemasukan di sisi kiri, ikon panah pengeluaran di sisi kanan pada baris yang sama
      final incomeImgFinder = find.byType(Image).first;
      final expenseImgFinder = find.byType(Image).last;
      final incomeCenter = tester.getCenter(incomeImgFinder);
      final expenseCenter = tester.getCenter(expenseImgFinder);
      expect(incomeCenter.dx, lessThan(expenseCenter.dx));
      expect((incomeCenter.dy - expenseCenter.dy).abs(), lessThan(8.0));

      // Pastikan tidak ada Container / DecoratedBox berlatar warna di sekeliling AnimatedAmountText
      final amountFinder = find.byType(AnimatedAmountText);
      expect(amountFinder, findsNWidgets(2));
      for (final element in amountFinder.evaluate()) {
        Element? parent = element;
        bool foundCashflowContainer = false;
        element.visitAncestorElements((ancestor) {
          if (ancestor.widget is SafeArea) {
            return false; // stop di SafeArea konten utama header
          }
          if (ancestor.widget is Container) {
            final container = ancestor.widget as Container;
            if (container.color != null || container.decoration != null) {
              foundCashflowContainer = true;
            }
          }
          parent = ancestor;
          return true;
        });
        expect(parent, isNotNull);
        expect(foundCashflowContainer, isFalse);
      }
    });

    testWidgets('DashboardTactileHeader adapts nominal text colors and shadows for all 4 DashboardTimeOfDay themes', (tester) async {
      for (final time in DashboardTimeOfDay.values) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DashboardTactileHeader(
                userName: 'Heru',
                periodLabel: 'November 2026',
                totalIncomeValue: 250000,
                totalExpenseValue: 125000,
                onOpenPicker: () {},
                onPrev: () {},
                onNext: () {},
                timeOfDay: time,
              ),
            ),
          ),
        );
        await tester.pump(const Duration(seconds: 1));

        final incomeText = tester.widget<Text>(find.text('Rp 250.000'));
        final expenseText = tester.widget<Text>(find.text('Rp 125.000'));

        expect(incomeText.style?.color, equals(time.incomeAmountColor));
        expect(expenseText.style?.color, equals(time.expenseAmountColor));
        expect(incomeText.style?.shadows, equals(time.incomeAmountShadows));
        expect(expenseText.style?.shadows, equals(time.expenseAmountShadows));
        expect(incomeText.style?.color, isNot(equals(expenseText.style?.color)));
      }
    });

    testWidgets('DashboardTransactionsView renders 3D income and expense arrows for transactions', (tester) async {
      final transactions = [
        const DashboardTransaction(
          id: 'tx-1',
          dateStr: '6 November 2026',
          dateKey: '2026-11-06',
          year: 2026,
          month: 10,
          day: 6,
          category: 'Gaji Pokok',
          meta: '22.16',
          amount: 100000,
          type: TransactionType.income,
          icon: Icons.account_balance_wallet_rounded,
        ),
        const DashboardTransaction(
          id: 'tx-2',
          dateStr: '6 November 2026',
          dateKey: '2026-11-06',
          year: 2026,
          month: 10,
          day: 6,
          category: 'Makanan & Minuman',
          meta: '22.16',
          amount: 1000000,
          type: TransactionType.expense,
          icon: Icons.restaurant_rounded,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DashboardTransactionsView(
              period: DashboardPeriod.hari,
              transactions: transactions,
              currentYear: 2026,
              currentMonthIndex: 10,
              currentDecadeStart: 2020,
            ),
          ),
        ),
      );

      final imageWidgets = tester.widgetList<Image>(find.byType(Image)).toList();
      final assetNames = imageWidgets.map((img) {
        final provider = img.image;
        if (provider is ResizeImage) {
          return (provider.imageProvider as AssetImage).assetName;
        }
        return (provider as AssetImage).assetName;
      }).toList();

      expect(assetNames, contains('assets/icons/3d/income_arrow.webp'));
      expect(assetNames, contains('assets/icons/3d/expense_arrow.webp'));
    });
  });
}
