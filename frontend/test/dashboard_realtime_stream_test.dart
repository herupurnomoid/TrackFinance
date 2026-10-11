import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_finance/core/models/user_profile.dart';
import 'package:track_finance/core/theme/app_theme.dart';
import 'package:track_finance/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:track_finance/features/transaction/data/transaction_model.dart';
import 'package:track_finance/features/transaction/data/transaction_repository.dart';

void main() {
  group('DashboardScreen Realtime Stream Integration Tests (TX-12, TX-15)', () {
    late FakeFirebaseFirestore fakeFirestore;
    late TransactionRepository repository;

    const testUser = UserProfile(
      uid: 'user_dashboard_stream_test',
      email: 'dashboard@trackfinance.app',
      displayName: 'Heru',
      photoUrl: null,
    );

    final now = DateTime.now();
    final currentMonthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';
    final currentDateKey = '$currentMonthKey-${now.day.toString().padLeft(2, '0')}';

    final initialExpense = TransactionModel(
      id: 'tx_stream_exp_1',
      type: 'expense',
      amount: 150000,
      categoryId: 'cat-food',
      categoryName: 'Makanan',
      categoryIconCode: Icons.restaurant_rounded.codePoint,
      notes: 'Makan siang',
      timeStr: '12.30',
      date: DateTime(now.year, now.month, now.day, 12, 30),
      dateKey: currentDateKey,
      monthKey: currentMonthKey,
      year: now.year,
      month: now.month - 1,
      day: now.day,
    );

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repository = TransactionRepository(firestore: fakeFirestore);
      TransactionRepository.instance = repository;
    });

    testWidgets('Dashboard renders live data from Firestore and dynamically reacts to mutations', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      // 1. Simpan transaksi pengeluaran awal di Firestore
      await repository.addTransaction(testUser.uid, initialExpense);

      // 2. Render DashboardScreen dengan testUser
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const DashboardScreen(user: testUser),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      // Verifikasi transaksi awal muncul di antarmuka
      expect(find.text('Makanan'), findsWidgets);
      expect(find.textContaining('Makan siang'), findsWidgets);

      // 3. Tambahkan transaksi pemasukan baru secara realtime di background
      final liveIncome = TransactionModel(
        id: 'tx_stream_inc_2',
        type: 'income',
        amount: 4500000,
        categoryId: 'cat-salary',
        categoryName: 'Gaji Pokok',
        categoryIconCode: Icons.account_balance_wallet_rounded.codePoint,
        notes: 'Gaji bulan ini',
        timeStr: '09.00',
        date: DateTime(now.year, now.month, now.day, 9, 0),
        dateKey: currentDateKey,
        monthKey: currentMonthKey,
        year: now.year,
        month: now.month - 1,
        day: now.day,
      );

      await repository.addTransaction(testUser.uid, liveIncome);
      await tester.pump(const Duration(seconds: 1));

      // Verifikasi transaksi pemasukan baru langsung muncul seketika di layar
      expect(find.text('Gaji Pokok'), findsWidgets);
      expect(find.textContaining('Gaji bulan ini'), findsWidgets);

      // 4. Hapus transaksi pengeluaran awal di background
      await repository.deleteTransaction(testUser.uid, initialExpense);
      await tester.pump(const Duration(seconds: 1));

      // Verifikasi transaksi pengeluaran yang dihapus menghilang dari layar
      expect(find.textContaining('Makan siang'), findsNothing);
    });

    testWidgets('Dashboard Bulan & Tahun filter shows all months data (Jan to Dec) and accumulates accurately', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      // 1. Data transaksi Januari 2026 (pengeluaran Rp250.000)
      final janExpense = TransactionModel(
        id: 'tx_jan_2026',
        type: 'expense',
        amount: 250000,
        categoryId: 'cat-jan',
        categoryName: 'Belanja Januari',
        categoryIconCode: Icons.shopping_bag_rounded.codePoint,
        notes: 'Awal tahun',
        timeStr: '10.00',
        date: DateTime(2026, 1, 15, 10, 0),
        dateKey: '2026-01-15',
        monthKey: '2026-01',
        year: 2026,
        month: 0,
        day: 15,
      );

      // 2. Data transaksi Mei 2026 (pemasukan Rp500.000)
      final mayIncome = TransactionModel(
        id: 'tx_may_2026',
        type: 'income',
        amount: 500000,
        categoryId: 'cat-may',
        categoryName: 'Bonus Mei',
        categoryIconCode: Icons.savings_rounded.codePoint,
        notes: 'Bonus',
        timeStr: '14.00',
        date: DateTime(2026, 5, 20, 14, 0),
        dateKey: '2026-05-20',
        monthKey: '2026-05',
        year: 2026,
        month: 4,
        day: 20,
      );

      // 3. Data transaksi Oktober 2026 (pengeluaran Rp100.000)
      final octExpense = TransactionModel(
        id: 'tx_oct_2026',
        type: 'expense',
        amount: 100000,
        categoryId: 'cat-oct',
        categoryName: 'Makan Oktober',
        categoryIconCode: Icons.restaurant_rounded.codePoint,
        notes: 'Makan',
        timeStr: '18.00',
        date: DateTime(2026, 10, 5, 18, 0),
        dateKey: '2026-10-05',
        monthKey: '2026-10',
        year: 2026,
        month: 9,
        day: 5,
      );

      await repository.addTransaction(testUser.uid, janExpense);
      await repository.addTransaction(testUser.uid, mayIncome);
      await repository.addTransaction(testUser.uid, octExpense);

      // Render DashboardScreen
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const DashboardScreen(user: testUser),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      // Beralih ke filter 'Bulan'
      await tester.tap(find.text('Bulan'));
      await tester.pump(const Duration(seconds: 1));

      // Verifikasi banner aktif filter Bulan
      expect(find.textContaining('Filter Bulan aktif'), findsOneWidget);

      // Verifikasi nama bulan Januari, Mei, Oktober muncul di layar
      expect(find.text('Januari'), findsWidgets);
      expect(find.text('Mei'), findsWidgets);
      expect(find.text('Oktober'), findsWidgets);

      // Verifikasi bahwa nominal transaksi Januari (Rp250.000) dan Mei (Rp500.000)
      // bukan Rp0 lagi, melainkan tampil dengan benar
      expect(find.textContaining('250.000'), findsWidgets);
      expect(find.textContaining('500.000'), findsWidgets);

      // Beralih ke filter 'Tahun'
      await tester.tap(find.text('Tahun'));
      await tester.pump(const Duration(seconds: 1));

      // Verifikasi banner aktif filter Tahun
      expect(find.textContaining('Filter Tahun aktif'), findsOneWidget);

      // Verifikasi tahun 2026 muncul di daftar dekade
      expect(find.text('2026'), findsWidgets);

      // Verifikasi akumulasi total tahun 2026: pemasukan Rp500.000 dan pengeluaran Rp350.000 (250rb + 100rb)
      expect(find.textContaining('500.000'), findsWidgets);
      expect(find.textContaining('350.000'), findsWidgets);
    });

    testWidgets('Dashboard Minggu filter starts from Monday (Senin) to Sunday (Minggu)', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      // Buat transaksi di tanggal 2 Oktober 2026 (jatuh di Minggu 1: 28 Sep - 04 Okt)
      final txWeek1 = TransactionModel(
        id: 'tx_w1',
        type: 'expense',
        amount: 75000,
        categoryId: 'cat-w1',
        categoryName: 'Makan W1',
        categoryIconCode: Icons.restaurant_rounded.codePoint,
        notes: 'Minggu pertama',
        timeStr: '11.00',
        date: DateTime(2026, 10, 2, 11, 0),
        dateKey: '2026-10-02',
        monthKey: '2026-10',
        year: 2026,
        month: 9,
        day: 2,
      );

      // Buat transaksi di tanggal 7 Oktober 2026 (jatuh di Minggu 2: 05 Okt - 11 Okt)
      final txWeek2 = TransactionModel(
        id: 'tx_w2',
        type: 'income',
        amount: 300000,
        categoryId: 'cat-w2',
        categoryName: 'Pendapatan W2',
        categoryIconCode: Icons.wallet_rounded.codePoint,
        notes: 'Minggu kedua',
        timeStr: '09.00',
        date: DateTime(2026, 10, 7, 9, 0),
        dateKey: '2026-10-07',
        monthKey: '2026-10',
        year: 2026,
        month: 9,
        day: 7,
      );

      await repository.addTransaction(testUser.uid, txWeek1);
      await repository.addTransaction(testUser.uid, txWeek2);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const DashboardScreen(user: testUser),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      // Beralih ke filter 'Minggu'
      await tester.tap(find.text('Minggu'));
      await tester.pump(const Duration(seconds: 1));

      // Verifikasi judul dan subtitle mingguan dimulai dari hari Senin (28 Sep) sampai Minggu (04 Okt)
      expect(find.text('Minggu 1'), findsOneWidget);
      expect(find.text('28 Sep - 04 Okt'), findsOneWidget);

      expect(find.text('Minggu 2'), findsOneWidget);
      expect(find.text('05 Okt - 11 Okt'), findsOneWidget);

      expect(find.text('Minggu 3'), findsOneWidget);
      expect(find.text('12 Okt - 18 Okt'), findsOneWidget);

      expect(find.text('Minggu 4'), findsOneWidget);
      expect(find.text('19 Okt - 25 Okt'), findsOneWidget);

      expect(find.text('Minggu 5'), findsOneWidget);
      expect(find.text('26 Okt - 01 Nov'), findsOneWidget);

      // Verifikasi nominal pada Minggu 1 (Rp75.000) dan Minggu 2 (Rp300.000)
      expect(find.textContaining('75.000'), findsWidgets);
      expect(find.textContaining('300.000'), findsWidgets);
    });

    testWidgets('Dashboard does not duplicate transactions when adding a transaction through AddTransactionScreen', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const DashboardScreen(user: testUser),
        ),
      );
      await tester.pump(const Duration(seconds: 1));

      // Tap shortcut 'Tambah'
      await tester.tap(find.text('Tambah'));
      await tester.pumpAndSettle();

      expect(find.text('Tambah Transaksi'), findsOneWidget);

      // Enter nominal 50.000
      final amountField = find.byType(TextField).first;
      await tester.enterText(amountField, '50000');
      await tester.pump();

      // Select category "Makanan"
      await tester.tap(find.text('Makanan'));
      await tester.pump();

      // Tap 'Simpan Transaksi'
      final saveButton = find.text('Simpan Transaksi');
      await tester.tap(saveButton);
      await tester.pump();

      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump(const Duration(seconds: 1));

      // Kembali ke Dashboard:
      // 1. Kartu transaksi "Makanan" hanya ada 1 (tidak terduplikasi)
      expect(find.text('Makanan'), findsOneWidget);

      // 2. Total pengeluaran hari ini adalah -Rp50.000 (1 rekap tanggal + 1 kartu = 2 widgets teks)
      //    bukan -Rp100.000 (seperti bug duplikasi sebelumnya)
      expect(find.text('-Rp100.000'), findsNothing);
      expect(find.text('-Rp50.000'), findsNWidgets(2));
    });
  });
}
