import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_finance/features/dashboard/data/dashboard_transaction_model.dart';
import 'package:track_finance/features/transaction/data/transaction_model.dart';

void main() {
  group('TransactionModel Unit Tests (TX-01)', () {
    final sampleDate = DateTime(2026, 10, 10, 14, 30);

    final sampleTx = TransactionModel(
      id: 'tx_20261010_01',
      type: 'expense',
      amount: 150000,
      categoryId: 'exp-1',
      categoryName: 'Makanan & Minuman',
      categoryIconCode: Icons.restaurant_rounded.codePoint,
      notes: 'Makan siang bersama tim',
      timeStr: '14.30',
      date: sampleDate,
      dateKey: '2026-10-10',
      monthKey: '2026-10',
      year: 2026,
      month: 9, // 0-based: Oktober = 9
      day: 10,
    );

    test('Properties and getters are correct', () {
      expect(sampleTx.id, 'tx_20261010_01');
      expect(sampleTx.isExpense, isTrue);
      expect(sampleTx.isIncome, isFalse);
      expect(sampleTx.amount, 150000);
      expect(sampleTx.monthKey, '2026-10');
      expect(sampleTx.dateKey, '2026-10-10');
    });

    test('toFirestore serializes fields correctly', () {
      final firestoreMap = sampleTx.toFirestore();

      expect(firestoreMap['id'], 'tx_20261010_01');
      expect(firestoreMap['type'], 'expense');
      expect(firestoreMap['amount'], 150000);
      expect(firestoreMap['categoryId'], 'exp-1');
      expect(firestoreMap['categoryName'], 'Makanan & Minuman');
      expect(firestoreMap['categoryIconCode'], Icons.restaurant_rounded.codePoint);
      expect(firestoreMap['notes'], 'Makan siang bersama tim');
      expect(firestoreMap['timeStr'], '14.30');
      expect(firestoreMap['date'], isA<Timestamp>());
      expect((firestoreMap['date'] as Timestamp).toDate(), sampleDate);
      expect(firestoreMap['dateKey'], '2026-10-10');
      expect(firestoreMap['monthKey'], '2026-10');
      expect(firestoreMap['year'], 2026);
      expect(firestoreMap['month'], 9);
      expect(firestoreMap['day'], 10);
      expect(firestoreMap['updatedAt'], isA<FieldValue>());
    });

    test('fromMap parses map with Timestamps accurately', () {
      final map = {
        'id': 'tx_income_01',
        'type': 'income',
        'amount': 5000000,
        'categoryId': 'inc-1',
        'categoryName': 'Gaji',
        'categoryIconCode': Icons.account_balance_wallet_rounded.codePoint,
        'notes': 'Bonus kuartal',
        'timeStr': '09.00',
        'date': Timestamp.fromDate(sampleDate),
        'dateKey': '2026-10-10',
        'monthKey': '2026-10',
        'year': 2026,
        'month': 9,
        'day': 10,
      };

      final parsed = TransactionModel.fromMap(map);

      expect(parsed.id, 'tx_income_01');
      expect(parsed.isIncome, isTrue);
      expect(parsed.isExpense, isFalse);
      expect(parsed.amount, 5000000);
      expect(parsed.categoryId, 'inc-1');
      expect(parsed.categoryName, 'Gaji');
      expect(parsed.date, sampleDate);
      expect(parsed.notes, 'Bonus kuartal');
    });

    test('fromMap gracefully handles ISO-8601 strings and defaults', () {
      final map = {
        'amount': 25000,
        'date': '2026-10-10T14:30:00.000Z',
      };

      final parsed = TransactionModel.fromMap(map, id: 'fallback-id');

      expect(parsed.id, 'fallback-id');
      expect(parsed.amount, 25000);
      expect(parsed.type, 'expense'); // default
      expect(parsed.categoryName, '');
      expect(parsed.monthKey, isNotEmpty);
      expect(parsed.dateKey, isNotEmpty);
    });

    test('toDashboardTransaction converts to Domain Model with correct signed amounts', () {
      // Expense -> negative amount
      final dtExpense = sampleTx.toDashboardTransaction();
      expect(dtExpense.id, sampleTx.id);
      expect(dtExpense.category, 'Makanan & Minuman');
      expect(dtExpense.amount, -150000);
      expect(dtExpense.type, TransactionType.expense);
      expect(dtExpense.meta, '14.30 · Makan siang bersama tim');
      expect(dtExpense.dateStr, '10 Oktober 2026');

      // Income -> positive amount
      final incomeTx = sampleTx.copyWith(
        id: 'tx-inc-01',
        type: 'income',
        amount: 2000000,
        notes: '',
      );
      final dtIncome = incomeTx.toDashboardTransaction();
      expect(dtIncome.amount, 2000000);
      expect(dtIncome.type, TransactionType.income);
      expect(dtIncome.meta, '14.30'); // no note trailing
    });

    test('fromDashboardTransaction converts back to TransactionModel accurately', () {
      final dashboardTx = DashboardTransaction(
        id: 'dt-101',
        dateStr: '10 Oktober 2026',
        dateKey: '2026-10-10',
        year: 2026,
        month: 9,
        day: 10,
        category: 'Transportasi',
        meta: '08.15 · Bensin motor',
        amount: -50000,
        type: TransactionType.expense,
        icon: Icons.directions_bus_rounded,
      );

      final model = TransactionModel.fromDashboardTransaction(
        dashboardTx,
        categoryId: 'exp-2',
      );

      expect(model.id, 'dt-101');
      expect(model.type, 'expense');
      expect(model.amount, 50000); // absolute
      expect(model.categoryId, 'exp-2');
      expect(model.categoryName, 'Transportasi');
      expect(model.timeStr, '08.15');
      expect(model.notes, 'Bensin motor');
      expect(model.monthKey, '2026-10');
      expect(model.year, 2026);
      expect(model.month, 9);
      expect(model.day, 10);
    });

    test('copyWith and value equality work as expected', () {
      final copy = sampleTx.copyWith(amount: 250000);

      expect(copy.amount, 250000);
      expect(copy.id, sampleTx.id);
      expect(copy == sampleTx, isFalse);

      final identicalCopy = sampleTx.copyWith();
      expect(identicalCopy == sampleTx, isTrue);
      expect(identicalCopy.hashCode, sampleTx.hashCode);
    });
  });
}
