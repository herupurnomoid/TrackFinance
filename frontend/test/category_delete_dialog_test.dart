import 'dart:async';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_finance/core/models/user_profile.dart';
import 'package:track_finance/core/theme/app_theme.dart';
import 'package:track_finance/features/category/data/category_model.dart';
import 'package:track_finance/features/category/data/category_repository.dart';
import 'package:track_finance/core/widgets/animations.dart';
import 'package:track_finance/features/category/presentation/screens/category_screen.dart';
import 'package:track_finance/features/category/presentation/widgets/category_delete_dialog.dart';

void main() {
  group('CategoryDeleteDialog Integration Tests (CAT-10)', () {
    Widget buildDialogHarness({
      required String categoryName,
      int transactionCount = 0,
      required FutureOr<void> Function() onConfirmDelete,
    }) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (dialogContext) => CategoryDeleteDialog(
                      categoryName: categoryName,
                      transactionCount: transactionCount,
                      onConfirmDelete: onConfirmDelete,
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('Renders zero-transaction delete dialog with title and description', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildDialogHarness(
          categoryName: 'Langganan TV',
          transactionCount: 0,
          onConfirmDelete: () {},
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Hapus kategori Langganan TV?'), findsOneWidget);
      expect(find.text('Kategori ini akan dihapus dari daftar.'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);
      expect(find.text('Hapus'), findsOneWidget);
    });

    testWidgets('Renders dialog with transaction warning when transactionCount > 0', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        buildDialogHarness(
          categoryName: 'Transportasi',
          transactionCount: 7,
          onConfirmDelete: () {},
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Hapus kategori Transportasi?'), findsOneWidget);
      expect(
        find.text('7 transaksi di kategori ini akan dipindahkan ke ‘Lainnya’.'),
        findsOneWidget,
      );
    });

    testWidgets('Tapping Batal cancels dialog without calling onConfirmDelete', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      bool deleteCalled = false;

      await tester.pumpWidget(
        buildDialogHarness(
          categoryName: 'Kesehatan',
          transactionCount: 0,
          onConfirmDelete: () {
            deleteCalled = true;
          },
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      expect(deleteCalled, isFalse);
      expect(find.text('Hapus kategori Kesehatan?'), findsNothing);
    });

    testWidgets('Tapping Hapus shows loading and executes onConfirmDelete', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      final completer = Completer<void>();
      bool deleteCalled = false;

      await tester.pumpWidget(
        buildDialogHarness(
          categoryName: 'Kopi',
          transactionCount: 0,
          onConfirmDelete: () async {
            deleteCalled = true;
            await completer.future;
          },
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hapus'));
      await tester.pump(); // Start async deletion

      expect(deleteCalled, isTrue);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete();
      await tester.pumpAndSettle();

      // Dialog is dismissed
      expect(find.text('Hapus kategori Kopi?'), findsNothing);
    });

    testWidgets('End-to-End: CategoryScreen delete flow invokes repo and shows floating toast feedback', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      final fakeFirestore = FakeFirebaseFirestore();
      final repository = CategoryRepository(firestore: fakeFirestore);
      const testUser = UserProfile(
        uid: 'user_delete_e2e_10',
        email: 'user10@trackfinance.app',
        displayName: 'Delete Tester',
      );

      // Add custom category to delete
      const customCat = CategoryItem(
        id: 'cat-custom-del-10',
        name: 'Gym & Fitness',
        icon: Icons.fitness_center_rounded,
        color: Color(0xFF2563EB),
        isExpense: true,
        isCustom: true,
        order: 9,
      );
      await repository.addCategory(testUser.uid, customCat);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: CategoryScreen(
            user: testUser,
            repository: repository,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap on Gym & Fitness tile to open bottom sheet
      expect(find.text('Gym & Fitness'), findsOneWidget);
      await tester.tap(find.text('Gym & Fitness'));
      await tester.pumpAndSettle();

      // In bottom sheet, tap Hapus
      expect(find.text('Edit Kategori'), findsOneWidget);
      expect(find.text('Hapus'), findsOneWidget);
      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      // Confirmation dialog is shown
      expect(find.text('Hapus kategori Gym & Fitness?'), findsOneWidget);
      expect(find.text('Kategori ini akan dihapus dari daftar.'), findsOneWidget);

      // Confirm delete in dialog
      await tester.tap(find.widgetWithText(PressableScale, 'Hapus'));
      await tester.pumpAndSettle();

      // Floating toast feedback is displayed
      expect(find.text('Kategori "Gym & Fitness" berhasil dihapus'), findsOneWidget);

      // Verify removed from Firestore
      final categories = await repository.getCategories(testUser.uid);
      expect(categories.any((c) => c.id == 'cat-custom-del-10'), isFalse);

      // Advance timer so floating toast timer completes before widget disposal
      await tester.pump(const Duration(milliseconds: 2600));
    });
  });
}
