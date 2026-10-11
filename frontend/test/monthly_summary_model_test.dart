import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_finance/features/transaction/data/monthly_summary_model.dart';

void main() {
  group('MonthlySummaryModel Unit Tests (TX-02)', () {
    final sampleSummary = MonthlySummaryModel(
      monthKey: '2026-10',
      year: 2026,
      month: 9,
      totalIncome: 10000000,
      totalExpense: 4500000,
      netCashflow: 5500000,
      transactionCount: 15,
      categoryBreakdown: {
        'exp-1': {
          'name': 'Makanan & Minuman',
          'total': 1500000,
          'count': 10,
        },
        'exp-2': {
          'name': 'Transportasi',
          'total': 500000,
          'count': 5,
        },
      },
    );

    test('Properties and getters are correct', () {
      expect(sampleSummary.monthKey, '2026-10');
      expect(sampleSummary.year, 2026);
      expect(sampleSummary.month, 9);
      expect(sampleSummary.totalIncome, 10000000);
      expect(sampleSummary.totalExpense, 4500000);
      expect(sampleSummary.netCashflow, 5500000);
      expect(sampleSummary.transactionCount, 15);
      expect(sampleSummary.categoryBreakdown.length, 2);
    });

    test('typedCategoryBreakdown transforms map to CategoryBreakdownItem properly', () {
      final breakdown = sampleSummary.typedCategoryBreakdown;

      expect(breakdown.containsKey('exp-1'), isTrue);
      expect(breakdown['exp-1']?.name, 'Makanan & Minuman');
      expect(breakdown['exp-1']?.total, 1500000);
      expect(breakdown['exp-1']?.count, 10);

      expect(breakdown.containsKey('exp-2'), isTrue);
      expect(breakdown['exp-2']?.name, 'Transportasi');
      expect(breakdown['exp-2']?.total, 500000);
      expect(breakdown['exp-2']?.count, 5);
    });

    test('toFirestore serializes fields correctly', () {
      final map = sampleSummary.toFirestore();

      expect(map['monthKey'], '2026-10');
      expect(map['year'], 2026);
      expect(map['month'], 9);
      expect(map['totalIncome'], 10000000);
      expect(map['totalExpense'], 4500000);
      expect(map['netCashflow'], 5500000);
      expect(map['transactionCount'], 15);
      expect(map['updatedAt'], isA<FieldValue>());
    });

    test('fromMap parses map and computes netCashflow when missing', () {
      final rawMap = {
        'year': 2026,
        'month': 9,
        'totalIncome': 8000000,
        'totalExpense': 3000000,
        'transactionCount': 8,
      };

      final parsed = MonthlySummaryModel.fromMap(rawMap, monthKey: '2026-10');

      expect(parsed.monthKey, '2026-10');
      expect(parsed.totalIncome, 8000000);
      expect(parsed.totalExpense, 3000000);
      expect(parsed.netCashflow, 5000000); // 8m - 3m
      expect(parsed.transactionCount, 8);
    });

    test('fromMap handles dotted category breakdown fields', () {
      final dottedMap = {
        'monthKey': '2026-10',
        'year': 2026,
        'month': 9,
        'totalIncome': 5000000,
        'totalExpense': 2000000,
        'transactionCount': 3,
        'categoryBreakdown.exp-3.name': 'Belanja',
        'categoryBreakdown.exp-3.total': 300000,
        'categoryBreakdown.exp-3.count': 2,
      };

      final parsed = MonthlySummaryModel.fromMap(dottedMap);
      final breakdown = parsed.typedCategoryBreakdown;

      expect(breakdown.containsKey('exp-3'), isTrue);
      expect(breakdown['exp-3']?.name, 'Belanja');
      expect(breakdown['exp-3']?.total, 300000);
      expect(breakdown['exp-3']?.count, 2);
    });

    test('CategoryBreakdownItem value equality and copyWith', () {
      const item1 = CategoryBreakdownItem(name: 'Investasi', total: 1000000, count: 2);
      const item2 = CategoryBreakdownItem(name: 'Investasi', total: 1000000, count: 2);
      final item3 = item1.copyWith(total: 2000000);

      expect(item1, equals(item2));
      expect(item1 == item3, isFalse);
      expect(item1.hashCode, item2.hashCode);
    });

    test('MonthlySummaryModel value equality and copyWith', () {
      final copy = sampleSummary.copyWith(totalIncome: 12000000);
      expect(copy.totalIncome, 12000000);
      expect(copy == sampleSummary, isFalse);

      final identicalCopy = sampleSummary.copyWith();
      expect(identicalCopy, equals(sampleSummary));
    });
  });
}
