import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_finance/features/category/data/category_model.dart';
import 'package:track_finance/features/category/data/category_repository.dart';
import 'package:track_finance/features/category/presentation/screens/category_screen.dart';

void main() {
  testWidgets('CategoryScreen SingleChildScrollView fills full viewport and does not clip bottom row', (tester) async {
    tester.view.physicalSize = const Size(460, 1024);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    CategoryRepository.inMemoryExpenseCategories.clear();
    for (int i = 1; i <= 13; i++) {
      CategoryRepository.inMemoryExpenseCategories.add(
        CategoryItem(
          id: 'exp-$i',
          name: 'Category $i',
          icon: Icons.fastfood,
          isExpense: true,
          order: i,
        ),
      );
    }

    await tester.pumpWidget(
      const MaterialApp(
        home: CategoryScreen(),
      ),
    );
    await tester.pumpAndSettle();

    final singleChildFinder = find.byType(SingleChildScrollView);
    expect(singleChildFinder, findsOneWidget);

    final singleChildBox = tester.renderObject(singleChildFinder) as RenderBox;
    // Viewport must expand to fill the full remaining canvas height (948px), not shrink-wrap (e.g. 576px)
    expect(singleChildBox.size.height, greaterThanOrEqualTo(948.0));

    final addTile = find.text('Tambah');
    expect(addTile, findsOneWidget);

    // Test dragging/pull-to-refresh: bottom row must remain visible and unclipped
    await tester.drag(singleChildFinder, const Offset(0, 120));
    await tester.pump();
    expect(addTile, findsOneWidget);
  });
}
