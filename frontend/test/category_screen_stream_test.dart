import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_finance/core/models/user_profile.dart';
import 'package:track_finance/core/theme/app_theme.dart';
import 'package:track_finance/features/category/data/category_model.dart';
import 'package:track_finance/features/category/data/category_repository.dart';
import 'package:track_finance/features/category/presentation/screens/category_screen.dart';

void main() {
  group('CategoryScreen Reactive Stream Integration Tests (CAT-08)', () {
    late FakeFirebaseFirestore fakeFirestore;
    late CategoryRepository repository;
    const testUser = UserProfile(
      uid: 'user_stream_test_88',
      email: 'user88@trackfinance.app',
      displayName: 'Stream Tester',
    );

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();
      repository = CategoryRepository(firestore: fakeFirestore);
      await repository.seedDefaultCategoriesIfEmpty(testUser.uid);
    });

    testWidgets('CategoryScreen renders realtime data from CategoryRepository stream', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

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

      // Verify header and instruction
      expect(find.text('Kategori'), findsOneWidget);
      expect(find.text('Ketuk kategori untuk mengubah atau menghapus'), findsOneWidget);

      // Verify streamed expense count in tab
      expect(find.textContaining('Pengeluaran (8)'), findsOneWidget);
      expect(find.textContaining('Pemasukan (6)'), findsOneWidget);

      // Verify streamed default expense items
      expect(find.text('Makanan & Minuman'), findsOneWidget);
      expect(find.text('Transportasi'), findsOneWidget);
      expect(find.text('Belanja Harian'), findsOneWidget);
      expect(find.text('Lainnya'), findsOneWidget);

      // Dynamically add a custom category to Firestore while screen is active
      await repository.addCategory(
        testUser.uid,
        const CategoryItem(
          id: 'cat-stream-extra',
          name: 'Streaming Game',
          icon: Icons.sports_esports_rounded,
          color: Color(0xFF2563EB),
          isExpense: true,
          isCustom: true,
          order: 9,
        ),
      );

      // Pump to process Firestore stream event
      await tester.pumpAndSettle();

      // Verify screen instantly updated in realtime without manual reload
      expect(find.textContaining('Pengeluaran (9)'), findsOneWidget);
      expect(find.text('Streaming Game'), findsOneWidget);

      // Switch to income tab
      await tester.tap(find.textContaining('Pemasukan (6)'));
      await tester.pumpAndSettle();

      // Verify income categories
      expect(find.text('Gaji Pokok'), findsOneWidget);
      expect(find.text('Bonus'), findsOneWidget);
      expect(find.text('Investasi'), findsOneWidget);
      expect(find.text('Freelance'), findsOneWidget);
    });
  });
}
