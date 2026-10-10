import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_finance/features/category/data/category_model.dart';

void main() {
  group('CategoryItem Model & Serialization Unit Tests (CAT-01)', () {
    test('Default values and field assignments test', () {
      const item = CategoryItem(
        id: 'cat-test-1',
        name: 'Transportasi',
        icon: Icons.two_wheeler_rounded,
        isExpense: true,
      );

      expect(item.id, 'cat-test-1');
      expect(item.name, 'Transportasi');
      expect(item.icon, Icons.two_wheeler_rounded);
      expect(item.isExpense, isTrue);
      expect(item.isCustom, isFalse);
      expect(item.isLocked, isFalse);
      expect(item.order, 0);
      expect(item.color, const Color(0xFF2563EB));
      expect(item.createdAt, isNull);
      expect(item.updatedAt, isNull);
    });

    test('CategoryItem copyWith updates targeted fields only', () {
      final now = DateTime(2026, 10, 10, 12, 0);
      final original = CategoryItem(
        id: 'cat-test-1',
        name: 'Makanan',
        icon: Icons.restaurant_rounded,
        isExpense: true,
        isCustom: false,
        isLocked: false,
        order: 1,
        color: const Color(0xFFDC2626),
        createdAt: now,
        updatedAt: now,
      );

      final updated = original.copyWith(
        name: 'Kuliner Lezat',
        order: 5,
        isCustom: true,
      );

      expect(updated.id, original.id);
      expect(updated.name, 'Kuliner Lezat');
      expect(updated.icon, original.icon);
      expect(updated.isExpense, original.isExpense);
      expect(updated.isCustom, isTrue);
      expect(updated.isLocked, original.isLocked);
      expect(updated.order, 5);
      expect(updated.color, original.color);
      expect(updated.createdAt, now);
      expect(updated.updatedAt, now);
    });

    test('toMap and fromMap serialization roundtrip test', () {
      final createdAt = DateTime(2026, 10, 10, 9, 30);
      final updatedAt = DateTime(2026, 10, 10, 10, 45);

      final item = CategoryItem(
        id: 'cat-roundtrip-1',
        name: 'Belanja Bulanan',
        icon: Icons.shopping_bag_rounded,
        isExpense: true,
        isCustom: true,
        isLocked: false,
        order: 3,
        color: const Color(0xFF16A34A),
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      final map = item.toMap();
      expect(map['id'], 'cat-roundtrip-1');
      expect(map['name'], 'Belanja Bulanan');
      expect(map['iconCode'], Icons.shopping_bag_rounded.codePoint);
      expect(map['isExpense'], isTrue);
      expect(map['isCustom'], isTrue);
      expect(map['isLocked'], isFalse);
      expect(map['order'], 3);
      expect(map['color'], const Color(0xFF16A34A).toARGB32());
      expect(map['createdAt'], createdAt.toIso8601String());
      expect(map['updatedAt'], updatedAt.toIso8601String());

      final restored = CategoryItem.fromMap(map);
      expect(restored.id, item.id);
      expect(restored.name, item.name);
      expect(restored.icon.codePoint, item.icon.codePoint);
      expect(restored.isExpense, item.isExpense);
      expect(restored.isCustom, item.isCustom);
      expect(restored.isLocked, item.isLocked);
      expect(restored.order, item.order);
      expect(restored.color.toARGB32(), item.color.toARGB32());
      expect(restored.createdAt, createdAt);
      expect(restored.updatedAt, updatedAt);
    });

    test('fromMap handles Timestamp, String, and int epoch dates', () {
      final tsDate = DateTime(2026, 1, 1, 12, 0);
      final mapWithTimestamp = {
        'id': 'cat-ts',
        'name': 'Gaji',
        'iconCode': Icons.payments_rounded.codePoint,
        'color': const Color(0xFF16A34A).toARGB32(),
        'isExpense': false,
        'createdAt': Timestamp.fromDate(tsDate),
        'updatedAt': Timestamp.fromDate(tsDate),
      };

      final fromTs = CategoryItem.fromMap(mapWithTimestamp);
      expect(fromTs.createdAt, tsDate);
      expect(fromTs.updatedAt, tsDate);
      expect(fromTs.isExpense, isFalse);

      final mapWithEpoch = {
        'id': 'cat-epoch',
        'name': 'Bonus',
        'createdAt': tsDate.millisecondsSinceEpoch,
        'updatedAt': tsDate.millisecondsSinceEpoch,
      };

      final fromEpoch = CategoryItem.fromMap(mapWithEpoch);
      expect(fromEpoch.createdAt, tsDate);
      expect(fromEpoch.updatedAt, tsDate);
    });

    test('toFirestore includes all required fields and serverTimestamp', () {
      final createdAt = DateTime(2026, 10, 10, 8, 0);
      final item = CategoryItem(
        id: 'cat-fs-1',
        name: 'Investasi Saham',
        icon: Icons.trending_up_rounded,
        isExpense: false,
        isCustom: true,
        isLocked: false,
        order: 4,
        color: const Color(0xFF16A34A),
        createdAt: createdAt,
      );

      final fsMap = item.toFirestore();

      expect(fsMap['id'], 'cat-fs-1');
      expect(fsMap['name'], 'Investasi Saham');
      expect(fsMap['iconCode'], Icons.trending_up_rounded.codePoint);
      expect(fsMap['color'], const Color(0xFF16A34A).toARGB32());
      expect(fsMap['isExpense'], isFalse);
      expect(fsMap['isCustom'], isTrue);
      expect(fsMap['isLocked'], isFalse);
      expect(fsMap['order'], 4);
      expect(fsMap['createdAt'], isA<Timestamp>());
      expect((fsMap['createdAt'] as Timestamp).toDate(), createdAt);
      expect(fsMap['updatedAt'], isA<FieldValue>());
    });

    test('DefaultCategories validates 8 expenses and 6 incomes with locked items', () {
      final expenses = DefaultCategories.defaultExpenseCategories;
      final incomes = DefaultCategories.defaultIncomeCategories;

      expect(expenses.length, 8);
      expect(incomes.length, 6);

      // Verify expense orders and properties
      for (int i = 0; i < expenses.length; i++) {
        final cat = expenses[i];
        expect(cat.isExpense, isTrue);
        expect(cat.isCustom, isFalse);
        expect(cat.order, i + 1);
        expect(cat.id, 'exp-${i + 1}');
      }

      // Verify income orders and properties
      for (int i = 0; i < incomes.length; i++) {
        final cat = incomes[i];
        expect(cat.isExpense, isFalse);
        expect(cat.isCustom, isFalse);
        expect(cat.order, i + 1);
        expect(cat.id, 'inc-${i + 1}');
      }

      // Locked system fallback categories
      final lockedExpense = expenses.firstWhere((c) => c.name == 'Lainnya');
      expect(lockedExpense.id, 'exp-8');
      expect(lockedExpense.isLocked, isTrue);

      final lockedIncome = incomes.firstWhere((c) => c.name == 'Lainnya');
      expect(lockedIncome.id, 'inc-6');
      expect(lockedIncome.isLocked, isTrue);
    });

    test('Equality, hashCode, and toString test', () {
      const item1 = CategoryItem(
        id: 'cat-eq-1',
        name: 'Pendidikan',
        icon: Icons.school_rounded,
        isExpense: true,
        order: 7,
      );

      const item2 = CategoryItem(
        id: 'cat-eq-1',
        name: 'Pendidikan',
        icon: Icons.school_rounded,
        isExpense: true,
        order: 7,
      );

      const item3 = CategoryItem(
        id: 'cat-eq-2',
        name: 'Hiburan',
        icon: Icons.sports_esports_rounded,
        isExpense: true,
        order: 6,
      );

      expect(item1, equals(item2));
      expect(item1.hashCode, equals(item2.hashCode));
      expect(item1, isNot(equals(item3)));
      expect(item1.toString(), contains('cat-eq-1'));
    });
  });
}
