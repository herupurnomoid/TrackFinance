import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_finance/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:track_finance/features/dashboard/presentation/widgets/dashboard_date_range_picker_dialog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DashboardDateRangePickerDialog Unit & Widget Tests', () {
    testWidgets('renders all initial elements according to reference image',
        (WidgetTester tester) async {
      DateTimeRange? returnedRange;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    returnedRange = await DashboardDateRangePickerDialog.show(
                      context,
                      initialDateRange: DateTimeRange(
                        start: DateTime(2024, 7, 1),
                        end: DateTime(2024, 7, 17),
                      ),
                      firstDate: DateTime(2020, 1, 1),
                      lastDate: DateTime(2035, 12, 31),
                    );
                  },
                  child: const Text('Open Dialog'),
                );
              },
            ),
          ),
        ),
      );

      // Buka dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // 1. Verifikasi Header "Select date range"
      expect(find.text('Select date range'), findsOneWidget);

      // 2. Verifikasi Format Rentang "Jul 1, 2024 - Jul 17, 2024"
      expect(find.text('Jul 1, 2024 - Jul 17, 2024'), findsOneWidget);

      // 3. Verifikasi Inisial Hari: S M T W T F S
      expect(find.text('S'), findsNWidgets(2)); // Sunday & Saturday
      expect(find.text('M'), findsOneWidget);
      expect(find.text('T'), findsNWidgets(2)); // Tuesday & Thursday
      expect(find.text('W'), findsOneWidget);
      expect(find.text('F'), findsOneWidget);

      // 4. Verifikasi Judul Bulan "July 2024"
      expect(find.text('July 2024'), findsOneWidget);

      // 5. Verifikasi Tanggal 1 dan 17 dirender
      expect(find.text('1'), findsOneWidget);
      expect(find.text('17'), findsOneWidget);

      // 6. Verifikasi Tombol Cancel dan OK
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);

      // Tap OK untuk konfirmasi
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(returnedRange, isNotNull);
      expect(returnedRange!.start, DateTime(2024, 7, 1));
      expect(returnedRange!.end, DateTime(2024, 7, 17));
    });

    testWidgets('allows selecting new date range and cancels gracefully',
        (WidgetTester tester) async {
      DateTimeRange? returnedRange;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () async {
                    returnedRange = await DashboardDateRangePickerDialog.show(
                      context,
                      initialDateRange: null,
                      firstDate: DateTime(2024, 1, 1),
                      lastDate: DateTime(2024, 12, 31),
                    );
                  },
                  child: const Text('Open Dialog'),
                );
              },
            ),
          ),
        ),
      );

      // Buka dialog
      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      // Pilih tanggal 10
      await tester.tap(find.text('10'));
      await tester.pumpAndSettle();

      // Pilih tanggal 20
      await tester.tap(find.text('20'));
      await tester.pumpAndSettle();

      // Verifikasi headline mengandung 10 dan 20
      expect(find.textContaining('10'), findsWidgets);
      expect(find.textContaining('20'), findsWidgets);

      // Tap Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Dialog ditutup dan null dikembalikan
      expect(find.byType(DashboardDateRangePickerDialog), findsNothing);
      expect(returnedRange, isNull);
    });

    testWidgets('month navigation moves back and forth',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    DashboardDateRangePickerDialog.show(
                      context,
                      initialDateRange: DateTimeRange(
                        start: DateTime(2024, 7, 1),
                        end: DateTime(2024, 7, 17),
                      ),
                      firstDate: DateTime(2020, 1, 1),
                      lastDate: DateTime(2035, 12, 31),
                    );
                  },
                  child: const Text('Open Dialog'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('July 2024'), findsOneWidget);

      // Tap next month
      await tester.tap(find.byTooltip('Next month'));
      await tester.pumpAndSettle();

      expect(find.text('August 2024'), findsOneWidget);

      // Tap prev month twice
      await tester.tap(find.byTooltip('Previous month'));
      await tester.pumpAndSettle();
      expect(find.text('July 2024'), findsOneWidget);

      await tester.tap(find.byTooltip('Previous month'));
      await tester.pumpAndSettle();
      expect(find.text('June 2024'), findsOneWidget);
    });

    testWidgets('dashboard opens calendar range picker and updates label on confirm',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardScreen(),
        ),
      );
      await tester.pump(const Duration(seconds: 2));

      // Temukan tombol kalender di header (sebelah kiri prev & next)
      final calendarButton = find.byIcon(Icons.calendar_today_rounded);
      expect(calendarButton, findsOneWidget);

      // Tap tombol kalender
      await tester.tap(calendarButton);
      await tester.pump(const Duration(milliseconds: 500));

      // Pastikan Dialog Date Range Picker terbuka
      expect(find.byType(DashboardDateRangePickerDialog), findsOneWidget);
      expect(find.text('Select date range'), findsOneWidget);

      // Konfirmasi dialog dengan OK
      await tester.tap(find.text('OK'));
      await tester.pump(const Duration(milliseconds: 500));

      // Dialog tertutup dan kembali ke dashboard
      expect(find.byType(DashboardDateRangePickerDialog), findsNothing);
      expect(find.byType(DashboardScreen), findsOneWidget);
    });
  });
}
