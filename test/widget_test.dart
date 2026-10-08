import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_finance/core/theme/app_theme.dart';
import 'package:track_finance/features/category/presentation/screens/category_screen.dart';
import 'package:track_finance/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:track_finance/features/profile/presentation/screens/profile_screen.dart';
import 'package:track_finance/features/transaction/presentation/screens/add_transaction_screen.dart';
import 'package:track_finance/features/export/presentation/screens/export_data_screen.dart';
import 'package:track_finance/main.dart';

void main() {
  testWidgets('Login screen smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const TrackFinanceApp());

    // Verify that the welcome text and sign-in button are present
    expect(find.text('Selamat Datang'), findsOneWidget);
    expect(find.text('Sign in with Google'), findsOneWidget);
    expect(find.text('Aman & Terenkripsi'), findsOneWidget);
  });

  testWidgets('Dashboard screen smoke test', (WidgetTester tester) async {
    // Set realistic mobile phone screen size for widget test
    tester.view.physicalSize = const Size(1080, 2400);
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
    expect(find.text('Selamat Datang Kembali'), findsOneWidget);
    expect(find.textContaining('Selamat Pagi, Alex Pratama'), findsOneWidget);
    expect(find.textContaining('9.800.000'), findsWidgets);
    expect(find.textContaining('4.250.000'), findsWidgets);
    expect(find.text('Cari transaksi...'), findsOneWidget);
    expect(find.text('Mei 2024'), findsOneWidget);
    expect(find.text('Bulan'), findsOneWidget);
    expect(find.text('ANALISIS'), findsOneWidget);
    expect(find.text('Top Pengeluaran'), findsOneWidget);
    expect(find.text('Sangat Sehat'), findsOneWidget);
    expect(find.text('Skor 85 / 100'), findsOneWidget);
    expect(find.text('Menu'), findsOneWidget);
    expect(find.text('Kategori'), findsOneWidget);
    expect(find.text('Ekspor'), findsOneWidget);
    expect(find.text('Tanya AI'), findsOneWidget);
    expect(find.text('Tambah'), findsOneWidget);
    expect(find.text('Tren Arus Kas'), findsOneWidget);
    expect(find.text('10 Jt'), findsOneWidget);
    expect(find.text('5 Jt'), findsOneWidget);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('18 Mei'), findsOneWidget);
    expect(find.text('Distribusi Kategori'), findsOneWidget);
    expect(find.text('Rincian Transaksi'), findsOneWidget);
    expect(find.text('Belanja Bulanan'), findsOneWidget);
    expect(find.text('Pendapatan Freelance'), findsOneWidget);
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
    expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsOneWidget);
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

    // Let entrance animations finish
    await tester.pump(const Duration(seconds: 2));

    // Verify header and intro card
    expect(find.text('Atur Kategori & Alokasi'), findsOneWidget);
    expect(find.text('Alokasi & Kategori'), findsOneWidget);

    // Verify tabs
    expect(find.text('Pengeluaran'), findsOneWidget);
    expect(find.text('Pemasukan'), findsOneWidget);

    // Verify search bar
    expect(find.text('Cari kategori...'), findsOneWidget);

    // Verify default expense categories
    expect(find.text('Makanan'), findsOneWidget);
    expect(find.text('Transportasi'), findsOneWidget);
    expect(find.text('Belanja'), findsOneWidget);
    expect(find.text('Tagihan'), findsOneWidget);

    // Verify add category button
    expect(find.text('Tambah Kategori Baru'), findsOneWidget);

    // Test tab switch to Pemasukan
    await tester.tap(find.text('Pemasukan'));
    await tester.pumpAndSettle();

    expect(find.text('Gaji Utama'), findsOneWidget);
    expect(find.text('Bonus'), findsOneWidget);
    expect(find.text('Freelance'), findsOneWidget);
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

    // Verify skeleton widget is active
    expect(find.byKey(const ValueKey('skeleton')), findsOneWidget);
    expect(find.byKey(const ValueKey('content')), findsNothing);

    // Toggle skeleton via top app bar button
    await tester.tap(find.byIcon(Icons.visibility_rounded));
    await tester.pump(const Duration(seconds: 2));

    expect(find.byKey(const ValueKey('content')), findsOneWidget);
    expect(find.text('Alokasi & Kategori'), findsOneWidget);
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
    expect(find.text('+50rb'), findsOneWidget);
    expect(find.text('+100rb'), findsOneWidget);
    expect(find.text('+250rb'), findsOneWidget);
    expect(find.byIcon(Icons.backspace_outlined), findsOneWidget);

    // Verify Category section
    expect(find.text('Pilih Kategori'), findsOneWidget);
    expect(find.text('Kelola'), findsOneWidget);
    expect(find.text('Makanan &\nMinuman'), findsOneWidget);
    expect(find.text('Belanja\nPasar'), findsOneWidget);

    // Verify Additional Details
    expect(find.text('Rincian Tambahan'), findsOneWidget);
    expect(find.text('Tanggal'), findsOneWidget);
    expect(find.text('24 Mei 2025'), findsOneWidget);
    expect(find.text('Waktu Transaksi'), findsOneWidget);
    expect(find.text('14:30 WIB'), findsOneWidget);
    expect(find.text('Catatan (Opsional)'), findsOneWidget);

    // Verify CTA Button
    expect(find.text('Simpan Transaksi'), findsOneWidget);

    // Test Quick Add +50rb -> 150.000 + 50.000 = 200.000
    await tester.tap(find.text('+50rb'));
    await tester.pump();
    expect(find.text('200.000'), findsOneWidget);

    // Test Clear button
    await tester.tap(find.byIcon(Icons.backspace_outlined));
    await tester.pump();
    final amountEditable = tester.widgetList<EditableText>(find.byType(EditableText)).first;
    expect(amountEditable.controller.text, '0');

    // Test Quick Add +100rb -> 100.000
    await tester.tap(find.text('+100rb'));
    await tester.pump();
    expect(amountEditable.controller.text, '100.000');

    // Test tab switch to Pemasukan
    await tester.tap(find.text('Pemasukan'));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Masuk'), findsOneWidget);
    expect(find.text('Gaji\nUtama'), findsOneWidget);
    expect(find.text('Bonus &\nTunjangan'), findsOneWidget);
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

    // Toggle skeleton via top app bar button
    await tester.tap(find.byIcon(Icons.visibility_rounded));
    await tester.pump(const Duration(seconds: 2));

    expect(find.byKey(const ValueKey('content')), findsOneWidget);
    expect(find.text('Nominal Transaksi'), findsOneWidget);
  });

  testWidgets('Export data screen smoke test & interactions', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const ExportDataScreen(),
      ),
    );

    // Let entrance animations finish
    await tester.pump(const Duration(seconds: 2));

    // Verify headers & section
    expect(find.text('PUSAT CADANGAN & SINKRON'), findsOneWidget);
    expect(find.text('Kelola Data Anda'), findsOneWidget);
    expect(find.text('Cadangan & Sinkronisasi'), findsOneWidget);

    // Verify Segmented switcher
    expect(find.text('Ekspor Data'), findsOneWidget);
    expect(find.text('Impor Data'), findsOneWidget);

    // Verify Periode selector
    expect(find.text('Periode Laporan'), findsOneWidget);
    expect(find.text('Mei 2025'), findsOneWidget);
    expect(find.text('Ubah'), findsOneWidget);

    // Verify Format cards
    expect(find.text('Pilih Format File'), findsOneWidget);
    expect(find.text('File .CSV'), findsOneWidget);
    expect(find.text('Dokumen .PDF'), findsOneWidget);

    // Verify Preview Table
    expect(find.text('Pratinjau Data (6 Kolom)'), findsOneWidget);
    expect(find.text('6 Kolom Sesuai'), findsOneWidget);
    expect(find.textContaining('28 Transaksi'), findsOneWidget);

    // Verify CTA Button
    expect(find.text('Unduh File Ekspor (.CSV)'), findsOneWidget);

    // Test switching format to PDF
    await tester.tap(find.text('Dokumen .PDF'));
    await tester.pumpAndSettle();
    expect(find.text('Unduh Dokumen Ekspor (.PDF)'), findsOneWidget);

    // Test switching mode to Impor Data
    await tester.tap(find.text('Impor Data'));
    await tester.pumpAndSettle();

    expect(find.text('Impor File Transaksi'), findsOneWidget);
    expect(find.text('UNGGAH CATATAN KEUANGAN'), findsOneWidget);
    expect(find.text('Unduh Contoh Template .CSV'), findsOneWidget);
    expect(find.text('Pilih atau Tarik File .CSV ke Sini'), findsOneWidget);
    expect(find.text('transaksi_keuangan_mei_2025.csv'), findsOneWidget);
    expect(find.text('Pratinjau Berkas'), findsOneWidget);
    expect(find.text('6 Kolom Terdeteksi'), findsOneWidget);
    expect(find.text('Semua kolom sesuai dengan format sistem'), findsOneWidget);
    expect(find.text('Mulai Impor 24 Transaksi'), findsOneWidget);
    expect(find.text('Batal'), findsOneWidget);

    // Test tapping Batal switches back to Ekspor Data
    await tester.ensureVisible(find.text('Batal'));
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();

    expect(find.text('Kelola Data Anda'), findsOneWidget);
    expect(find.text('Periode Laporan'), findsOneWidget);
  });

  testWidgets('Export data screen skeleton loading test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const ExportDataScreen(initialIsLoading: true),
      ),
    );

    await tester.pump();

    // Verify skeleton widget is active
    expect(find.byKey(const ValueKey('skeleton')), findsOneWidget);
    expect(find.byKey(const ValueKey('content')), findsNothing);

    // Toggle skeleton via top app bar button
    await tester.tap(find.byIcon(Icons.visibility_rounded));
    await tester.pump(const Duration(seconds: 2));

    expect(find.byKey(const ValueKey('content')), findsOneWidget);
    expect(find.text('Kelola Data Anda'), findsOneWidget);
  });
}
