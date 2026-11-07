import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_finance/core/theme/app_theme.dart';
import 'package:track_finance/features/export/presentation/screens/export_data_screen.dart';
import 'package:track_finance/features/export/presentation/widgets/export_date_picker_modal.dart';

void main() {
  group('ExportDatePickerModal Unit & Widget Tests', () {
    testWidgets('renders scroller picker with TANGGAL, BULAN, TAHUN columns and Terapkan button', (tester) async {
      DateTime? confirmedDate;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  ExportDatePickerModal.show(
                    context,
                    title: 'Pilih Tanggal Mulai',
                    initialDate: DateTime(2026, 10, 5),
                    onConfirm: (date) {
                      confirmedDate = date;
                    },
                  );
                },
                child: const Text('Open Modal'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Check header title & icons
      expect(find.text('Pilih Tanggal Mulai'), findsOneWidget);
      expect(find.text('TANGGAL'), findsOneWidget);
      expect(find.text('BULAN'), findsOneWidget);
      expect(find.text('TAHUN'), findsOneWidget);
      expect(find.text('Terapkan'), findsOneWidget);

      // Tap Terapkan
      await tester.tap(find.text('Terapkan'));
      await tester.pumpAndSettle();

      expect(confirmedDate, equals(DateTime(2026, 10, 5)));
    });

    testWidgets('adjusts selected day when month changes to one with fewer days (e.g. 31 Jan to Feb)', (tester) async {
      DateTime? confirmedDate;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  ExportDatePickerModal.show(
                    context,
                    title: 'Pilih Tanggal',
                    initialDate: DateTime(2026, 1, 31),
                    onConfirm: (date) {
                      confirmedDate = date;
                    },
                  );
                },
                child: const Text('Open Modal'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Tap 'Feb' month in scroller
      await tester.tap(find.text('Feb'));
      await tester.pumpAndSettle();

      // Tap Terapkan
      await tester.tap(find.text('Terapkan'));
      await tester.pumpAndSettle();

      // In 2026, Feb has 28 days -> clamped to 28
      expect(confirmedDate, equals(DateTime(2026, 2, 28)));
    });

    testWidgets('ExportDataScreen in Rentang mode triggers ExportDatePickerModal for Dari and Sampai', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ExportDataScreen(
            initialIsLoading: false,
            initialIsExport: true,
            initialExportPeriod: 'Rentang',
            initialExportFormat: 'CSV',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check initial date buttons
      expect(find.text('Dari'), findsOneWidget);
      expect(find.text('01 Okt 2026'), findsOneWidget);
      expect(find.text('Sampai'), findsOneWidget);
      expect(find.text('09 Okt 2026'), findsOneWidget);

      // Tap 'Dari' button (01 Okt 2026)
      await tester.tap(find.text('01 Okt 2026'));
      await tester.pumpAndSettle();

      // Modal should appear with 'Pilih Tanggal Mulai'
      expect(find.text('Pilih Tanggal Mulai'), findsOneWidget);
      expect(find.text('TANGGAL'), findsOneWidget);
      expect(find.text('BULAN'), findsOneWidget);
      expect(find.text('TAHUN'), findsOneWidget);

      // Tap 'Terapkan'
      await tester.tap(find.text('Terapkan'));
      await tester.pumpAndSettle();

      // Tap 'Sampai' button (09 Okt 2026)
      await tester.tap(find.text('09 Okt 2026'));
      await tester.pumpAndSettle();

      // Modal should appear with 'Pilih Tanggal Selesai'
      expect(find.text('Pilih Tanggal Selesai'), findsOneWidget);

      // Tap 'Terapkan'
      await tester.tap(find.text('Terapkan'));
      await tester.pumpAndSettle();

      // Still in screen
      expect(find.text('Dari'), findsOneWidget);
      expect(find.text('Sampai'), findsOneWidget);
    });

    testWidgets('ExportDataScreen in Bulan mode triggers ReportMonthPickerModal and updates selected month', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ExportDataScreen(
            initialIsLoading: false,
            initialIsExport: true,
            initialExportPeriod: 'Bulan',
            initialExportFormat: 'PDF',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check initial month pill button and verify count is removed
      expect(find.text('Oktober 2026'), findsOneWidget);
      expect(find.text('24 transaksi'), findsNothing);

      // Tap 'Oktober 2026' pill button
      await tester.tap(find.text('Oktober 2026'));
      await tester.pumpAndSettle();

      // Modal should appear with 'Pilih Periode', 'BULAN', and 'TAHUN'
      expect(find.text('Pilih Periode'), findsOneWidget);
      expect(find.text('BULAN'), findsOneWidget);
      expect(find.text('TAHUN'), findsOneWidget);
      expect(find.text('Terapkan'), findsOneWidget);

      // Tap on month "Sep"
      await tester.tap(find.text('Sep'));
      await tester.pumpAndSettle();

      // Tap 'Terapkan'
      await tester.tap(find.text('Terapkan'));
      await tester.pumpAndSettle();

      // Button should now display "September 2026"
      expect(find.text('September 2026'), findsOneWidget);
    });

    testWidgets('ExportDataScreen in Tahun mode triggers YearPickerModal and updates selected year', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ExportDataScreen(
            initialIsLoading: false,
            initialIsExport: true,
            initialExportPeriod: 'Tahun',
            initialExportFormat: 'PDF',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Check initial year pill button and verify count is removed
      expect(find.text('Tahun 2026'), findsOneWidget);
      expect(find.text('288 transaksi'), findsNothing);

      // Tap 'Tahun 2026' pill button
      await tester.tap(find.text('Tahun 2026'));
      await tester.pumpAndSettle();

      // Modal should appear with 'Pilih Tahun', 'TAHUN', and 'Terapkan'
      expect(find.text('Pilih Tahun'), findsOneWidget);
      expect(find.text('TAHUN'), findsOneWidget);
      expect(find.text('Terapkan'), findsOneWidget);

      // Tap on year "2025"
      await tester.tap(find.text('2025'));
      await tester.pumpAndSettle();

      // Tap 'Terapkan'
      await tester.tap(find.text('Terapkan'));
      await tester.pumpAndSettle();

      // Button should now display "Tahun 2025"
      expect(find.text('Tahun 2025'), findsOneWidget);
    });
  });
}
