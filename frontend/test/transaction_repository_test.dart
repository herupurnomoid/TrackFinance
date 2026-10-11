import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_finance/features/transaction/data/monthly_summary_model.dart';
import 'package:track_finance/features/transaction/data/transaction_model.dart';
import 'package:track_finance/features/transaction/data/transaction_repository.dart';

void main() {
  group('TransactionRepository Unit Tests (TX-03 to TX-08)', () {
    late FakeFirebaseFirestore fakeFirestore;
    late TransactionRepository repository;
    const testUid = 'user_test_456';

    final sampleExpense = TransactionModel(
      id: 'tx_exp_01',
      type: 'expense',
      amount: 150000,
      categoryId: 'exp-1',
      categoryName: 'Makanan & Minuman',
      categoryIconCode: Icons.restaurant_rounded.codePoint,
      notes: 'Makan siang bersama tim',
      timeStr: '12.30',
      date: DateTime(2026, 10, 10, 12, 30),
      dateKey: '2026-10-10',
      monthKey: '2026-10',
      year: 2026,
      month: 9, // Oktober (0-based)
      day: 10,
    );

    final sampleIncome = TransactionModel(
      id: 'tx_inc_01',
      type: 'income',
      amount: 5000000,
      categoryId: 'inc-1',
      categoryName: 'Gaji Pokok',
      categoryIconCode: Icons.account_balance_wallet_rounded.codePoint,
      notes: 'Gaji bulanan',
      timeStr: '09.00',
      date: DateTime(2026, 10, 1, 9, 0),
      dateKey: '2026-10-01',
      monthKey: '2026-10',
      year: 2026,
      month: 9,
      day: 1,
    );

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repository = TransactionRepository(firestore: fakeFirestore);
    });

    // =========================================================================
    // TX-03: ATOMIC BATCH ADD TRANSACTION TESTS
    // =========================================================================
    group('TX-03: addTransaction', () {
      test('Successfully adds expense and atomically updates transactions, monthly summary, and user balance', () async {
        await repository.addTransaction(testUid, sampleExpense);

        // 1. Verifikasi dokumen transaksi
        final txDoc = await fakeFirestore
            .collection('users')
            .doc(testUid)
            .collection('transactions')
            .doc('tx_exp_01')
            .get();

        expect(txDoc.exists, isTrue);
        expect(txDoc.data()?['type'], 'expense');
        expect(txDoc.data()?['amount'], 150000);
        expect(txDoc.data()?['categoryName'], 'Makanan & Minuman');

        // 2. Verifikasi dokumen monthly summary
        final summaryDoc = await fakeFirestore
            .collection('users')
            .doc(testUid)
            .collection('monthly_summaries')
            .doc('2026-10')
            .get();

        expect(summaryDoc.exists, isTrue);
        final summary = await repository.getMonthlySummary(testUid, '2026-10');
        expect(summary, isNotNull);
        expect(summary!.totalExpense, 150000);
        expect(summary.totalIncome, 0);
        expect(summary.netCashflow, -150000);
        expect(summary.transactionCount, 1);

        final breakdown = summary.typedCategoryBreakdown;
        expect(breakdown['exp-1']?.name, 'Makanan & Minuman');
        expect(breakdown['exp-1']?.total, 150000);
        expect(breakdown['exp-1']?.count, 1);

        // 3. Verifikasi saldo pengguna
        final balance = await repository.getUserBalance(testUid);
        expect(balance, -150000);
      });

      test('Successfully adds income and increases user balance and monthly summary', () async {
        await repository.addTransaction(testUid, sampleIncome);

        final summary = await repository.getMonthlySummary(testUid, '2026-10');
        expect(summary, isNotNull);
        expect(summary!.totalIncome, 5000000);
        expect(summary.totalExpense, 0);
        expect(summary.netCashflow, 5000000);
        expect(summary.transactionCount, 1);

        final balance = await repository.getUserBalance(testUid);
        expect(balance, 5000000);
      });

      test('Consecutive transactions accumulate correctly', () async {
        await repository.addTransaction(testUid, sampleIncome); // +5.000.000
        await repository.addTransaction(testUid, sampleExpense); // -150.000

        final summary = await repository.getMonthlySummary(testUid, '2026-10');
        expect(summary!.totalIncome, 5000000);
        expect(summary.totalExpense, 150000);
        expect(summary.netCashflow, 4850000);
        expect(summary.transactionCount, 2);

        final balance = await repository.getUserBalance(testUid);
        expect(balance, 4850000);
      });

      test('Throws ArgumentError on empty UID or non-positive amount', () async {
        expect(
          () => repository.addTransaction('', sampleExpense),
          throwsArgumentError,
        );

        final invalidTx = sampleExpense.copyWith(amount: 0);
        expect(
          () => repository.addTransaction(testUid, invalidTx),
          throwsArgumentError,
        );
      });
    });

    // =========================================================================
    // TX-04: ATOMIC BATCH UPDATE TRANSACTION TESTS
    // =========================================================================
    group('TX-04: updateTransaction', () {
      test('Updates transaction nominal within the same month and recalculates deltas', () async {
        // Tambahkan transaksi awal: Pengeluaran 150.000
        await repository.addTransaction(testUid, sampleExpense);

        // Ubah transaksi menjadi: Pengeluaran 200.000 (+50.000 pengeluaran)
        final updatedExpense = sampleExpense.copyWith(
          amount: 200000,
          notes: 'Makan siang + kopi tim',
        );

        await repository.updateTransaction(testUid, sampleExpense, updatedExpense);

        // Verifikasi dokumen transaksi terupdate
        final tx = await repository.getTransaction(testUid, 'tx_exp_01');
        expect(tx?.amount, 200000);
        expect(tx?.notes, 'Makan siang + kopi tim');

        // Verifikasi monthly summary terupdate secara delta
        final summary = await repository.getMonthlySummary(testUid, '2026-10');
        expect(summary?.totalExpense, 200000);
        expect(summary?.netCashflow, -200000);
        expect(summary?.transactionCount, 1); // count tetap 1
        expect(summary?.typedCategoryBreakdown['exp-1']?.total, 200000);

        // Verifikasi total balance berkurang lagi 50.000 -> -200.000
        final balance = await repository.getUserBalance(testUid);
        expect(balance, -200000);
      });

      test('Updates category correctly adjusting old and new category buckets', () async {
        await repository.addTransaction(testUid, sampleExpense);

        // Ubah kategori dari 'exp-1' (Makanan) ke 'exp-2' (Transportasi)
        final updatedCategoryTx = sampleExpense.copyWith(
          categoryId: 'exp-2',
          categoryName: 'Transportasi',
        );

        await repository.updateTransaction(testUid, sampleExpense, updatedCategoryTx);

        final summary = await repository.getMonthlySummary(testUid, '2026-10');
        final breakdown = summary!.typedCategoryBreakdown;

        expect(breakdown['exp-1']?.total, 0);
        expect(breakdown['exp-1']?.count, 0);
        expect(breakdown['exp-2']?.name, 'Transportasi');
        expect(breakdown['exp-2']?.total, 150000);
        expect(breakdown['exp-2']?.count, 1);
      });

      test('Handles cross-month date modification by moving summary accumulation', () async {
        await repository.addTransaction(testUid, sampleExpense); // Bulan 2026-10

        // Pindahkan tanggal transaksi ke bulan November 2026 (2026-11)
        final novExpense = sampleExpense.copyWith(
          monthKey: '2026-11',
          dateKey: '2026-11-05',
          year: 2026,
          month: 10, // November
          day: 5,
        );

        await repository.updateTransaction(testUid, sampleExpense, novExpense);

        // Ringkasan Oktober berkurang
        final octSummary = await repository.getMonthlySummary(testUid, '2026-10');
        expect(octSummary?.totalExpense, 0);
        expect(octSummary?.transactionCount, 0);

        // Ringkasan November bertambah
        final novSummary = await repository.getMonthlySummary(testUid, '2026-11');
        expect(novSummary?.totalExpense, 150000);
        expect(novSummary?.transactionCount, 1);
        expect(novSummary?.typedCategoryBreakdown['exp-1']?.total, 150000);

        // Saldo pengguna tetap sama karena nominal & jenis tidak berubah
        final balance = await repository.getUserBalance(testUid);
        expect(balance, -150000);
      });

      test('Throws ArgumentError on invalid update inputs', () async {
        expect(
          () => repository.updateTransaction('', sampleExpense, sampleExpense),
          throwsArgumentError,
        );

        final invalidTx = sampleExpense.copyWith(amount: 0);
        expect(
          () => repository.updateTransaction(testUid, sampleExpense, invalidTx),
          throwsArgumentError,
        );
      });
    });

    // =========================================================================
    // TX-05: ATOMIC BATCH DELETE TRANSACTION TESTS
    // =========================================================================
    group('TX-05: deleteTransaction', () {
      test('Deletes expense transaction, decrements summary, and restores user balance', () async {
        await repository.addTransaction(testUid, sampleExpense);
        expect(await repository.getUserBalance(testUid), -150000);

        // Hapus transaksi
        await repository.deleteTransaction(testUid, sampleExpense);

        // 1. Dokumen transaksi terhapus
        final deletedTx = await repository.getTransaction(testUid, 'tx_exp_01');
        expect(deletedTx, isNull);

        // 2. Ringkasan bulanan dikurangkan
        final summary = await repository.getMonthlySummary(testUid, '2026-10');
        expect(summary?.totalExpense, 0);
        expect(summary?.netCashflow, 0);
        expect(summary?.transactionCount, 0);
        expect(summary?.typedCategoryBreakdown['exp-1']?.total, 0);
        expect(summary?.typedCategoryBreakdown['exp-1']?.count, 0);

        // 3. Saldo dikembalikan ke 0
        final balance = await repository.getUserBalance(testUid);
        expect(balance, 0);
      });

      test('Deletes income transaction, decrements summary, and deducts user balance', () async {
        await repository.addTransaction(testUid, sampleIncome);
        expect(await repository.getUserBalance(testUid), 5000000);

        await repository.deleteTransaction(testUid, sampleIncome);

        final deletedTx = await repository.getTransaction(testUid, 'tx_inc_01');
        expect(deletedTx, isNull);

        final summary = await repository.getMonthlySummary(testUid, '2026-10');
        expect(summary?.totalIncome, 0);
        expect(summary?.netCashflow, 0);
        expect(summary?.transactionCount, 0);

        final balance = await repository.getUserBalance(testUid);
        expect(balance, 0);
      });

      test('Throws ArgumentError when deleting with empty UID', () async {
        expect(
          () => repository.deleteTransaction('', sampleExpense),
          throwsArgumentError,
        );
      });
    });

    // =========================================================================
    // TX-06, TX-07, TX-08: REALTIME STREAMS TESTS
    // =========================================================================
    group('TX-06: watchRecentTransactions', () {
      test('Emits transactions ordered by date descending with limit', () async {
        final stream = repository.watchRecentTransactions(testUid, limit: 3);

        final t1 = sampleExpense.copyWith(
          id: 'tx_1',
          date: DateTime(2026, 10, 1, 10, 0),
        );
        final t2 = sampleExpense.copyWith(
          id: 'tx_2',
          date: DateTime(2026, 10, 5, 10, 0),
        );
        final t3 = sampleExpense.copyWith(
          id: 'tx_3',
          date: DateTime(2026, 10, 10, 10, 0),
        );
        final t4 = sampleExpense.copyWith(
          id: 'tx_4',
          date: DateTime(2026, 10, 15, 10, 0),
        );

        await repository.addTransaction(testUid, t1);
        await repository.addTransaction(testUid, t2);
        await repository.addTransaction(testUid, t3);
        await repository.addTransaction(testUid, t4);

        final list = await stream.first;
        expect(list.length, 3);
        // Terurut descending (terbaru lebih dahulu: t4, t3, t2)
        expect(list[0].id, 'tx_4');
        expect(list[1].id, 'tx_3');
        expect(list[2].id, 'tx_2');
      });

      test('Returns empty stream when UID is empty', () async {
        final stream = repository.watchRecentTransactions('');
        final list = await stream.first;
        expect(list, isEmpty);
      });
    });

    group('TX-07: watchTransactionsByMonth', () {
      test('Filters transactions strictly by monthKey', () async {
        final octTx = sampleExpense.copyWith(
          id: 'tx_oct',
          monthKey: '2026-10',
          date: DateTime(2026, 10, 12),
        );
        final novTx = sampleExpense.copyWith(
          id: 'tx_nov',
          monthKey: '2026-11',
          date: DateTime(2026, 11, 2),
        );

        await repository.addTransaction(testUid, octTx);
        await repository.addTransaction(testUid, novTx);

        final octStream = repository.watchTransactionsByMonth(testUid, '2026-10');
        final octList = await octStream.first;
        expect(octList.length, 1);
        expect(octList.first.id, 'tx_oct');

        final novStream = repository.watchTransactionsByMonth(testUid, '2026-11');
        final novList = await novStream.first;
        expect(novList.length, 1);
        expect(novList.first.id, 'tx_nov');
      });

      test('Returns empty stream on empty arguments', () async {
        expect(await repository.watchTransactionsByMonth('', '2026-10').first, isEmpty);
        expect(await repository.watchTransactionsByMonth(testUid, '').first, isEmpty);
      });
    });

    group('watchTransactionsByYear & watchAllTransactions', () {
      test('watchTransactionsByYear filters transactions strictly by year', () async {
        final tx2025 = sampleExpense.copyWith(
          id: 'tx_2025',
          year: 2025,
          monthKey: '2025-12',
          date: DateTime(2025, 12, 10),
        );
        final tx2026 = sampleExpense.copyWith(
          id: 'tx_2026',
          year: 2026,
          monthKey: '2026-05',
          date: DateTime(2026, 5, 20),
        );

        await repository.addTransaction(testUid, tx2025);
        await repository.addTransaction(testUid, tx2026);

        final stream2026 = repository.watchTransactionsByYear(testUid, 2026);
        final list2026 = await stream2026.first;
        expect(list2026.any((tx) => tx.id == 'tx_2026'), isTrue);
        expect(list2026.any((tx) => tx.id == 'tx_2025'), isFalse);

        expect(await repository.watchTransactionsByYear('', 2026).first, isEmpty);
      });

      test('watchAllTransactions emits all transactions across all years', () async {
        final tx2025 = sampleExpense.copyWith(
          id: 'tx_all_2025',
          year: 2025,
          monthKey: '2025-12',
          date: DateTime(2025, 12, 10),
        );
        final tx2026 = sampleExpense.copyWith(
          id: 'tx_all_2026',
          year: 2026,
          monthKey: '2026-05',
          date: DateTime(2026, 5, 20),
        );

        await repository.addTransaction(testUid, tx2025);
        await repository.addTransaction(testUid, tx2026);

        final allStream = repository.watchAllTransactions(testUid);
        final list = await allStream.first;
        expect(list.any((tx) => tx.id == 'tx_all_2025'), isTrue);
        expect(list.any((tx) => tx.id == 'tx_all_2026'), isTrue);

        expect(await repository.watchAllTransactions('').first, isEmpty);
      });
    });

    group('TX-08: watchMonthlySummary', () {
      test('Emits null initially then emits updated summary on add and delete', () async {
        final stream = repository.watchMonthlySummary(testUid, '2026-10');

        expectLater(
          stream,
          emitsInOrder([
            isNull,
            predicate<MonthlySummaryModel?>((s) => s != null && s.totalExpense == 150000),
            predicate<MonthlySummaryModel?>((s) => s != null && s.totalExpense == 0),
          ]),
        );

        // Tambah transaksi
        await repository.addTransaction(testUid, sampleExpense);
        // Hapus transaksi
        await repository.deleteTransaction(testUid, sampleExpense);
      });

      test('watchUserBalance emits live balance changes', () async {
        final balanceStream = repository.watchUserBalance(testUid);

        expectLater(
          balanceStream,
          emitsInOrder([
            0,
            -150000,
            4850000,
          ]),
        );

        await repository.addTransaction(testUid, sampleExpense); // -150.000
        await repository.addTransaction(testUid, sampleIncome); // +5.000.000
      });
    });

    // =========================================================================
    // SYNC-05: getTransactionsByDateRange TESTS
    // =========================================================================
    group('SYNC-05: getTransactionsByDateRange', () {
      test('Returns transactions within date range inclusive', () async {
        await repository.addTransaction(testUid, sampleIncome); // 2026-10-01
        await repository.addTransaction(testUid, sampleExpense); // 2026-10-10

        final result = await repository.getTransactionsByDateRange(
          testUid,
          startDate: DateTime(2026, 10, 1),
          endDate: DateTime(2026, 10, 10),
        );

        expect(result.length, equals(2));
      });

      test('Filters out transactions outside date range', () async {
        await repository.addTransaction(testUid, sampleIncome); // 2026-10-01
        await repository.addTransaction(testUid, sampleExpense); // 2026-10-10

        final result = await repository.getTransactionsByDateRange(
          testUid,
          startDate: DateTime(2026, 10, 5),
          endDate: DateTime(2026, 10, 31),
        );

        expect(result.length, equals(1));
        expect(result.first.id, equals('tx_exp_01'));
      });

      test('Returns empty list when UID is empty', () async {
        final result = await repository.getTransactionsByDateRange(
          '',
          startDate: DateTime(2026, 10, 1),
          endDate: DateTime(2026, 10, 10),
        );

        expect(result, isEmpty);
      });
    });
  });
}

