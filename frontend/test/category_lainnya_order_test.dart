import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_finance/features/category/data/category_model.dart';
import 'package:track_finance/features/category/data/category_repository.dart';
import 'package:track_finance/features/category/presentation/screens/category_screen.dart';

void main() {
  group('Category "Lainnya" Order Tests', () {
    test('sortCategoriesWithLainnyaLast places "Lainnya" / isLocked at the very end', () {
      final input = <CategoryItem>[
        const CategoryItem(id: 'c1', name: 'Makanan & Minuman', icon: Icons.fastfood, isExpense: true, order: 1),
        const CategoryItem(id: 'c2', name: 'Lainnya', icon: Icons.more_horiz, isLocked: true, isExpense: true, order: 2),
        const CategoryItem(id: 'c3', name: 'Transportasi', icon: Icons.directions_bus, isExpense: true, order: 3),
        const CategoryItem(id: 'c4', name: 'WiFi', icon: Icons.wifi, isExpense: true, isCustom: true, order: 4),
      ];

      final sorted = CategoryRepository.sortCategoriesWithLainnyaLast(input);
      expect(sorted.map((c) => c.name).toList(), [
        'Makanan & Minuman',
        'Transportasi',
        'WiFi',
        'Lainnya',
      ]);
      expect(sorted.last.name, 'Lainnya');
    });

    testWidgets('CategoryScreen always displays "Lainnya" as the last category item before Tambah button', (tester) async {
      tester.view.physicalSize = const Size(460, 1024);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      CategoryRepository.inMemoryExpenseCategories
        ..clear()
        ..addAll([
          const CategoryItem(id: 'exp-1', name: 'Makanan & Minuman', icon: Icons.fastfood, isExpense: true, order: 1),
          const CategoryItem(id: 'exp-2', name: 'Lainnya', icon: Icons.more_horiz, isLocked: true, isExpense: true, order: 2),
          const CategoryItem(id: 'exp-3', name: 'Bengkel', icon: Icons.build, isExpense: true, order: 3),
          const CategoryItem(id: 'exp-4', name: 'Donasi', icon: Icons.card_giftcard, isExpense: true, order: 4),
          const CategoryItem(id: 'exp-5', name: 'WiFi', icon: Icons.wifi, isExpense: true, order: 5),
        ]);

      await tester.pumpWidget(
        const MaterialApp(
          home: CategoryScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Find all category item names rendered
      final makananRect = tester.getRect(find.text('Makanan & Minuman'));
      final bengkelRect = tester.getRect(find.text('Bengkel'));
      final donasiRect = tester.getRect(find.text('Donasi'));
      final wifiRect = tester.getRect(find.text('WiFi'));
      final lainnyaRect = tester.getRect(find.text('Lainnya'));
      final tambahRect = tester.getRect(find.text('Tambah'));

      // Verify custom categories are rendered in order before Lainnya
      expect(bengkelRect.left, greaterThan(makananRect.left));
      expect(donasiRect.left, greaterThan(bengkelRect.left));
      expect(wifiRect.left, greaterThan(donasiRect.left));
      // Verify Lainnya is placed after all custom categories (Donasi, Bengkel, WiFi)
      expect(lainnyaRect.top, greaterThanOrEqualTo(wifiRect.top));
      // And Tambah is after Lainnya
      expect(tambahRect.left, greaterThan(lainnyaRect.left));
    });
  });
}
