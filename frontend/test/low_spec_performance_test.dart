import 'dart:convert';
import 'dart:typed_data';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_finance/features/dashboard/data/dashboard_transaction_model.dart';
import 'package:track_finance/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:track_finance/features/dashboard/presentation/widgets/dashboard_search_and_filter.dart';
import 'package:track_finance/features/dashboard/presentation/widgets/dashboard_tactile_header.dart';
import 'package:track_finance/features/dashboard/presentation/widgets/dashboard_transactions_view.dart';
import 'package:track_finance/features/dashboard/presentation/widgets/header_time_background.dart';
import 'package:track_finance/features/dashboard/presentation/widgets/header_time_theme.dart';
import 'package:track_finance/features/export/data/sync_import_repository.dart';
import 'package:track_finance/main.dart';

void main() {
  group('Low-Spec Android Performance Safeguards', () {
    testWidgets(
      'configureLowSpecPerformanceBudgets caps imageCache size and byte budget',
      (tester) async {
        configureLowSpecPerformanceBudgets();

        final imageCache = PaintingBinding.instance.imageCache;
        expect(imageCache.maximumSize, 100);
        expect(imageCache.maximumSizeBytes, 24 * 1024 * 1024);
      },
    );

    testWidgets(
      'DashboardTransactionsView progressively batches large lists at 60 cards and loads more on demand',
      (tester) async {
        final largeList = List.generate(135, (index) {
          return DashboardTransaction(
            id: 'tx-perf-$index',
            category: 'Item Ke-$index',
            meta: 'Catatan $index',
            amount: -10000,
            type: TransactionType.expense,
            dateStr: '10 Oktober 2026',
            dateKey: '2026-10-10',
            year: 2026,
            month: 9,
            day: 10,
            icon: Icons.fastfood_rounded,
          );
        });

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: DashboardTransactionsView(
                  period: DashboardPeriod.hari,
                  transactions: largeList,
                  currentYear: 2026,
                  currentMonthIndex: 9,
                  currentDecadeStart: 2020,
                ),
              ),
            ),
          ),
        );

        // Hanya 60 kartu pertama yang dipasang ke pohon widget
        expect(find.text('Item Ke-0'), findsOneWidget);
        expect(find.text('Item Ke-59'), findsOneWidget);
        expect(find.text('Item Ke-60'), findsNothing);
        expect(
          find.text('Tampilkan lebih banyak (75 lainnya)'),
          findsOneWidget,
        );

        // Rekap harian tetap akurat menghitung seluruh 135 transaksi (135 * 10.000 = 1.350.000)
        expect(find.textContaining('1.350.000'), findsOneWidget);

        // Ketuk tombol muat lebih banyak -> bertambah menjadi 120 kartu
        await tester.ensureVisible(
          find.text('Tampilkan lebih banyak (75 lainnya)'),
        );
        await tester.tap(find.text('Tampilkan lebih banyak (75 lainnya)'));
        await tester.pump();

        expect(find.text('Item Ke-119'), findsOneWidget);
        expect(find.text('Item Ke-120'), findsNothing);
        expect(
          find.text('Tampilkan lebih banyak (15 lainnya)'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'DashboardScreen pauses DashboardTactileHeader TickerMode when scrolled behind content panel',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 1920);
        tester.view.devicePixelRatio = 2.625;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(
          const MaterialApp(
            home: DashboardScreen(),
          ),
        );
        await tester.pump(const Duration(milliseconds: 500));

        final headerElement = tester.element(find.byType(DashboardTactileHeader));
        expect(TickerMode.valuesOf(headerElement).enabled, isTrue);

        // Gulir ke bawah melewati batas penutupan header
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -500),
        );
        await tester.pump();

        expect(TickerMode.valuesOf(headerElement).enabled, isFalse);

        // Gulir kembali ke atas -> TickerMode menyala kembali
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, 500),
        );
        await tester.pump();

        expect(TickerMode.valuesOf(headerElement).enabled, isTrue);
      },
    );

    testWidgets(
      'HeaderTimeBackground respects MediaQuery disableAnimations without running tickers',
      (tester) async {
        await tester.pumpWidget(
          const MediaQuery(
            data: MediaQueryData(disableAnimations: true),
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: SizedBox(
                width: 360,
                height: 240,
                child: HeaderTimeBackground(
                  timeOfDay: DashboardTimeOfDay.siang,
                ),
              ),
            ),
          ),
        );

        // pumpAndSettle berhasil langsung selesai tanpa timeout karena tidak ada ticker tak terbatas
        await tester.pumpAndSettle();
        expect(find.byType(HeaderTimeBackground), findsOneWidget);
      },
    );

    test(
      'SyncImportRepository offloads CSV > 32 KB to background isolate cleanly',
      () async {
        final repo = SyncImportRepository(firestore: FakeFirebaseFirestore());
        final buffer = StringBuffer(
          'No,Tanggal,Waktu,Tipe,Kategori,Nominal,Catatan\n',
        );
        for (int i = 1; i <= 700; i++) {
          buffer.writeln(
            '$i,2026-10-12,12.30,PENGELUARAN,Makan & Minum,${25000 + i},Catatan transaksi panjang baris ke-$i agar melampaui batas tiga puluh dua kilobita',
          );
        }

        final bytes = Uint8List.fromList(utf8.encode(buffer.toString()));
        expect(
          bytes.lengthInBytes,
          greaterThan(SyncImportRepository.kIsolateParseThresholdBytes),
        );

        final result = await repo.parseAndValidateCsv(bytes, 'large_import.csv');
        expect(result.validCount, 700);
        expect(result.errorCount, 0);
      },
    );
  });
}
