import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_finance/core/theme/app_theme.dart';
import 'package:track_finance/features/category/presentation/screens/category_screen.dart';
import 'package:track_finance/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:track_finance/features/profile/presentation/screens/profile_screen.dart';
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
    expect(find.text('Alex Pratama'), findsNWidgets(2));
    expect(find.text('alex.pratama@email.com'), findsNWidgets(2));
    expect(find.text('INFORMASI AKUN'), findsOneWidget);
    expect(find.text('NAMA LENGKAP'), findsOneWidget);
    expect(find.text('EMAIL TERDAFTAR'), findsOneWidget);
    expect(find.text('Aktif'), findsOneWidget);
    expect(find.text('Keluar dari Akun'), findsOneWidget);
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

    // Verify header and intro card
    expect(find.text('Atur Kategori & Alokasi'), findsOneWidget);
    expect(find.text('Alokasi & Kategori'), findsOneWidget);

    // Verify tabs
    expect(find.text('Pengeluaran'), findsOneWidget);
    expect(find.text('Pemasukan'), findsOneWidget);

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
}
