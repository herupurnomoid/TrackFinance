import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_finance/core/models/user_profile.dart';
import 'package:track_finance/core/theme/app_theme.dart';
import 'package:track_finance/features/category/data/category_model.dart';
import 'package:track_finance/features/category/data/category_repository.dart';
import 'package:track_finance/features/category/presentation/screens/category_screen.dart';

void main() {
  group('Category Offline Persistence & Cache Tests (CAT-13)', () {
    late FakeFirebaseFirestore fakeFirestore;
    late CategoryRepository repository;
    const testUid = 'user_offline_persistence_13';

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();
      repository = CategoryRepository(firestore: fakeFirestore);
      await repository.seedDefaultCategoriesIfEmpty(testUid);
    });

    test('getCategories retrieves categories from cache via Source.cache', () async {
      final cachedCategories = await repository.getCategories(
        testUid,
        source: Source.cache,
      );

      expect(cachedCategories.length, equals(14));
      expect(cachedCategories.where((c) => c.isExpense).length, equals(8));
      expect(cachedCategories.where((c) => !c.isExpense).length, equals(6));
    });

    test('getCategoryById retrieves single document from cache via Source.cache', () async {
      final item = await repository.getCategoryById(
        testUid,
        'exp-1',
        source: Source.cache,
      );

      expect(item, isNotNull);
      expect(item!.id, equals('exp-1'));
      expect(item.name, equals('Makanan & Minuman'));
      expect(item.isExpense, isTrue);
    });

    test('addCategory creates category queryable in offline cache', () async {
      const offlineCategory = CategoryItem(
        id: 'cat-offline-01',
        name: 'Internet & Wifi',
        icon: Icons.wifi_rounded,
        color: Color(0xFF2563EB),
        isExpense: true,
        isCustom: true,
        order: 9,
      );

      final addedId = await repository.addCategory(testUid, offlineCategory);
      expect(addedId, equals('cat-offline-01'));

      final cachedList = await repository.getCategories(
        testUid,
        isExpense: true,
        source: Source.cache,
      );

      expect(cachedList.length, equals(9));
      expect(cachedList.any((c) => c.name == 'Internet & Wifi'), isTrue);
    });

    test('updateCategory mutates category in cache and persists changes', () async {
      final initialItem = await repository.getCategoryById(testUid, 'exp-2');
      expect(initialItem, isNotNull);

      final updatedItem = initialItem!.copyWith(name: 'Transport & Bensin');
      await repository.updateCategory(testUid, updatedItem);

      final fetchedFromCache = await repository.getCategoryById(
        testUid,
        'exp-2',
        source: Source.cache,
      );

      expect(fetchedFromCache, isNotNull);
      expect(fetchedFromCache!.name, equals('Transport & Bensin'));
    });

    test('deleteCategory removes item from cache while safeguarding isLocked items', () async {
      // 1. Adding custom category
      const customItem = CategoryItem(
        id: 'cat-to-delete-13',
        name: 'Langganan Game',
        icon: Icons.sports_esports_rounded,
        isExpense: true,
        isCustom: true,
        order: 10,
      );
      await repository.addCategory(testUid, customItem);

      // Verify exists in cache
      var cached = await repository.getCategoryById(testUid, 'cat-to-delete-13', source: Source.cache);
      expect(cached, isNotNull);

      // Delete custom category
      await repository.deleteCategory(testUid, 'cat-to-delete-13');

      // Verify removed from cache
      cached = await repository.getCategoryById(testUid, 'cat-to-delete-13', source: Source.cache);
      expect(cached, isNull);

      // 2. Attempting to delete locked category throws Exception
      expect(
        () => repository.deleteCategory(testUid, 'exp-8'),
        throwsA(isA<Exception>()),
      );
    });

    testWidgets('CategoryScreen operates smoothly in standalone offline mode without user login', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      // No user UID provided (Guest / disconnected offline mode)
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const CategoryScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Renders pre-seeded offline default categories
      expect(find.text('Kategori'), findsOneWidget);
      expect(find.textContaining('Pengeluaran (8)'), findsOneWidget);
      expect(find.textContaining('Pemasukan (6)'), findsOneWidget);
      expect(find.text('Makanan & Minuman'), findsOneWidget);

      // Tap on a non-locked category to open modal
      await tester.tap(find.text('Transportasi'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Kategori'), findsOneWidget);
      expect(find.text('Hapus'), findsOneWidget);

      // Dismiss modal
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      // Screen is interactive and intact
      expect(find.text('Makanan & Minuman'), findsOneWidget);
    });

    testWidgets('CategoryScreen realtime stream handles offline data mutations reactively', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      const userProfile = UserProfile(
        uid: testUid,
        email: 'offline@trackfinance.app',
        displayName: 'Offline Tester',
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: CategoryScreen(
            user: userProfile,
            repository: repository,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initially 8 expense items
      expect(find.textContaining('Pengeluaran (8)'), findsOneWidget);

      // Perform add while offline
      await repository.addCategory(
        testUid,
        const CategoryItem(
          id: 'cat-offline-fast',
          name: 'Kopi Susu Harian',
          icon: Icons.local_cafe_rounded,
          color: Color(0xFFEA580C),
          isExpense: true,
          isCustom: true,
          order: 9,
        ),
      );

      await tester.pumpAndSettle();

      // Stream immediately reflects offline mutation
      expect(find.textContaining('Pengeluaran (9)'), findsOneWidget);
      expect(find.text('Kopi Susu Harian'), findsOneWidget);
    });
  });
}
