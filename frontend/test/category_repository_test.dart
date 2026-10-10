import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_finance/features/category/data/category_model.dart';
import 'package:track_finance/features/category/data/category_repository.dart';

void main() {
  group('CategoryRepository Seeder Unit Tests (CAT-02)', () {
    late FakeFirebaseFirestore fakeFirestore;
    late CategoryRepository repository;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      repository = CategoryRepository(firestore: fakeFirestore);
    });

    test('seedDefaultCategoriesIfEmpty successfully seeds 14 categories for new user', () async {
      const uid = 'test_user_123';

      // Verify categories subcollection is empty initially
      final initialSnapshot = await fakeFirestore
          .collection('users')
          .doc(uid)
          .collection('categories')
          .get();
      expect(initialSnapshot.docs, isEmpty);

      // Execute seeding
      final seeded = await repository.seedDefaultCategoriesIfEmpty(uid);
      expect(seeded, isTrue);

      // Query seeded categories
      final resultSnapshot = await fakeFirestore
          .collection('users')
          .doc(uid)
          .collection('categories')
          .get();

      expect(resultSnapshot.docs.length, 14);

      // Verify all 8 expense categories
      final expenseDocs = resultSnapshot.docs
          .where((doc) => doc.data()['isExpense'] == true)
          .toList()
        ..sort((a, b) => (a.data()['order'] as int).compareTo(b.data()['order'] as int));

      expect(expenseDocs.length, 8);
      for (int i = 0; i < expenseDocs.length; i++) {
        final doc = expenseDocs[i];
        final data = doc.data();
        expect(doc.id, 'exp-${i + 1}');
        expect(data['id'], 'exp-${i + 1}');
        expect(data['order'], i + 1);
        expect(data['isExpense'], isTrue);
        expect(data['isCustom'], isFalse);
        expect(data['name'], isNotEmpty);
        expect(data['iconCode'], isNotNull);
        expect(data['color'], isNotNull);
      }

      // Verify "Lainnya" locked flag on exp-8
      final lockedExpense = expenseDocs.firstWhere((d) => d.id == 'exp-8');
      expect(lockedExpense.data()['isLocked'], isTrue);
      expect(lockedExpense.data()['name'], 'Lainnya');

      // Verify non-locked expense
      final unlockedExpense = expenseDocs.firstWhere((d) => d.id == 'exp-1');
      expect(unlockedExpense.data()['isLocked'], isFalse);

      // Verify all 6 income categories
      final incomeDocs = resultSnapshot.docs
          .where((doc) => doc.data()['isExpense'] == false)
          .toList()
        ..sort((a, b) => (a.data()['order'] as int).compareTo(b.data()['order'] as int));

      expect(incomeDocs.length, 6);
      for (int i = 0; i < incomeDocs.length; i++) {
        final doc = incomeDocs[i];
        final data = doc.data();
        expect(doc.id, 'inc-${i + 1}');
        expect(data['id'], 'inc-${i + 1}');
        expect(data['order'], i + 1);
        expect(data['isExpense'], isFalse);
        expect(data['isCustom'], isFalse);
        expect(data['name'], isNotEmpty);
      }

      // Verify "Lainnya" locked flag on inc-6
      final lockedIncome = incomeDocs.firstWhere((d) => d.id == 'inc-6');
      expect(lockedIncome.data()['isLocked'], isTrue);
      expect(lockedIncome.data()['name'], 'Lainnya');
    });

    test('seedDefaultCategoriesIfEmpty is idempotent and does not overwrite existing data', () async {
      const uid = 'test_user_idempotent';

      // First seeding
      final firstRun = await repository.seedDefaultCategoriesIfEmpty(uid);
      expect(firstRun, isTrue);

      // Second seeding attempt
      final secondRun = await repository.seedDefaultCategoriesIfEmpty(uid);
      expect(secondRun, isFalse);

      // Document count must still be exactly 14
      final snapshot = await fakeFirestore
          .collection('users')
          .doc(uid)
          .collection('categories')
          .get();
      expect(snapshot.docs.length, 14);
    });

    test('seedDefaultCategoriesIfEmpty returns false for empty or whitespace UID', () async {
      final emptyResult = await repository.seedDefaultCategoriesIfEmpty('');
      expect(emptyResult, isFalse);

      final whitespaceResult = await repository.seedDefaultCategoriesIfEmpty('   ');
      expect(whitespaceResult, isFalse);
    });

    test('User data isolation: seeding user A does not seed user B', () async {
      const uidA = 'user_alpha';
      const uidB = 'user_beta';

      await repository.seedDefaultCategoriesIfEmpty(uidA);

      final docsA = await fakeFirestore
          .collection('users')
          .doc(uidA)
          .collection('categories')
          .get();
      final docsB = await fakeFirestore
          .collection('users')
          .doc(uidB)
          .collection('categories')
          .get();

      expect(docsA.docs.length, 14);
      expect(docsB.docs.length, 0);
    });

    test('Singleton instance getter and setter test', () {
      final original = CategoryRepository.instance;
      expect(original, isNotNull);

      final customRepo = CategoryRepository(firestore: fakeFirestore);
      CategoryRepository.instance = customRepo;
      expect(CategoryRepository.instance, same(customRepo));

      // Restore original
      CategoryRepository.instance = original;
    });
  });

  group('CategoryRepository Stream Tests (CAT-03)', () {
    late FakeFirebaseFirestore fakeFirestore;
    late CategoryRepository repository;
    const uid = 'test_user_stream_1';

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();
      repository = CategoryRepository(firestore: fakeFirestore);
      await repository.seedDefaultCategoriesIfEmpty(uid);
    });

    test('getCategoriesStream emits expense categories ordered by order ascending', () async {
      final stream = repository.getCategoriesStream(uid, isExpense: true);
      final categories = await stream.first;

      expect(categories.length, 8);
      for (int i = 0; i < categories.length; i++) {
        expect(categories[i].isExpense, isTrue);
        expect(categories[i].order, i + 1);
      }
      expect(categories.first.name, 'Makanan & Minuman');
      expect(categories.last.name, 'Lainnya');
      expect(categories.last.isLocked, isTrue);
    });

    test('getCategoriesStream emits income categories ordered by order ascending', () async {
      final stream = repository.getCategoriesStream(uid, isExpense: false);
      final categories = await stream.first;

      expect(categories.length, 6);
      for (int i = 0; i < categories.length; i++) {
        expect(categories[i].isExpense, isFalse);
        expect(categories[i].order, i + 1);
      }
      expect(categories.first.name, 'Gaji Pokok');
      expect(categories.last.name, 'Lainnya');
      expect(categories.last.isLocked, isTrue);
    });

    test('getCategoriesStream with isExpense: null emits all categories', () async {
      final stream = repository.getCategoriesStream(uid);
      final categories = await stream.first;

      expect(categories.length, 14);
    });

    test('watchCategories alias provides exact same stream as getCategoriesStream', () async {
      final watchExpenses = await repository.watchCategories(uid, isExpense: true).first;
      final getExpenses = await repository.getCategoriesStream(uid, isExpense: true).first;

      expect(watchExpenses.length, getExpenses.length);
      for (int i = 0; i < watchExpenses.length; i++) {
        expect(watchExpenses[i].id, getExpenses[i].id);
        expect(watchExpenses[i].name, getExpenses[i].name);
      }
    });

    test('getCategoriesStream emits empty list for empty or whitespace UID', () async {
      final emptyStream = repository.getCategoriesStream('');
      expect(await emptyStream.first, isEmpty);

      final whitespaceStream = repository.getCategoriesStream('   ');
      expect(await whitespaceStream.first, isEmpty);
    });

    test('getCategoriesStream reacts in realtime to Firestore updates', () async {
      final stream = repository.getCategoriesStream(uid, isExpense: true);

      // Collect emissions from stream
      final emissions = <List<CategoryItem>>[];
      final subscription = stream.listen(emissions.add);
      addTearDown(() => subscription.cancel());

      // Wait for initial emission
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(emissions.length, 1);
      expect(emissions.first.length, 8);

      // Add a custom category to Firestore
      await fakeFirestore
          .collection('users')
          .doc(uid)
          .collection('categories')
          .doc('cat-custom-1')
          .set({
        'id': 'cat-custom-1',
        'name': 'Kopi & Cafe',
        'iconCode': 58312,
        'color': 0xFF2563EB,
        'isExpense': true,
        'isCustom': true,
        'isLocked': false,
        'order': 9,
      });

      // Wait for second emission
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(emissions.length, 2);
      expect(emissions.last.length, 9);
      expect(emissions.last.any((c) => c.name == 'Kopi & Cafe'), isTrue);
    });

    test('getCategories one-shot query returns populated list', () async {
      final expenses = await repository.getCategories(uid, isExpense: true);
      expect(expenses.length, 8);

      final incomes = await repository.getCategories(uid, isExpense: false);
      expect(incomes.length, 6);

      final all = await repository.getCategories(uid);
      expect(all.length, 14);

      final empty = await repository.getCategories('');
      expect(empty, isEmpty);
    });
  });

  group('CategoryRepository CRUD Operations Tests (CAT-04, CAT-05, CAT-06)', () {
    late FakeFirebaseFirestore fakeFirestore;
    late CategoryRepository repository;
    const uid = 'test_user_crud_1';

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();
      repository = CategoryRepository(firestore: fakeFirestore);
      await repository.seedDefaultCategoriesIfEmpty(uid);
    });

    // --- CAT-04: addCategory ---
    test('addCategory creates custom category with specific ID and sets isCustom to true', () async {
      const newCategory = CategoryItem(
        id: 'cat-custom-kopi',
        name: 'Kopi & Nongkrong',
        icon: Icons.local_cafe_rounded,
        color: Color(0xFF16A34A),
        isExpense: true,
        order: 9,
      );

      final docId = await repository.addCategory(uid, newCategory);
      expect(docId, 'cat-custom-kopi');

      final saved = await repository.getCategoryById(uid, 'cat-custom-kopi');
      expect(saved, isNotNull);
      expect(saved!.name, 'Kopi & Nongkrong');
      expect(saved.icon.codePoint, Icons.local_cafe_rounded.codePoint);
      expect(saved.color.toARGB32(), const Color(0xFF16A34A).toARGB32());
      expect(saved.isExpense, isTrue);
      expect(saved.isCustom, isTrue);
      expect(saved.isLocked, isFalse);
      expect(saved.order, 9);
    });

    test('addCategory auto-generates doc ID when category id is empty', () async {
      const categoryNoId = CategoryItem(
        id: '',
        name: 'Gym & Fitness',
        icon: Icons.fitness_center_rounded,
        color: Color(0xFF2563EB),
        isExpense: true,
      );

      final generatedId = await repository.addCategory(uid, categoryNoId);
      expect(generatedId, isNotEmpty);

      final saved = await repository.getCategoryById(uid, generatedId);
      expect(saved, isNotNull);
      expect(saved!.name, 'Gym & Fitness');
      expect(saved.isCustom, isTrue);
    });

    test('addCategory throws ArgumentError if UID is empty', () async {
      const category = CategoryItem(
        id: 'cat-1',
        name: 'Test',
        icon: Icons.home_rounded,
        isExpense: true,
      );

      expect(
        () => repository.addCategory('', category),
        throwsA(isA<ArgumentError>()),
      );
    });

    // --- CAT-05: updateCategory ---
    test('updateCategory updates name, icon, and color of existing category', () async {
      // First add a category
      const initialCat = CategoryItem(
        id: 'cat-to-update',
        name: 'Hobi Lama',
        icon: Icons.sports_esports_rounded,
        color: Color(0xFF2563EB),
        isExpense: true,
        isCustom: true,
        order: 9,
      );
      await repository.addCategory(uid, initialCat);

      // Now update its properties
      final updatedCat = initialCat.copyWith(
        name: 'Gaming & Konsol',
        icon: Icons.devices_rounded,
        color: const Color(0xFFDC2626),
      );

      await repository.updateCategory(uid, updatedCat);

      final fetched = await repository.getCategoryById(uid, 'cat-to-update');
      expect(fetched, isNotNull);
      expect(fetched!.name, 'Gaming & Konsol');
      expect(fetched.icon.codePoint, Icons.devices_rounded.codePoint);
      expect(fetched.color.toARGB32(), const Color(0xFFDC2626).toARGB32());
      expect(fetched.order, 9);
      expect(fetched.isCustom, isTrue);
    });

    test('updateCategory throws ArgumentError if UID or categoryId is empty', () async {
      const validCat = CategoryItem(
        id: 'cat-1',
        name: 'Test',
        icon: Icons.home_rounded,
        isExpense: true,
      );
      const emptyIdCat = CategoryItem(
        id: '',
        name: 'Test',
        icon: Icons.home_rounded,
        isExpense: true,
      );

      expect(
        () => repository.updateCategory('', validCat),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => repository.updateCategory(uid, emptyIdCat),
        throwsA(isA<ArgumentError>()),
      );
    });

    // --- CAT-06: deleteCategory ---
    test('deleteCategory successfully deletes custom unlocked category', () async {
      const customCat = CategoryItem(
        id: 'cat-to-delete',
        name: 'Kategori Sementara',
        icon: Icons.category_rounded,
        isExpense: true,
      );
      await repository.addCategory(uid, customCat);

      // Verify exists
      expect(await repository.getCategoryById(uid, 'cat-to-delete'), isNotNull);

      // Delete
      await repository.deleteCategory(uid, 'cat-to-delete');

      // Verify no longer exists
      expect(await repository.getCategoryById(uid, 'cat-to-delete'), isNull);
    });

    test('deleteCategory throws Exception when trying to delete isLocked category (Lainnya)', () async {
      // Locked Expense 'exp-8'
      final lockedExpense = await repository.getCategoryById(uid, 'exp-8');
      expect(lockedExpense, isNotNull);
      expect(lockedExpense!.isLocked, isTrue);

      expect(
        () => repository.deleteCategory(uid, 'exp-8'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Kategori bawaan sistem tidak dapat dihapus'),
          ),
        ),
      );

      // Locked Income 'inc-6'
      final lockedIncome = await repository.getCategoryById(uid, 'inc-6');
      expect(lockedIncome, isNotNull);
      expect(lockedIncome!.isLocked, isTrue);

      expect(
        () => repository.deleteCategory(uid, 'inc-6'),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Kategori bawaan sistem tidak dapat dihapus'),
          ),
        ),
      );

      // Verify both locked categories still exist intact in Firestore
      expect(await repository.getCategoryById(uid, 'exp-8'), isNotNull);
      expect(await repository.getCategoryById(uid, 'inc-6'), isNotNull);
    });

    test('deleteCategory completes gracefully if category does not exist', () async {
      await expectLater(
        repository.deleteCategory(uid, 'non-existent-cat-id'),
        completes,
      );
    });

    test('deleteCategory throws ArgumentError if UID or categoryId is empty', () async {
      expect(
        () => repository.deleteCategory('', 'cat-1'),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => repository.deleteCategory(uid, ''),
        throwsA(isA<ArgumentError>()),
      );
    });
  });

  group('CategoryRepository Transaction Integrity Tests (CAT-07)', () {
    late FakeFirebaseFirestore fakeFirestore;
    late CategoryRepository repository;
    const uid = 'test_user_tx_1';

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();
      repository = CategoryRepository(firestore: fakeFirestore);
      await repository.seedDefaultCategoriesIfEmpty(uid);
    });

    test('countTransactionsByCategory returns 0 when no transactions exist', () async {
      final count = await repository.countTransactionsByCategory(uid, 'exp-1');
      expect(count, 0);
    });

    test('countTransactionsByCategory returns accurate count of matching transactions', () async {
      final txCollection = fakeFirestore.collection('users').doc(uid).collection('transactions');

      // Add 3 transactions for 'cat-hobi'
      await txCollection.add({'categoryId': 'cat-hobi', 'amount': 50000, 'title': 'Komik'});
      await txCollection.add({'categoryId': 'cat-hobi', 'amount': 120000, 'title': 'Game'});
      await txCollection.add({'categoryId': 'cat-hobi', 'amount': 30000, 'title': 'Poster'});

      // Add 2 transactions for another category ('exp-1')
      await txCollection.add({'categoryId': 'exp-1', 'amount': 25000, 'title': 'Makan Siang'});
      await txCollection.add({'categoryId': 'exp-1', 'amount': 15000, 'title': 'Kopi'});

      final hobiCount = await repository.countTransactionsByCategory(uid, 'cat-hobi');
      expect(hobiCount, 3);

      final exp1Count = await repository.countTransactionsByCategory(uid, 'exp-1');
      expect(exp1Count, 2);

      final otherCount = await repository.countTransactionsByCategory(uid, 'exp-2');
      expect(otherCount, 0);
    });

    test('countTransactionsByCategory returns 0 for empty or whitespace UID or categoryId', () async {
      expect(await repository.countTransactionsByCategory('', 'exp-1'), 0);
      expect(await repository.countTransactionsByCategory('   ', 'exp-1'), 0);
      expect(await repository.countTransactionsByCategory(uid, ''), 0);
      expect(await repository.countTransactionsByCategory(uid, '   '), 0);
    });

    test('migrateTransactionsCategory successfully reassigns transactions to fallback category', () async {
      final txCollection = fakeFirestore.collection('users').doc(uid).collection('transactions');

      // Add 3 transactions for old category
      await txCollection.add({'categoryId': 'cat-lama', 'amount': 10000, 'title': 'Item 1'});
      await txCollection.add({'categoryId': 'cat-lama', 'amount': 20000, 'title': 'Item 2'});
      await txCollection.add({'categoryId': 'cat-lama', 'amount': 30000, 'title': 'Item 3'});

      // Migrate from 'cat-lama' to 'exp-8' (Lainnya)
      final migratedCount = await repository.migrateTransactionsCategory(
        uid,
        fromCategoryId: 'cat-lama',
        toCategoryId: 'exp-8',
      );

      expect(migratedCount, 3);

      // Verify old category count is now 0
      final oldCount = await repository.countTransactionsByCategory(uid, 'cat-lama');
      expect(oldCount, 0);

      // Verify new category count is now 3
      final newCount = await repository.countTransactionsByCategory(uid, 'exp-8');
      expect(newCount, 3);
    });

    test('migrateTransactionsCategory returns 0 when no transactions match fromCategoryId', () async {
      final migrated = await repository.migrateTransactionsCategory(
        uid,
        fromCategoryId: 'non-existent-cat',
        toCategoryId: 'exp-8',
      );
      expect(migrated, 0);
    });

    test('migrateTransactionsCategory returns 0 for empty parameters', () async {
      expect(
        await repository.migrateTransactionsCategory('', fromCategoryId: 'a', toCategoryId: 'b'),
        0,
      );
      expect(
        await repository.migrateTransactionsCategory(uid, fromCategoryId: '', toCategoryId: 'b'),
        0,
      );
      expect(
        await repository.migrateTransactionsCategory(uid, fromCategoryId: 'a', toCategoryId: ''),
        0,
      );
    });
  });
}
