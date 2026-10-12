import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_finance/core/models/user_profile.dart';
import 'package:track_finance/core/theme/app_theme.dart';
import 'package:track_finance/features/category/data/category_model.dart';
import 'package:track_finance/features/category/data/category_repository.dart';
import 'package:track_finance/features/category/presentation/screens/category_screen.dart';
import 'package:track_finance/features/transaction/data/transaction_repository.dart';
import 'package:track_finance/features/transaction/presentation/screens/add_transaction_screen.dart';
import 'package:track_finance/features/transaction/presentation/widgets/all_categories_bottom_sheet.dart';

void main() {
  group('AddTransactionScreen & Category Management Synchronization Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late CategoryRepository categoryRepo;
    late TransactionRepository txRepo;

    const testUser = UserProfile(
      uid: 'user_sync_test_01',
      email: 'user@trackfinance.app',
      displayName: 'Heru',
      photoUrl: null,
    );

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();
      categoryRepo = CategoryRepository(firestore: fakeFirestore);
      CategoryRepository.instance = categoryRepo;
      txRepo = TransactionRepository(firestore: fakeFirestore);
      TransactionRepository.instance = txRepo;

      // Seed default categories for testUser
      await categoryRepo.seedDefaultCategoriesIfEmpty(testUser.uid);
    });

    testWidgets('AddTransactionScreen displays categories from Category Management stream', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AddTransactionScreen(user: testUser),
        ),
      );
      await tester.pumpAndSettle();

      // Expense categories from DefaultCategories should appear
      expect(find.text('Makanan & Minuman'), findsOneWidget);
      expect(find.text('Transportasi'), findsOneWidget);
      expect(find.text('Belanja Harian'), findsOneWidget);
      expect(find.text('Tagihan & Pulsa'), findsOneWidget);

      // Verify old dummy names like 'Makanan' alone or 'Belanja' alone do not exist
      expect(find.text('Makanan'), findsNothing);
      expect(find.text('Belanja'), findsNothing);

      // Verify the more button is named 'Lebih Banyak' to avoid ambiguity with category 'Lainnya'
      expect(find.text('Lebih Banyak'), findsOneWidget);

      // Verify tapping 'Lebih Banyak' opens AllCategoriesBottomSheet containing full category list
      await tester.tap(find.text('Lebih Banyak'));
      await tester.pumpAndSettle();
      expect(find.byType(AllCategoriesBottomSheet), findsOneWidget);
      // In bottom sheet, the actual category 'Lainnya' is available and selectable
      expect(find.text('Lainnya'), findsOneWidget);
      await tester.tap(find.text('Lainnya'));
      await tester.pumpAndSettle();

      // Switch to Pemasukan tab
      await tester.tap(find.text('Pemasukan'));
      await tester.pumpAndSettle();

      // Income categories should appear
      expect(find.text('Gaji Pokok'), findsOneWidget);
      expect(find.text('Bonus'), findsOneWidget);
      expect(find.text('Investasi'), findsOneWidget);
      expect(find.text('Lebih Banyak'), findsOneWidget);
    });

    testWidgets('Adding, updating, and deleting categories in Firestore immediately reflects in AddTransactionScreen', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AddTransactionScreen(user: testUser),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Add new custom expense category via category repository
      const customCategory = CategoryItem(
        id: 'cat_custom_kopi',
        name: 'Kopi & Nongkrong',
        icon: Icons.coffee_rounded,
        color: Colors.brown,
        isExpense: true,
      );
      await categoryRepo.addCategory(testUser.uid, customCategory);
      await tester.pumpAndSettle();

      // The new category should immediately appear on AddTransactionScreen
      expect(find.text('Kopi & Nongkrong'), findsOneWidget);

      // 2. Update category name (e.g. from 'Kopi & Nongkrong' to 'Kopi Spesial')
      final updatedCategory = customCategory.copyWith(name: 'Kopi Spesial');
      await categoryRepo.updateCategory(testUser.uid, updatedCategory);
      await tester.pumpAndSettle();

      expect(find.text('Kopi & Nongkrong'), findsNothing);
      expect(find.text('Kopi Spesial'), findsOneWidget);

      // 3. Delete category
      await categoryRepo.deleteCategory(testUser.uid, customCategory.id);
      await tester.pumpAndSettle();

      expect(find.text('Kopi Spesial'), findsNothing);
    });

    testWidgets('Tapping Kelola Kategori & Ikon navigates to CategoryScreen and refreshes categories', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const AddTransactionScreen(user: testUser),
        ),
      );
      await tester.pumpAndSettle();

      // Tap 'Kelola Kategori & Ikon'
      await tester.tap(find.text('Kelola Kategori & Ikon'));
      await tester.pumpAndSettle();

      // Verify CategoryScreen is opened
      expect(find.byType(CategoryScreen), findsOneWidget);
      expect(find.text('Kategori'), findsWidgets);

      // Pop back to AddTransactionScreen
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(AddTransactionScreen), findsOneWidget);
    });

    testWidgets('Transaction saved with selected category contains exact categoryId and categoryName from Category Management', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      // Add a custom category
      const customCategory = CategoryItem(
        id: 'cat_custom_gym',
        name: 'Gym & Fitness',
        icon: Icons.fitness_center_rounded,
        color: Colors.orange,
        isExpense: true,
      );
      await categoryRepo.addCategory(testUser.uid, customCategory);

      dynamic savedResult;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                savedResult = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddTransactionScreen(user: testUser),
                  ),
                );
              },
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Enter nominal
      final amountField = find.byType(TextField).first;
      await tester.enterText(amountField, '75000');
      await tester.pump();

      // Select custom category
      expect(find.text('Gym & Fitness'), findsOneWidget);
      await tester.tap(find.text('Gym & Fitness'));
      await tester.pump();

      // Save transaction
      await tester.tap(find.text('Simpan Transaksi'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      // Check transaction saved in Firestore repository
      final txs = await txRepo.watchRecentTransactions(testUser.uid).first;
      expect(txs.length, 1);
      expect(txs.first.categoryId, 'cat_custom_gym');
      expect(txs.first.categoryName, 'Gym & Fitness');
      expect(txs.first.amount, 75000);
      expect(savedResult, isNotNull);
    });
  });
}
