import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_finance/core/theme/app_theme.dart';
import 'package:track_finance/features/category/presentation/screens/category_screen.dart';
import 'package:track_finance/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:track_finance/features/profile/presentation/screens/profile_screen.dart';
import 'package:track_finance/features/transaction/presentation/screens/add_transaction_screen.dart';
import 'package:track_finance/features/export/presentation/screens/export_data_screen.dart';
import 'package:track_finance/features/export/presentation/widgets/export_import_success_dialog.dart';
import 'package:track_finance/features/report/presentation/screens/report_screen.dart';
import 'package:track_finance/features/dashboard/data/dashboard_transaction_model.dart';
import 'package:track_finance/features/transaction/data/transaction_action_result.dart';
import 'package:track_finance/features/transaction/presentation/widgets/transaction_delete_dialog.dart';
import 'package:track_finance/main.dart';

import 'package:track_finance/features/category/presentation/widgets/category_empty_state.dart';
import 'package:track_finance/features/splash/presentation/screens/splash_screen.dart';
import 'package:track_finance/features/dashboard/presentation/widgets/header_time_theme.dart';
import 'package:track_finance/features/dashboard/presentation/widgets/header_time_background.dart';

void main() {
  testWidgets('Splash screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TrackFinanceApp(initialRoute: '/splash'));
    await tester.pump(const Duration(milliseconds: 500));

    // Verify brand texts and elements on splash screen
    expect(find.text('Track'), findsOneWidget);
    expect(find.text('Finance'), findsOneWidget);
    expect(find.byType(SplashScreen), findsOneWidget);
  });

  testWidgets('Login screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TrackFinanceApp(initialRoute: '/login'));

    // Verify that the welcome text and sign-in button are present
    expect(find.textContaining('Selamat datang di'), findsOneWidget);
    expect(find.textContaining('Track Finance'), findsOneWidget);
    expect(find.text('Catat uangmu dengan tenang dan rapi.'), findsOneWidget);
    expect(find.text('Login dengan Google'), findsOneWidget);
  });

  testWidgets('Dashboard screen smoke test', (WidgetTester tester) async {
    // Set realistic mobile phone screen size for widget test
    tester.view.physicalSize = const Size(1080, 5000);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const DashboardScreen(),
      ),
    );
    // Let one-shot entrance & count-up animations finish.
    // (pumpAndSettle would time out because of repeating pulse animations.)
    await tester.pump(const Duration(seconds: 3));

    // Verify dashboard elements
    expect(find.textContaining('Selamat'), findsOneWidget);
    expect(find.text('Pemasukan'), findsOneWidget);
    expect(find.text('Pengeluaran'), findsOneWidget);
    expect(find.textContaining('1.525.000'), findsWidgets);
    expect(find.textContaining('361.666'), findsWidgets);
    expect(find.text('Cari transaksi...'), findsOneWidget);
    expect(find.text('Oktober 2026'), findsOneWidget);
    expect(find.text('Hari'), findsOneWidget);
    expect(find.text('Minggu'), findsOneWidget);
    expect(find.text('Bulan'), findsOneWidget);
    expect(find.text('Tahun'), findsOneWidget);
    expect(find.text('Tambah'), findsOneWidget);
    expect(find.text('Kategori'), findsOneWidget);
    expect(find.text('Ekspor/Impor'), findsOneWidget);
    expect(find.text('Laporan'), findsOneWidget);
    expect(find.text('07 Oktober 2026'), findsOneWidget);
    expect(find.text('Makanan & Minuman'), findsWidgets);
    expect(find.text('Transportasi'), findsOneWidget);
    expect(find.text('Gaji & Pendapatan'), findsOneWidget);
  });

  testWidgets('Dashboard screen skeleton loading smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const DashboardScreen(isLoading: true),
      ),
    );

    // Verify skeleton widget is active
    expect(find.byKey(const ValueKey('skeleton')), findsOneWidget);
    expect(find.byKey(const ValueKey('content')), findsNothing);
  });

  testWidgets('Profile screen smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const ProfileScreen(),
      ),
    );

    // Verify profile elements
    expect(find.text('Alex Pratama'), findsOneWidget);
    expect(find.text('alex.pratama@email.com'), findsOneWidget);
    expect(find.text('Keluar'), findsOneWidget);
    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
  });

  testWidgets('Category screen smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const CategoryScreen(),
      ),
    );

    await tester.pump(const Duration(seconds: 1));

    // Verify header and instruction
    expect(find.text('Kategori'), findsOneWidget);
    expect(find.text('Ketuk kategori untuk mengubah atau menghapus'), findsOneWidget);

    // Verify tabs
    expect(find.textContaining('Pengeluaran (8)'), findsOneWidget);
    expect(find.textContaining('Pemasukan (6)'), findsOneWidget);

    // Verify default expense categories
    expect(find.text('Makanan & Minuman'), findsOneWidget);
    expect(find.text('Transportasi'), findsOneWidget);
    expect(find.text('Belanja Harian'), findsOneWidget);
    expect(find.text('Lainnya'), findsOneWidget);

    // Verify add category tile
    expect(find.text('Tambah'), findsOneWidget);

    // Verify budget tips card
    expect(find.text('Tips Manajemen Anggaran'), findsOneWidget);

    // Test tab switch to Pemasukan
    await tester.tap(find.textContaining('Pemasukan'));
    await tester.pumpAndSettle();

    expect(find.text('Gaji Pokok'), findsOneWidget);
    expect(find.text('Bonus'), findsOneWidget);
    expect(find.text('Investasi'), findsOneWidget);
  });

  testWidgets('Category screen skeleton loading test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const CategoryScreen(isLoading: true),
      ),
    );

    await tester.pump();

    // Verify skeleton widget is active saat isLoading: true
    expect(find.byKey(const ValueKey('skeleton')), findsOneWidget);
    expect(find.byKey(const ValueKey('content')), findsNothing);

    // Pump ulang dengan isLoading: false
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const CategoryScreen(isLoading: false),
      ),
    );
    await tester.pump(const Duration(seconds: 1));

    expect(find.byKey(const ValueKey('content')), findsOneWidget);
    expect(find.text('Kategori'), findsOneWidget);
  });

  testWidgets('Category screen empty state test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(() => tester.view.resetPhysicalSize());

    // Import widget empty state directly to verify
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: CategoryEmptyState(
            isExpense: false,
            onAddCategory: () {},
            onAddQuickCategory: (_, _, _) {},
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.text('Belum ada kategori pemasukan'), findsOneWidget);
    expect(find.text('Tambah Kategori'), findsOneWidget);
    expect(find.text('SARAN KATEGORI CEPAT'), findsOneWidget);
    expect(find.text('Gaji Pokok'), findsOneWidget);
  });

  testWidgets('Add Transaction screen smoke test & interactions', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const AddTransactionScreen(),
      ),
    );

    // Let one-shot entrance animations finish
    await tester.pump(const Duration(seconds: 2));

    // Verify header
    expect(find.text('Tambah Transaksi'), findsOneWidget);

    // Verify Segmented control
    expect(find.text('Pengeluaran'), findsOneWidget);
    expect(find.text('Pemasukan'), findsOneWidget);

    // Verify Amount Hero Card
    expect(find.text('Nominal Transaksi'), findsOneWidget);
    expect(find.text('Keluar'), findsOneWidget);
    expect(find.text('Rp'), findsOneWidget);
    expect(find.text('150.000'), findsOneWidget);

    // Verify Quick Chips
    expect(find.text('+10.000'), findsOneWidget);
    expect(find.text('+20.000'), findsOneWidget);
    expect(find.text('+50.000'), findsOneWidget);
    expect(find.text('+100.000'), findsOneWidget);
    expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);

    // Verify Category section
    expect(find.text('Kategori'), findsOneWidget);
    expect(find.text('Kelola Kategori & Ikon'), findsOneWidget);
    expect(find.text('Makanan'), findsOneWidget);
    expect(find.text('Belanja'), findsOneWidget);

    // Verify Additional Details
    expect(find.text('Tanggal'), findsOneWidget);
    expect(find.text('24 Mei 2025'), findsOneWidget);
    expect(find.text('Waktu'), findsOneWidget);
    expect(find.text('14.30'), findsOneWidget);
    expect(find.text('Catatan (opsional)'), findsOneWidget);

    // Verify CTA Button
    expect(find.text('Simpan Transaksi'), findsOneWidget);

    // Test Quick Add +50.000 -> 150.000 + 50.000 = 200.000
    await tester.tap(find.text('+50.000'));
    await tester.pump();
    expect(find.text('200.000'), findsOneWidget);

    // Test Clear button
    await tester.tap(find.byIcon(Icons.backspace_outlined));
    await tester.pump();
    final amountEditable = tester.widgetList<EditableText>(find.byType(EditableText)).first;
    expect(amountEditable.controller.text, '0');

    // Test Quick Add +10.000 -> 10.000
    await tester.tap(find.text('+10.000'));
    await tester.pump();
    expect(amountEditable.controller.text, '10.000');

    // Test tab switch to Pemasukan
    await tester.tap(find.text('Pemasukan'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Kas Masuk'), findsOneWidget);
    expect(find.text('Gaji'), findsOneWidget);
    expect(find.text('Bonus'), findsOneWidget);
  });

  testWidgets('Add Transaction skeleton loading test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const AddTransactionScreen(initialIsLoading: true),
      ),
    );

    await tester.pump();

    // Verify skeleton widget is active
    expect(find.byKey(const ValueKey('skeleton')), findsOneWidget);
    expect(find.byKey(const ValueKey('content')), findsNothing);

    // Rebuild with content loaded (initialIsLoading: false)
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const AddTransactionScreen(initialIsLoading: false),
      ),
    );
    await tester.pump(const Duration(seconds: 2));

    expect(find.byKey(const ValueKey('content')), findsOneWidget);
    expect(find.text('Nominal Transaksi'), findsOneWidget);

    // Test tapping 'Lainnya' opens AllCategoriesBottomSheet
    expect(find.text('Lainnya'), findsOneWidget);
    await tester.tap(find.text('Lainnya'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Semua Kategori Pengeluaran'), findsOneWidget);

    // Close bottom sheet
    await tester.tap(find.text('Donasi & Amal'));
    await tester.pumpAndSettle();

    // Test tapping Tanggal opens TransactionDatePickerModal (Only Date)
    await tester.tap(find.text('Tanggal'));
    await tester.pumpAndSettle();
    expect(find.text('Pilih Tanggal'), findsOneWidget);
    expect(find.text('WAKTU (WIB)'), findsNothing); // Verify no time stepper in date picker

    // Close date picker
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();

    // Test tapping Waktu opens TransactionTimePickerModal (Only Time)
    await tester.tap(find.text('Waktu'));
    await tester.pumpAndSettle();
    expect(find.text('Pilih Waktu'), findsOneWidget);
    expect(find.text('WAKTU TRANSAKSI (WIB)'), findsOneWidget);

    // Close time picker
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
  });

  testWidgets('Export data screen with uploaded file state & interactions', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const ExportDataScreen(initialIsLoading: false, initialHasFile: true),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Title & Header
    expect(find.text('Ekspor & Impor'), findsOneWidget);

    // Verify Uploaded File Card Info
    expect(find.text('transaksi_oktober.csv'), findsOneWidget);
    expect(find.text('128 baris terdeteksi'), findsOneWidget);

    // Verify 3 Validation Stats Boxes
    expect(find.text('120'), findsOneWidget);
    expect(find.text('VALID'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('DUPLIKAT'), findsOneWidget);
    expect(find.text('3'), findsOneWidget);
    expect(find.text('BERMASALAH'), findsOneWidget);

    // Verify Problematic Rows Link
    expect(find.text('Lihat baris bermasalah'), findsOneWidget);

    // Verify Data Preview Section
    expect(find.text('Pratinjau Data'), findsOneWidget);
    expect(find.text('Menampilkan 3 dari 120'), findsOneWidget);
    expect(find.text('Makanan & Minuman'), findsOneWidget);
    expect(find.text('-Rp21.000'), findsOneWidget);
    expect(find.text('Transportasi'), findsOneWidget);
    expect(find.text('-Rp35.000'), findsOneWidget);
    expect(find.text('Gaji & Pendapatan'), findsOneWidget);
    expect(find.text('+Rp1.500.000'), findsOneWidget);

    // Verify Bottom Active CTA Button
    expect(find.text('Impor 120 Transaksi'), findsOneWidget);

    // Test Tapping "Lihat baris bermasalah" opens bottom sheet
    await tester.tap(find.text('Lihat baris bermasalah'));
    await tester.pumpAndSettle();
    expect(find.text('Baris Bermasalah (3)'), findsOneWidget);
    expect(find.textContaining('Nominal tidak valid'), findsOneWidget);
    expect(find.text('Mengerti'), findsOneWidget);

    // Close bottom sheet
    await tester.tap(find.text('Mengerti'));
    await tester.pumpAndSettle();
    expect(find.text('Baris Bermasalah (3)'), findsNothing);

    // Test Tapping "Impor 120 Transaksi" opens success modal
    await tester.tap(find.text('Impor 120 Transaksi'));
    await tester.pump(const Duration(milliseconds: 1100));
    await tester.pumpAndSettle();
    expect(find.text('120 transaksi diimpor'), findsOneWidget);
    expect(find.text('Selesai'), findsOneWidget);

    // Close success modal
    await tester.tap(find.text('Selesai'));
    await tester.pumpAndSettle();

    // Clear any active toast timers
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('Export data screen empty state smoke test & interactions', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const ExportDataScreen(
          initialIsLoading: false,
          initialHasFile: false,
          initialIsExport: false,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Empty State Drop Zone
    expect(find.text('Pilih file CSV'), findsOneWidget);
    expect(find.text('Maks. 5 MB'), findsOneWidget);

    // Verify Template Action
    expect(find.text('Unduh template'), findsOneWidget);

    // Verify Format CSV Table Specification
    expect(find.text('Format CSV'), findsOneWidget);
    expect(find.text('PENGELUARAN'), findsOneWidget);

    // Test Tapping "Unduh template" triggers toast
    await tester.tap(find.text('Unduh template'));
    await tester.pump();
    expect(find.textContaining('Template CSV berhasil diunduh'), findsOneWidget);

    // Test Switching Tab to "Ekspor"
    await tester.tap(find.text('Ekspor'));
    await tester.pumpAndSettle();
    expect(find.text('Periode'), findsOneWidget);
    expect(find.text('Rentang'), findsOneWidget);
    expect(find.text('Bulan'), findsOneWidget);
    expect(find.text('Tahun'), findsOneWidget);
    expect(find.text('Format'), findsOneWidget);
    expect(find.textContaining('Ekspor'), findsWidgets);

    // Test Switching back to "Impor"
    await tester.tap(find.text('Impor'));
    await tester.pumpAndSettle();
    expect(find.text('Pilih file CSV'), findsOneWidget);

    // Test Tapping Drop Zone loads file
    await tester.tap(find.text('Pilih file CSV'));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();
    expect(find.text('transaksi_oktober.csv'), findsOneWidget);

    // Clear any active toast timers
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('Export tab smoke test, range filters, format selection & execution', (WidgetTester tester) async {
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

    // Verify Period Section & Sub-Segmented Tabs
    expect(find.text('Periode'), findsOneWidget);
    expect(find.text('Filter Waktu'), findsOneWidget);
    expect(find.text('Rentang'), findsOneWidget);
    expect(find.text('Bulan'), findsOneWidget);
    expect(find.text('Tahun'), findsOneWidget);

    // Verify 2-Column Date Inputs
    expect(find.text('Dari'), findsOneWidget);
    expect(find.text('01 Okt 2026'), findsOneWidget);
    expect(find.text('Sampai'), findsOneWidget);
    expect(find.text('09 Okt 2026'), findsOneWidget);

    // Verify Active Chips & Insight Well
    expect(find.text('9 transaksi ditemukan'), findsOneWidget);
    expect(find.text('Jika kosong: 0 data'), findsOneWidget);
    expect(find.text('Estimasi Total Rentang'), findsOneWidget);
    expect(find.text('Rp 3.840.000'), findsOneWidget);
    expect(find.text('Tersinkron'), findsOneWidget);

    // Verify Format Selector
    expect(find.text('Format'), findsOneWidget);
    expect(find.text('PDF'), findsOneWidget);
    expect(find.text('CSV'), findsOneWidget);

    // Verify Bottom CTA Button
    expect(find.text('Ekspor CSV'), findsOneWidget);
    expect(find.text('Ukuran file diperkirakan ~14 KB'), findsOneWidget);

    // Test Selecting Format PDF
    await tester.tap(find.text('PDF'));
    await tester.pumpAndSettle();
    expect(find.text('Ekspor PDF'), findsOneWidget);
    expect(find.text('Ukuran file diperkirakan ~280 KB'), findsOneWidget);

    // Test Selecting Format CSV back
    await tester.tap(find.text('CSV'));
    await tester.pumpAndSettle();
    expect(find.text('Ekspor CSV'), findsOneWidget);

    // Test Tapping "Bulan" period tab
    await tester.tap(find.text('Bulan'));
    await tester.pumpAndSettle();
    expect(find.text('24 transaksi'), findsOneWidget);
    expect(find.text('Oktober 2026'), findsOneWidget);

    // Test Switching back to "Rentang"
    await tester.tap(find.text('Rentang'));
    await tester.pumpAndSettle();
    expect(find.text('9 transaksi ditemukan'), findsOneWidget);

    // Test Executing Export
    await tester.tap(find.text('Ekspor CSV'));
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();

    // Verify Success Modal
    expect(find.text('9 transaksi diekspor'), findsOneWidget);
    expect(find.text('Selesai'), findsOneWidget);

    // Close Modal
    await tester.tap(find.text('Selesai'));
    await tester.pumpAndSettle();
  });

  testWidgets('Export tab with Month (Bulan) filter active state & interactions', (WidgetTester tester) async {
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

    // Verify Title & Header
    expect(find.text('Ekspor & Impor'), findsOneWidget);

    // Verify Periode & Tabs
    expect(find.text('Periode'), findsOneWidget);
    expect(find.text('Rentang'), findsOneWidget);
    expect(find.text('Bulan'), findsOneWidget);
    expect(find.text('Tahun'), findsOneWidget);

    // Verify Month Selector Card ("Oktober 2026")
    expect(find.text('Oktober 2026'), findsOneWidget);

    // Verify Transaction Count Badge ("24 transaksi")
    expect(find.text('24 transaksi'), findsOneWidget);

    // Verify Format Section (PDF selected, CSV unselected)
    expect(find.text('Format'), findsOneWidget);
    expect(find.text('PDF'), findsOneWidget);
    expect(find.text('CSV'), findsOneWidget);

    // Verify Bottom CTA Button ("Ekspor PDF")
    expect(find.text('Ekspor PDF'), findsOneWidget);

    // Test Tapping "Oktober 2026" opens MonthPickerModal
    await tester.tap(find.text('Oktober 2026'));
    await tester.pumpAndSettle();
    expect(find.text('2026'), findsOneWidget);
    expect(find.text('September'), findsOneWidget);

    // Select "September"
    await tester.tap(find.text('September'));
    await tester.pumpAndSettle();
    expect(find.text('September 2026'), findsOneWidget);

    // Test Selecting Format CSV
    await tester.tap(find.text('CSV'));
    await tester.pumpAndSettle();
    expect(find.text('Ekspor CSV'), findsOneWidget);

    // Test Executing Export
    await tester.tap(find.text('Ekspor CSV'));
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();
    expect(find.text('18 transaksi diekspor'), findsOneWidget);
    expect(find.text('Selesai'), findsOneWidget);

    // Close Modal
    await tester.tap(find.text('Selesai'));
    await tester.pumpAndSettle();
  });

  testWidgets('Export tab with Year (Tahun) filter active state & interactions', (WidgetTester tester) async {
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

    // Verify Title & Header
    expect(find.text('Ekspor & Impor'), findsOneWidget);

    // Verify Periode & Tabs
    expect(find.text('Periode'), findsOneWidget);
    expect(find.text('Rentang'), findsOneWidget);
    expect(find.text('Bulan'), findsOneWidget);
    expect(find.text('Tahun'), findsOneWidget);

    // Verify Year Selector Card ("Tahun 2026", "Januari - Desember 2026")
    expect(find.text('Tahun 2026'), findsOneWidget);
    expect(find.text('Januari - Desember 2026'), findsOneWidget);

    // Verify Transaction Count & Active Months
    expect(find.text('288 transaksi ditemukan'), findsOneWidget);
    expect(find.text('12 Bulan Aktif'), findsOneWidget);

    // Verify Estimasi Total Card & Tersinkron Badge
    expect(find.text('Estimasi Total Tahun 2026'), findsOneWidget);
    expect(find.text('Rp 45.600.000'), findsOneWidget);
    expect(find.text('Tersinkron'), findsOneWidget);

    // Verify Format Section (PDF selected, CSV unselected)
    expect(find.text('Format'), findsOneWidget);
    expect(find.text('PDF'), findsOneWidget);
    expect(find.text('CSV'), findsOneWidget);

    // Verify Bottom CTA Button ("Ekspor PDF")
    expect(find.text('Ekspor PDF'), findsOneWidget);

    // Test Tapping "Tahun 2026" opens YearPickerModal
    await tester.tap(find.text('Tahun 2026'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Pilih Tahun'), findsOneWidget);
    expect(find.text('2025'), findsOneWidget);

    // Select "2025"
    await tester.tap(find.text('2025'));
    await tester.pumpAndSettle();
    expect(find.text('Tahun 2025'), findsOneWidget);
    expect(find.text('Januari - Desember 2025'), findsOneWidget);

    // Test Selecting Format CSV
    await tester.tap(find.text('CSV'));
    await tester.pumpAndSettle();
    expect(find.text('Ekspor CSV'), findsOneWidget);

    // Test Executing Export
    await tester.tap(find.text('Ekspor CSV'));
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();
    expect(find.text('288 transaksi diekspor'), findsOneWidget);
    expect(find.text('Selesai'), findsOneWidget);

    // Close Modal
    await tester.tap(find.text('Selesai'));
    await tester.pumpAndSettle();
  });

  testWidgets('Export data screen skeleton loading test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const ExportDataScreen(initialIsLoading: true, initialIsExport: true),
      ),
    );

    await tester.pump(const Duration(milliseconds: 100));

    // Skeleton active
    expect(find.byKey(const ValueKey('skeleton_export')), findsOneWidget);
    expect(find.byKey(const ValueKey('content')), findsNothing);
  });

  testWidgets('ExportImportSuccessDialog direct smoke test & dismiss', (WidgetTester tester) async {
    bool doneCalled = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                ExportImportSuccessDialog.show(
                  context,
                  message: '120 transaksi diimpor',
                  onDone: () {
                    doneCalled = true;
                    Navigator.of(context).pop();
                  },
                );
              },
              child: const Text('Show Dialog'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Show Dialog'));
    await tester.pumpAndSettle();

    expect(find.text('120 transaksi diimpor'), findsOneWidget);
    expect(find.text('Selesai'), findsOneWidget);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    await tester.tap(find.text('Selesai'));
    await tester.pumpAndSettle();

    expect(doneCalled, isTrue);
    expect(find.text('120 transaksi diimpor'), findsNothing);
  });

  testWidgets('Report screen empty state smoke test & UI verification', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const ReportScreen(initialMonthIndex: 8), // September 2026 = Kosong
      ),
    );

    await tester.pumpAndSettle();

    // Verify Header
    expect(find.text('Laporan'), findsOneWidget);
    expect(find.byIcon(Icons.chevron_left_rounded), findsOneWidget);

    // Verify Month Filter Pill & Archive Status
    expect(find.text('Sep 2026'), findsOneWidget);
    expect(find.byIcon(Icons.calendar_month_rounded), findsOneWidget);
    expect(find.text('Arsip Non-Aktif'), findsOneWidget);

    // Verify Card 1: Tren Keuangan (Empty State)
    expect(find.text('Tren Keuangan'), findsOneWidget);
    expect(find.text('Keluar'), findsWidgets); // di legend tren & tab struktur
    expect(find.text('Masuk'), findsWidgets);
    expect(find.text('75k'), findsOneWidget);
    expect(find.text('50k'), findsOneWidget);
    expect(find.text('25k'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('Belum ada transaksi'), findsOneWidget);
    expect(find.text('Pengeluaran'), findsOneWidget);
    expect(find.text('Pemasukan'), findsOneWidget);

    // Verify Card 2: Struktur Transaksi (Empty State)
    expect(find.text('Struktur Transaksi'), findsOneWidget);
    expect(find.text('Total Terkategori'), findsOneWidget);

    // Verify Card 3: Indikator Kesehatan (Empty State)
    expect(find.text('Indikator Kesehatan'), findsOneWidget);
    expect(find.text('Belum ada data'), findsOneWidget);
    expect(find.text('0%'), findsOneWidget);
    expect(find.text('Skor: -'), findsOneWidget);
    expect(find.text('100%'), findsOneWidget);
  });

  testWidgets('Report screen populated Keluar (Pengeluaran) state test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const ReportScreen(
          initialMonthIndex: 9, // Oktober 2026
          initialIsExpenseTab: true, // Keluar
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Header & Filter
    expect(find.text('Okt 2026'), findsOneWidget);

    // Card 1: Tren Keuangan (Populated Keluar)
    expect(find.text('Tren Keuangan'), findsOneWidget);
    expect(find.text('120k'), findsOneWidget);
    expect(find.text('80k'), findsOneWidget);
    expect(find.text('40k'), findsOneWidget);
    expect(find.text('01'), findsOneWidget);
    expect(find.text('02'), findsOneWidget);
    expect(find.text('05'), findsOneWidget);
    expect(find.text('06'), findsOneWidget);
    expect(find.text('07'), findsOneWidget);
    expect(find.text('Rp 248.466'), findsWidgets); // di summary & donut

    // Card 2: Struktur Transaksi (Populated Keluar 4 Kategori)
    expect(find.text('Struktur Transaksi'), findsOneWidget);
    expect(find.text('Makanan & Minuman'), findsOneWidget);
    expect(find.text('39.0%'), findsOneWidget);
    expect(find.text('Rp 97.000'), findsOneWidget);
    expect(find.text('Transportasi'), findsOneWidget);
    expect(find.text('29.3%'), findsOneWidget);
    expect(find.text('Rp 72.666'), findsOneWidget);
    expect(find.text('Belanja'), findsOneWidget);
    expect(find.text('27.7%'), findsOneWidget);
    expect(find.text('Rp 68.800'), findsOneWidget);
    expect(find.text('Tagihan'), findsOneWidget);
    expect(find.text('4.0%'), findsOneWidget);
    expect(find.text('Rp 10.000'), findsOneWidget);

    // Card 3: Indikator Kesehatan (Minus Kritis)
    expect(find.text('Indikator Kesehatan'), findsOneWidget);
    expect(find.text('Minus Kritis'), findsOneWidget);
    expect(find.text('Skor: -100.0%'), findsOneWidget);
  });

  testWidgets('Report screen populated Masuk (Pemasukan) state test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const ReportScreen(
          initialMonthIndex: 9, // Oktober 2026
          initialIsExpenseTab: false, // Masuk
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Card 1: Tren Keuangan (Dual Bars 6jt scale)
    expect(find.text('6jt'), findsOneWidget);
    expect(find.text('4jt'), findsOneWidget);
    expect(find.text('2jt'), findsOneWidget);
    expect(find.text('Rp 5.000.000'), findsWidgets); // di summary & donut

    // Card 2: Struktur Transaksi (Populated Masuk 3 Kategori)
    expect(find.text('Gaji'), findsOneWidget);
    expect(find.text('90.0%'), findsOneWidget);
    expect(find.text('Rp 4.500.000'), findsOneWidget);
    expect(find.text('Freelance'), findsOneWidget);
    expect(find.text('8.0%'), findsOneWidget);
    expect(find.text('Rp 400.000'), findsOneWidget);
    expect(find.text('Hadiah'), findsOneWidget);
    expect(find.text('2.0%'), findsOneWidget);
    expect(find.text('Rp 100.000'), findsOneWidget);

    // Card 3: Indikator Kesehatan (Sehat 95%)
    expect(find.text('Sehat'), findsOneWidget);
    expect(find.text('Skor: 95.0%'), findsOneWidget);
  });

  testWidgets('Report screen skeleton loading smoke test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const ReportScreen(initialIsLoading: true),
      ),
    );

    await tester.pump();

    // Verify skeleton active
    expect(find.byKey(const ValueKey('skeleton')), findsOneWidget);
    expect(find.byKey(const ValueKey('content')), findsNothing);
  });

  testWidgets('Report screen structure card segmented toggle interaction', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const ReportScreen(
          initialMonthIndex: 9,
          initialIsExpenseTab: true,
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Initially in Keluar mode: shows Minus Kritis & Makanan & Minuman
    expect(find.text('Minus Kritis'), findsOneWidget);
    expect(find.text('Makanan & Minuman'), findsOneWidget);

    // Tap "Masuk" on Struktur Transaksi tab
    await tester.tap(find.text('Masuk').last);
    await tester.pumpAndSettle();

    // Verify switched to Masuk mode: shows Sehat & Gaji
    expect(find.text('Sehat'), findsOneWidget);
    expect(find.text('Gaji'), findsOneWidget);

    // Tap "Keluar" on Struktur Transaksi tab
    await tester.tap(find.text('Keluar').last);
    await tester.pumpAndSettle();

    expect(find.text('Minus Kritis'), findsOneWidget);
    expect(find.text('Makanan & Minuman'), findsOneWidget);
  });

  testWidgets('Report screen Month and Year Picker Modal interactions & apply', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const ReportScreen(initialMonthIndex: 8),
      ),
    );

    await tester.pumpAndSettle();

    // Tap on the Month filter pill ("Sep 2026")
    await tester.tap(find.text('Sep 2026'));
    await tester.pumpAndSettle();

    // Verify MonthPickerModal is displayed
    expect(find.text('2026'), findsOneWidget);
    expect(find.text('Rentang Terpilih'), findsOneWidget);
    expect(find.text('1 Sep - 30 Sep 2026'), findsOneWidget);
    expect(find.text('Terapkan'), findsOneWidget);

    // Tap next year button (chevron_right_rounded)
    await tester.tap(find.byIcon(Icons.chevron_right_rounded));
    await tester.pumpAndSettle();
    expect(find.text('2027'), findsOneWidget);
    expect(find.text('1 Sep - 30 Sep 2027'), findsOneWidget);

    // Tap prev year button (chevron_left_rounded)
    await tester.tap(find.byIcon(Icons.chevron_left_rounded).last);
    await tester.pumpAndSettle();
    expect(find.text('2026'), findsOneWidget);

    // Tap on month "Okt"
    await tester.tap(find.text('Okt'));
    await tester.pumpAndSettle();
    expect(find.text('1 Okt - 31 Okt 2026'), findsOneWidget);

    // Tap on "Terapkan" button
    await tester.tap(find.text('Terapkan'));
    await tester.pumpAndSettle();

    // Modal should close and the Report screen should now display "Okt 2026"
    expect(find.text('Rentang Terpilih'), findsNothing);
    expect(find.text('Okt 2026'), findsOneWidget);
  });

  testWidgets('Dashboard to Report screen navigation test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const DashboardScreen(),
      ),
    );

    // Allow animations to finish
    await tester.pump(const Duration(seconds: 3));

    // Find and tap "Laporan" shortcut
    expect(find.text('Laporan'), findsOneWidget);
    await tester.tap(find.text('Laporan'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify we arrived on the Report screen
    expect(find.text('Tren Keuangan'), findsOneWidget);
    expect(find.text('Struktur Transaksi'), findsOneWidget);
    expect(find.text('Indikator Kesehatan'), findsOneWidget);

    // Tap back button
    await tester.tap(find.byIcon(Icons.chevron_left_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Back to dashboard
    expect(find.text('Cari transaksi...'), findsOneWidget);
  });

  testWidgets('Edit Transaction screen pre-populates data and renders edit UI', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(() => tester.view.resetPhysicalSize());

    const sampleTx = DashboardTransaction(
      id: 'tx-test-1',
      dateStr: '07 Oktober 2026',
      dateKey: '2026-10-07',
      year: 2026,
      month: 9, // Oktober (0-based)
      day: 7,
      category: 'Makanan',
      meta: '16.03 · kopi hangat',
      amount: -45000,
      type: TransactionType.expense,
      icon: Icons.restaurant_rounded,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const AddTransactionScreen(transaction: sampleTx),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Edit Mode Header
    expect(find.text('Edit Transaksi'), findsOneWidget);
    expect(find.byIcon(Icons.delete_outline_rounded), findsWidgets);

    // Verify Pre-populated Nominal
    expect(find.text('45.000'), findsOneWidget);

    // Verify Pre-populated Note
    expect(find.text('kopi hangat'), findsOneWidget);

    // Verify CTA button text
    expect(find.text('Perbarui Transaksi'), findsOneWidget);
    expect(find.text('Hapus Transaksi'), findsOneWidget);
  });

  testWidgets('Delete Transaction flow shows confirmation dialog and confirms delete', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(() => tester.view.resetPhysicalSize());

    const sampleTx = DashboardTransaction(
      id: 'tx-test-2',
      dateStr: '07 Oktober 2026',
      dateKey: '2026-10-07',
      year: 2026,
      month: 9,
      day: 7,
      category: 'Makanan',
      meta: '12.00 · makan siang',
      amount: -75000,
      type: TransactionType.expense,
      icon: Icons.restaurant_rounded,
    );

    dynamic returnedResult;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(
          builder: (context) => Scaffold(
            body: ElevatedButton(
              onPressed: () async {
                returnedResult = await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddTransactionScreen(transaction: sampleTx),
                  ),
                );
              },
              child: const Text('Open Edit'),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Open edit screen
    await tester.tap(find.text('Open Edit'));
    await tester.pumpAndSettle();

    expect(find.text('Edit Transaksi'), findsOneWidget);

    // Tap on frosted delete button in header bar
    await tester.tap(find.byIcon(Icons.delete_outline_rounded).first);
    await tester.pumpAndSettle();

    // Verify dialog appears
    expect(find.byType(TransactionDeleteDialog), findsOneWidget);
    expect(find.text('Hapus Transaksi?'), findsOneWidget);
    expect(find.textContaining('akan dihapus secara permanen', findRichText: true), findsOneWidget);

    // Tap confirm "Hapus" button in dialog
    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();

    // Verify returned result is deleted
    expect(returnedResult, isA<TransactionActionResult>());
    expect((returnedResult as TransactionActionResult).isDeleted, isTrue);
    expect((returnedResult as TransactionActionResult).transactionId, 'tx-test-2');
  });

  testWidgets('Dashboard screen transaction card tap navigates to Edit Transaction', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 5000);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const DashboardScreen(),
      ),
    );
    await tester.pump(const Duration(seconds: 3));

    // Verify dashboard is loaded and a transaction card is visible
    expect(find.text('Makanan & Minuman'), findsWidgets);

    // Tap the first transaction card
    await tester.tap(find.text('Makanan & Minuman').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Verify Edit Transaksi screen is opened
    expect(find.text('Edit Transaksi'), findsOneWidget);
    expect(find.text('Perbarui Transaksi'), findsOneWidget);

    // Tap back button to return to dashboard
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    // Returned to dashboard
    expect(find.text('Cari transaksi...'), findsOneWidget);
  });

  testWidgets('Dashboard time-of-day automatic system theme test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const DashboardScreen(),
      ),
    );
    await tester.pump(const Duration(seconds: 3));

    // Verify background animation is present in header
    final timeBg = find.byType(HeaderTimeBackground);
    expect(timeBg, findsOneWidget);

    // Verify system automatic greeting is rendered based on current time
    final currentAuto = DashboardTimeOfDay.fromDateTime();
    expect(find.text(currentAuto.greeting), findsOneWidget);
  });

  testWidgets('Dashboard header time background renders all 4 periods correctly', (WidgetTester tester) async {
    for (final time in DashboardTimeOfDay.values) {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HeaderTimeBackground(timeOfDay: time),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(HeaderTimeBackground), findsOneWidget);
    }
  });

  test('DashboardTimeOfDay logic and time thresholds test', () {
    // Pagi: 04:00 - 10:59
    expect(DashboardTimeOfDay.fromDateTime(DateTime(2026, 10, 10, 4, 0)), DashboardTimeOfDay.pagi);
    expect(DashboardTimeOfDay.fromDateTime(DateTime(2026, 10, 10, 8, 30)), DashboardTimeOfDay.pagi);
    expect(DashboardTimeOfDay.fromDateTime(DateTime(2026, 10, 10, 10, 59)), DashboardTimeOfDay.pagi);

    // Siang: 11:00 - 14:59
    expect(DashboardTimeOfDay.fromDateTime(DateTime(2026, 10, 10, 11, 0)), DashboardTimeOfDay.siang);
    expect(DashboardTimeOfDay.fromDateTime(DateTime(2026, 10, 10, 13, 15)), DashboardTimeOfDay.siang);
    expect(DashboardTimeOfDay.fromDateTime(DateTime(2026, 10, 10, 14, 59)), DashboardTimeOfDay.siang);

    // Sore: 15:00 - 17:59
    expect(DashboardTimeOfDay.fromDateTime(DateTime(2026, 10, 10, 15, 0)), DashboardTimeOfDay.sore);
    expect(DashboardTimeOfDay.fromDateTime(DateTime(2026, 10, 10, 16, 45)), DashboardTimeOfDay.sore);
    expect(DashboardTimeOfDay.fromDateTime(DateTime(2026, 10, 10, 17, 59)), DashboardTimeOfDay.sore);

    // Malam: 18:00 - 03:59
    expect(DashboardTimeOfDay.fromDateTime(DateTime(2026, 10, 10, 18, 0)), DashboardTimeOfDay.malam);
    expect(DashboardTimeOfDay.fromDateTime(DateTime(2026, 10, 10, 23, 30)), DashboardTimeOfDay.malam);
    expect(DashboardTimeOfDay.fromDateTime(DateTime(2026, 10, 10, 0, 0)), DashboardTimeOfDay.malam);
    expect(DashboardTimeOfDay.fromDateTime(DateTime(2026, 10, 10, 3, 59)), DashboardTimeOfDay.malam);

    // Greetings
    expect(DashboardTimeOfDay.pagi.greeting, 'Selamat pagi,');
    expect(DashboardTimeOfDay.siang.greeting, 'Selamat siang,');
    expect(DashboardTimeOfDay.sore.greeting, 'Selamat sore,');
    expect(DashboardTimeOfDay.malam.greeting, 'Selamat malam,');
  });

  testWidgets('Dashboard return to today button appears when month/year filter is active and resets back to today', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const DashboardScreen(),
      ),
    );
    await tester.pump(const Duration(seconds: 3));

    // Initially on Hari, return to today button should NOT be present
    expect(find.text('Kembali ke Hari Ini'), findsNothing);

    // Tap on 'Bulan' filter pill
    await tester.tap(find.text('Bulan'));
    await tester.pump(const Duration(milliseconds: 300));

    // Now month filter is active, return to today button should appear
    expect(find.text('Kembali ke Hari Ini'), findsOneWidget);
    expect(find.textContaining('Filter Bulan aktif'), findsOneWidget);

    // Tap 'Kembali ke Hari Ini' button
    await tester.tap(find.text('Kembali ke Hari Ini'));
    await tester.pump(const Duration(milliseconds: 300));

    // Should return back to Hari and button disappears
    expect(find.text('Kembali ke Hari Ini'), findsNothing);

    // Now test 'Tahun' filter pill
    await tester.tap(find.text('Tahun'));
    await tester.pump(const Duration(milliseconds: 300));

    // Year filter is active, return to today button should appear
    expect(find.text('Kembali ke Hari Ini'), findsOneWidget);
    expect(find.textContaining('Filter Tahun aktif'), findsOneWidget);

    // Tap header today icon button
    await tester.tap(find.byIcon(Icons.today_rounded));
    await tester.pump(const Duration(milliseconds: 300));

    // Should return back to Hari and button disappears
    expect(find.text('Kembali ke Hari Ini'), findsNothing);
  });
}

