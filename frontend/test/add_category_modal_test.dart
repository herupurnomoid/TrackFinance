import 'dart:async';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_finance/core/theme/app_theme.dart';
import 'package:track_finance/features/category/data/category_model.dart';
import 'package:track_finance/features/category/data/category_repository.dart';
import 'package:track_finance/features/category/presentation/widgets/add_category_modal.dart';

void main() {
  group('AddCategoryModal Integration Tests (CAT-09)', () {
    Widget buildModalHarness({
      CategoryItem? categoryToEdit,
      bool initialIsExpense = true,
      List<String> existingNames = const [],
      required FutureOr<void> Function(String name, IconData icon, Color color, bool isExpense) onSave,
      VoidCallback? onDelete,
    }) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (sheetContext) => AddCategoryModal(
                      categoryToEdit: categoryToEdit,
                      initialIsExpense: initialIsExpense,
                      existingNames: existingNames,
                      onSave: onSave,
                      onDelete: onDelete,
                    ),
                  );
                },
                child: const Text('Open Modal'),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('Renders Add Category mode and displays default elements', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildModalHarness(
          initialIsExpense: true,
          existingNames: const ['Makanan', 'Gaji'],
          onSave: (_, _, _, _) {},
        ),
      );

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      expect(find.text('Tambah Kategori'), findsOneWidget);
      expect(find.text('Simpan Kategori'), findsOneWidget);
      expect(find.text('Hapus'), findsNothing);
    });

    testWidgets('Renders Edit Category mode and displays category details & delete button', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      bool deleteTriggered = false;

      const editCat = CategoryItem(
        id: 'cat-edit-1',
        name: 'Hobi & Game',
        icon: Icons.sports_esports_rounded,
        color: Color(0xFF9333EA),
        isExpense: true,
        isCustom: true,
      );

      await tester.pumpWidget(
        buildModalHarness(
          categoryToEdit: editCat,
          initialIsExpense: true,
          existingNames: const ['Makanan', 'Hobi & Game'],
          onSave: (_, _, _, _) {},
          onDelete: () {
            deleteTriggered = true;
          },
        ),
      );

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Kategori'), findsOneWidget);
      expect(find.text('Simpan Perubahan'), findsOneWidget);
      expect(find.text('Hapus'), findsOneWidget);
      expect(find.text('Hobi & Game'), findsWidgets);

      // Tap delete button
      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();
      expect(deleteTriggered, isTrue);
    });

    testWidgets('Prevents duplicate name and displays validation error message', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildModalHarness(
          initialIsExpense: true,
          existingNames: const ['Makanan & Minuman', 'Transportasi'],
          onSave: (_, _, _, _) {},
        ),
      );

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Enter duplicate name
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'makanan & minuman');
      await tester.pumpAndSettle();

      expect(find.text('Nama sudah dipakai. Gunakan nama yang berbeda.'), findsOneWidget);
    });

    testWidgets('Shows loading indicator (CircularProgressIndicator & Menyimpan...) during async onSave', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      final completer = Completer<void>();
      bool saved = false;

      await tester.pumpWidget(
        buildModalHarness(
          initialIsExpense: true,
          existingNames: const [],
          onSave: (name, icon, color, isExpense) async {
            saved = true;
            await completer.future;
          },
        ),
      );

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      // Enter name
      await tester.enterText(find.byType(TextField), 'Kopi & Nongkrong');
      await tester.pumpAndSettle();

      // Tap save button
      await tester.tap(find.text('Simpan Kategori'));
      await tester.pump(); // Start async work

      expect(saved, isTrue);
      expect(find.text('Menyimpan...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete the save
      completer.complete();
      await tester.pumpAndSettle();

      // After complete, modal pops and returning to underlying route
      expect(find.text('Open Modal'), findsOneWidget);
      expect(find.text('Menyimpan...'), findsNothing);
    });

    testWidgets('Full integration: AddCategoryModal writes to CategoryRepository in FakeFirestore', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      final fakeFirestore = FakeFirebaseFirestore();
      final repository = CategoryRepository(firestore: fakeFirestore);
      const testUid = 'user_cat_09_test';

      await tester.pumpWidget(
        buildModalHarness(
          initialIsExpense: true,
          existingNames: const [],
          onSave: (name, icon, color, isExpense) async {
            final newCat = CategoryItem(
              id: 'cat-new-09',
              name: name,
              icon: icon,
              color: color,
              isExpense: isExpense,
              isCustom: true,
              order: 1,
            );
            await repository.addCategory(testUid, newCat);
          },
        ),
      );

      await tester.tap(find.text('Open Modal'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Langganan AI');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Simpan Kategori'));
      await tester.pumpAndSettle();

      // Verify modal dismissed
      expect(find.text('Open Modal'), findsOneWidget);

      // Verify stored in Firestore
      final categories = await repository.getCategories(testUid);
      expect(categories.length, equals(1));
      expect(categories.first.name, equals('Langganan AI'));
      expect(categories.first.isCustom, isTrue);
    });
  });
}
