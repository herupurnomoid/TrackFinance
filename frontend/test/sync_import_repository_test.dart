import 'dart:convert';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_finance/features/category/data/category_model.dart';
import 'package:track_finance/features/export/data/csv_import_parser.dart';
import 'package:track_finance/features/export/data/sync_import_repository.dart';
import 'package:track_finance/features/transaction/data/transaction_model.dart';

void main() {
  group('SyncImportRepository Unit Tests (SYNC-08, SYNC-09, SYNC-10)', () {
    late FakeFirebaseFirestore fakeFirestore;
    late SyncImportRepository repository;
    const testUid = 'user_import_test';

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repository = SyncImportRepository(
        firestore: fakeFirestore,
        parser: const CsvImportParser(),
      );
    });

    test('parseAndValidateCsv uses default categories when user has no custom categories', () async {
      const csv = '''No,Tanggal,Tipe,Kategori,Nominal,Catatan
1,2026-10-01,PENGELUARAN,Makanan & Minuman,25000,Makan siang''';
      final bytes = utf8.encode(csv);

      final model = await repository.parseAndValidateCsv(
        bytes,
        'test.csv',
        uid: testUid,
      );

      expect(model.validCount, equals(1));
      expect(model.validTransactions.first.categoryName, equals('Makanan & Minuman'));
    });

    test('parseAndValidateCsv loads custom categories from Firestore', () async {
      final customCategory = CategoryItem(
        id: 'cat_custom_hobby',
        name: 'Hobi & Fotografi',
        icon: Icons.camera_alt_rounded,
        isExpense: true,
      );

      await fakeFirestore
          .collection('users')
          .doc(testUid)
          .collection('categories')
          .doc(customCategory.id)
          .set(customCategory.toMap());

      const csv = '''No,Tanggal,Tipe,Kategori,Nominal,Catatan
1,2026-10-01,PENGELUARAN,Hobi & Fotografi,150000,Lensa kamera''';
      final bytes = utf8.encode(csv);

      final model = await repository.parseAndValidateCsv(
        bytes,
        'hobby.csv',
        uid: testUid,
      );

      expect(model.validCount, equals(1));
      expect(model.validTransactions.first.categoryId, equals('cat_custom_hobby'));
      expect(model.validTransactions.first.categoryName, equals('Hobi & Fotografi'));
    });

    test('parseAndValidateCsv queries Firestore transactions and flags duplicates (SYNC-10)', () async {
      final existing = TransactionModel(
        id: 'tx_old_1',
        type: 'expense',
        amount: 50000,
        categoryId: 'exp-1',
        categoryName: 'Makanan & Minuman',
        categoryIconCode: 1,
        notes: 'Lunch',
        timeStr: '12:00',
        date: DateTime(2026, 10, 5),
        dateKey: '2026-10-05',
        monthKey: '2026-10',
        year: 2026,
        month: 9,
        day: 5,
      );

      await fakeFirestore
          .collection('users')
          .doc(testUid)
          .collection('transactions')
          .doc(existing.id)
          .set(existing.toFirestore());

      const csv = '''No,Tanggal,Tipe,Kategori,Nominal,Catatan
1,2026-10-05,PENGELUARAN,Makanan & Minuman,50000,Duplicate with Firestore
2,2026-10-06,PENGELUARAN,Makanan & Minuman,70000,New item''';
      final bytes = utf8.encode(csv);

      final model = await repository.parseAndValidateCsv(
        bytes,
        'items.csv',
        uid: testUid,
      );

      expect(model.validCount, equals(1));
      expect(model.duplicateCount, equals(1));
      expect(model.validTransactions.length, equals(1));
      expect(model.validTransactions.first.amount, equals(70000));
    });

    test('commitImport throws ArgumentError for empty or whitespace UID (SYNC-13)', () async {
      expect(
        () => repository.commitImport('', []),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => repository.commitImport('   ', []),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('commitImport returns 0 and does not write when transactions list is empty (SYNC-13)', () async {
      final committed = await repository.commitImport(testUid, []);
      expect(committed, equals(0));

      final txSnap = await fakeFirestore
          .collection('users')
          .doc(testUid)
          .collection('transactions')
          .get();
      expect(txSnap.docs.isEmpty, isTrue);
    });

    test('commitImport commits transactions, updates monthly_summaries and user balance atomically (SYNC-13)', () async {
      // Set initial user balance
      await fakeFirestore.collection('users').doc(testUid).set({
        'totalBalance': 1000000,
      });

      final txExpense = TransactionModel(
        id: 'tx_batch_exp',
        type: 'expense',
        amount: 200000,
        categoryId: 'exp-1',
        categoryName: 'Makanan & Minuman',
        categoryIconCode: 1,
        notes: 'Groceries',
        timeStr: '12:00',
        date: DateTime(2026, 10, 10),
        dateKey: '2026-10-10',
        monthKey: '2026-10',
        year: 2026,
        month: 9,
        day: 10,
      );

      final txIncome = TransactionModel(
        id: 'tx_batch_inc',
        type: 'income',
        amount: 500000,
        categoryId: 'inc-1',
        categoryName: 'Gaji Pokok',
        categoryIconCode: 2,
        notes: 'Side gig',
        timeStr: '14:00',
        date: DateTime(2026, 10, 11),
        dateKey: '2026-10-11',
        monthKey: '2026-10',
        year: 2026,
        month: 9,
        day: 11,
      );

      final total = await repository.commitImport(testUid, [txExpense, txIncome]);
      expect(total, equals(2));

      // 1. Verify transactions created
      final txExpDoc = await fakeFirestore
          .collection('users')
          .doc(testUid)
          .collection('transactions')
          .doc(txExpense.id)
          .get();
      expect(txExpDoc.exists, isTrue);
      expect(txExpDoc.data()?['amount'], equals(200000));
      expect(txExpDoc.data()?['type'], equals('expense'));

      final txIncDoc = await fakeFirestore
          .collection('users')
          .doc(testUid)
          .collection('transactions')
          .doc(txIncome.id)
          .get();
      expect(txIncDoc.exists, isTrue);
      expect(txIncDoc.data()?['amount'], equals(500000));
      expect(txIncDoc.data()?['type'], equals('income'));

      // 2. Verify monthly summary
      final summaryDoc = await fakeFirestore
          .collection('users')
          .doc(testUid)
          .collection('monthly_summaries')
          .doc('2026-10')
          .get();
      expect(summaryDoc.exists, isTrue);
      final sData = summaryDoc.data()!;
      expect(sData['totalExpense'], equals(200000));
      expect(sData['totalIncome'], equals(500000));
      expect(sData['netCashflow'], equals(300000));
      expect(sData['transactionCount'], equals(2));
      expect(sData['categoryBreakdown']['exp-1']['total'], equals(200000));
      expect(sData['categoryBreakdown']['inc-1']['total'], equals(500000));

      // 3. Verify user totalBalance
      final userDoc = await fakeFirestore.collection('users').doc(testUid).get();
      // 1.000.000 - 200.000 + 500.000 = 1.300.000
      expect(userDoc.data()?['totalBalance'], equals(1300000));
    });

    test('commitImport splits transactions into chunks when exceeding chunkSize (SYNC-13)', () async {
      final List<TransactionModel> txs = List.generate(5, (index) {
        return TransactionModel(
          id: 'tx_chunk_$index',
          type: 'expense',
          amount: 10000 * (index + 1),
          categoryId: 'exp-1',
          categoryName: 'Makanan',
          categoryIconCode: 1,
          notes: 'Item $index',
          timeStr: '12:00',
          date: DateTime(2026, 10, index + 1),
          dateKey: '2026-10-0${index + 1}',
          monthKey: '2026-10',
          year: 2026,
          month: 9,
          day: index + 1,
        );
      });

      // chunkSize = 2 means 3 chunks (2, 2, 1)
      final committed = await repository.commitImport(
        testUid,
        txs,
        chunkSize: 2,
      );

      expect(committed, equals(5));

      final allDocs = await fakeFirestore
          .collection('users')
          .doc(testUid)
          .collection('transactions')
          .get();
      expect(allDocs.docs.length, equals(5));

      final summaryDoc = await fakeFirestore
          .collection('users')
          .doc(testUid)
          .collection('monthly_summaries')
          .doc('2026-10')
          .get();
      // Total amount: 10k + 20k + 30k + 40k + 50k = 150k
      expect(summaryDoc.data()?['totalExpense'], equals(150000));
      expect(summaryDoc.data()?['transactionCount'], equals(5));
    });

    test('commitImport across multiple months updates separate monthly_summaries (SYNC-13)', () async {
      final txOct = TransactionModel(
        id: 'tx_oct',
        type: 'expense',
        amount: 80000,
        categoryId: 'exp-1',
        categoryName: 'Makanan',
        categoryIconCode: 1,
        notes: 'Oct',
        timeStr: '12:00',
        date: DateTime(2026, 10, 15),
        dateKey: '2026-10-15',
        monthKey: '2026-10',
        year: 2026,
        month: 9,
        day: 15,
      );

      final txNov = TransactionModel(
        id: 'tx_nov',
        type: 'income',
        amount: 1200000,
        categoryId: 'inc-1',
        categoryName: 'Gaji',
        categoryIconCode: 2,
        notes: 'Nov',
        timeStr: '12:00',
        date: DateTime(2026, 11, 1),
        dateKey: '2026-11-01',
        monthKey: '2026-11',
        year: 2026,
        month: 10,
        day: 1,
      );

      await repository.commitImport(testUid, [txOct, txNov]);

      final octSummary = await fakeFirestore
          .collection('users')
          .doc(testUid)
          .collection('monthly_summaries')
          .doc('2026-10')
          .get();
      expect(octSummary.data()?['totalExpense'], equals(80000));

      final novSummary = await fakeFirestore
          .collection('users')
          .doc(testUid)
          .collection('monthly_summaries')
          .doc('2026-11')
          .get();
      expect(novSummary.data()?['totalIncome'], equals(1200000));
    });
  });
}
