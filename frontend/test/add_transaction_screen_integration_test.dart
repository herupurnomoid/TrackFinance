import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_finance/core/models/user_profile.dart';
import 'package:track_finance/core/theme/app_theme.dart';
import 'package:track_finance/features/transaction/data/transaction_action_result.dart';
import 'package:track_finance/features/transaction/data/transaction_model.dart';
import 'package:track_finance/features/transaction/data/transaction_repository.dart';
import 'package:track_finance/features/transaction/presentation/screens/add_transaction_screen.dart';

void main() {
  group('AddTransactionScreen Repository Integration Tests (TX-09, TX-10)', () {
    late FakeFirebaseFirestore fakeFirestore;
    late TransactionRepository repository;

    const testUser = UserProfile(
      uid: 'user_integration_test',
      email: 'test@trackfinance.app',
      displayName: 'Test User',
      photoUrl: null,
    );

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repository = TransactionRepository(firestore: fakeFirestore);
      TransactionRepository.instance = repository;
    });

    testWidgets('TX-09: Add Transaction flow invokes TransactionRepository.addTransaction and persists to Firestore', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      dynamic popResult;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  popResult = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AddTransactionScreen(user: testUser),
                    ),
                  );
                },
                child: const Text('Buka Tambah Transaksi'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Buka layar tambah transaksi
      await tester.tap(find.text('Buka Tambah Transaksi'));
      await tester.pumpAndSettle();

      expect(find.text('Tambah Transaksi'), findsOneWidget);

      // Masukkan nominal 200.000
      final amountField = find.byType(TextField).first;
      await tester.enterText(amountField, '200000');
      await tester.pump();
      expect(find.text('200.000'), findsOneWidget);

      // Pilih kategori "Makanan"
      await tester.tap(find.text('Makanan'));
      await tester.pump();

      // Masukkan catatan transaksi
      final noteField = find.byWidgetPredicate(
        (widget) => widget is TextField && widget.decoration?.hintText == 'Tulis rincian catatan...',
      );
      expect(noteField, findsOneWidget);
      await tester.enterText(noteField, 'Makan siang bareng rekan');
      await tester.pump();

      // Tekan tombol Simpan Transaksi ("Simpan Transaksi")
      final saveButton = find.text('Simpan Transaksi');
      expect(saveButton, findsOneWidget);
      await tester.tap(saveButton);
      await tester.pump();

      // Tunggu proses commit batch dan animasi haptic
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      // 1. Verifikasi data tersimpan di Fake Firestore
      final txSnapshot = await fakeFirestore
          .collection('users')
          .doc(testUser.uid)
          .collection('transactions')
          .get();
      expect(txSnapshot.docs.length, 1);

      final docData = txSnapshot.docs.first.data();
      expect(docData['amount'], 200000);
      expect(docData['type'], 'expense');
      expect(docData['notes'], 'Makan siang bareng rekan');
      expect(docData['monthKey'], '2025-05');

      // 2. Verifikasi monthly summary terupdate
      final summary = await repository.getMonthlySummary(testUser.uid, '2025-05');
      expect(summary, isNotNull);
      expect(summary?.totalExpense, 200000);
      expect(summary?.netCashflow, -200000);
      expect(summary?.transactionCount, 1);

      // 3. Verifikasi saldo pengguna terupdate
      final balance = await repository.getUserBalance(testUser.uid);
      expect(balance, -200000);

      // 4. Verifikasi feedback SnackBar dan hasil pop
      expect(find.text('Pengeluaran Rp 200.000 berhasil dicatat!'), findsOneWidget);
      expect(popResult, isA<TransactionActionResult>());
      expect((popResult as TransactionActionResult).isDeleted, isFalse);
    });

    testWidgets('TX-10: Edit Transaction flow invokes TransactionRepository.updateTransaction and adjusts deltas', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      // 1. Siapkan transaksi awal di Firestore
      final initialTx = TransactionModel(
        id: 'tx_edit_integration_1',
        type: 'expense',
        amount: 80000,
        categoryId: 'cat-food',
        categoryName: 'Makanan',
        categoryIconCode: Icons.restaurant_rounded.codePoint,
        notes: 'Sarapan pagi',
        timeStr: '08.00',
        date: DateTime(2026, 10, 10, 8, 0),
        dateKey: '2026-10-10',
        monthKey: '2026-10',
        year: 2026,
        month: 9,
        day: 10,
      );
      await repository.addTransaction(testUser.uid, initialTx);

      expect(await repository.getUserBalance(testUser.uid), -80000);

      final dashboardTx = initialTx.toDashboardTransaction();
      dynamic popResult;

      // 2. Render layar AddTransactionScreen dalam mode Edit
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  popResult = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AddTransactionScreen(
                        user: testUser,
                        transaction: dashboardTx,
                      ),
                    ),
                  );
                },
                child: const Text('Buka Edit Transaksi'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Buka mode edit
      await tester.tap(find.text('Buka Edit Transaksi'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Transaksi'), findsOneWidget);
      expect(find.text('80.000'), findsOneWidget);
      expect(find.text('Sarapan pagi'), findsOneWidget);

      // Tambahkan +20.000 melalui chip sehingga nominal menjadi 100.000
      await tester.tap(find.text('+20.000'));
      await tester.pump();
      expect(find.text('100.000'), findsOneWidget);

      // Ubah catatan transaksi
      final noteField = find.byWidgetPredicate(
        (widget) => widget is TextField && widget.controller?.text == 'Sarapan pagi',
      );
      await tester.enterText(noteField, 'Sarapan pagi + teh tarik');
      await tester.pump();

      // Tekan tombol Perbarui Transaksi
      final updateButton = find.text('Perbarui Transaksi');
      expect(updateButton, findsOneWidget);
      await tester.tap(updateButton);
      await tester.pump();

      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      // 3. Verifikasi data di Firestore telah terupdate
      final updatedInDb = await repository.getTransaction(testUser.uid, 'tx_edit_integration_1');
      expect(updatedInDb?.amount, 100000);
      expect(updatedInDb?.notes, 'Sarapan pagi + teh tarik');

      // 4. Verifikasi saldo berkurang tambahan 20.000 menjadi -100.000
      final balance = await repository.getUserBalance(testUser.uid);
      expect(balance, -100000);

      // 5. Verifikasi monthly summary
      final summary = await repository.getMonthlySummary(testUser.uid, '2026-10');
      expect(summary?.totalExpense, 100000);
      expect(summary?.netCashflow, -100000);
      expect(summary?.transactionCount, 1);

      // 6. Verifikasi SnackBar dan pop result
      expect(find.text('Transaksi Pengeluaran berhasil diperbarui!'), findsOneWidget);
      expect(popResult, isA<TransactionActionResult>());
      expect((popResult as TransactionActionResult).updatedTransaction?.amount, -100000);
    });

    testWidgets('TX-11: Delete Transaction flow invokes TransactionRepository.deleteTransaction and removes doc from Firestore', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      // 1. Siapkan data transaksi di Firestore
      final initialTx = TransactionModel(
        id: 'tx_delete_integration_1',
        type: 'expense',
        amount: 75000,
        categoryId: 'cat-food',
        categoryName: 'Makanan',
        categoryIconCode: Icons.restaurant_rounded.codePoint,
        notes: 'Makan siang',
        timeStr: '12.00',
        date: DateTime(2026, 10, 7, 12, 0),
        dateKey: '2026-10-07',
        monthKey: '2026-10',
        year: 2026,
        month: 9,
        day: 7,
      );
      await repository.addTransaction(testUser.uid, initialTx);
      expect(await repository.getUserBalance(testUser.uid), -75000);

      final dashboardTx = initialTx.toDashboardTransaction();
      dynamic popResult;

      // 2. Render layar AddTransactionScreen dalam mode Edit
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  popResult = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AddTransactionScreen(
                        user: testUser,
                        transaction: dashboardTx,
                      ),
                    ),
                  );
                },
                child: const Text('Buka Edit Transaksi'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Buka Edit Transaksi'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Transaksi'), findsOneWidget);

      // 3. Tekan tombol hapus di header
      final deleteIcon = find.byIcon(Icons.delete_outline_rounded).first;
      await tester.tap(deleteIcon);
      await tester.pumpAndSettle();

      // 4. Konfirmasi dialog hapus
      final confirmDeleteBtn = find.text('Hapus');
      expect(confirmDeleteBtn, findsOneWidget);
      await tester.tap(confirmDeleteBtn);
      await tester.pump();

      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      // 5. Verifikasi transaksi telah terhapus dari Firestore
      final deletedDoc = await repository.getTransaction(testUser.uid, 'tx_delete_integration_1');
      expect(deletedDoc, isNull);

      // 6. Verifikasi saldo telah di-rollback ke 0
      final balance = await repository.getUserBalance(testUser.uid);
      expect(balance, 0);

      // 7. Verifikasi ringkasan bulanan dikurangkan
      final summary = await repository.getMonthlySummary(testUser.uid, '2026-10');
      expect(summary?.totalExpense, 0);
      expect(summary?.transactionCount, 0);

      // 8. Verifikasi SnackBar dan hasil pop
      expect(find.text('Transaksi Makanan berhasil dihapus'), findsOneWidget);
      expect(popResult, isA<TransactionActionResult>());
      expect((popResult as TransactionActionResult).isDeleted, isTrue);
    });
  });
}
