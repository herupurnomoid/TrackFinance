import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_finance/core/models/user_profile.dart';
import 'package:track_finance/core/theme/app_theme.dart';
import 'package:track_finance/core/widgets/tactile_swipe_detector.dart';
import 'package:track_finance/features/category/data/category_repository.dart';
import 'package:track_finance/features/category/presentation/screens/category_screen.dart';
import 'package:track_finance/features/category/presentation/widgets/category_tab_bar.dart';
import 'package:track_finance/features/export/data/sync_export_repository.dart';
import 'package:track_finance/features/export/data/sync_import_repository.dart';
import 'package:track_finance/features/export/presentation/screens/export_data_screen.dart';
import 'package:track_finance/features/export/presentation/widgets/export_import_segmented_control.dart';
import 'package:track_finance/features/transaction/data/transaction_repository.dart';
import 'package:track_finance/features/transaction/presentation/screens/add_transaction_screen.dart';
import 'package:track_finance/features/transaction/presentation/widgets/transaction_type_switch.dart';

void main() {
  const testUser = UserProfile(
    uid: 'user_swipe_test',
    email: 'swipe@trackfinance.app',
    displayName: 'Swipe User',
  );

  group('TactileSwipeDetector Unit & Gesture Tests', () {
    testWidgets('triggers onSwipeLeft when dragged left beyond threshold', (tester) async {
      int leftCount = 0;
      int rightCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TactileSwipeDetector(
              onSwipeLeft: () => leftCount++,
              onSwipeRight: () => rightCount++,
              swipeThreshold: 35.0,
              child: const SizedBox(
                width: 300,
                height: 300,
                child: Text('Swipe Area'),
              ),
            ),
          ),
        ),
      );

      // Drag left by -80 pixels
      await tester.drag(find.text('Swipe Area'), const Offset(-80, 0));
      await tester.pumpAndSettle();

      expect(leftCount, 1);
      expect(rightCount, 0);
    });

    testWidgets('triggers onSwipeRight when dragged right beyond threshold', (tester) async {
      int leftCount = 0;
      int rightCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TactileSwipeDetector(
              onSwipeLeft: () => leftCount++,
              onSwipeRight: () => rightCount++,
              swipeThreshold: 35.0,
              child: const SizedBox(
                width: 300,
                height: 300,
                child: Text('Swipe Area'),
              ),
            ),
          ),
        ),
      );

      // Drag right by +80 pixels
      await tester.drag(find.text('Swipe Area'), const Offset(80, 0));
      await tester.pumpAndSettle();

      expect(leftCount, 0);
      expect(rightCount, 1);
    });

    testWidgets('does not trigger if drag is below threshold', (tester) async {
      int leftCount = 0;
      int rightCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TactileSwipeDetector(
              onSwipeLeft: () => leftCount++,
              onSwipeRight: () => rightCount++,
              swipeThreshold: 50.0,
              child: const SizedBox(
                width: 300,
                height: 300,
                child: Text('Swipe Area'),
              ),
            ),
          ),
        ),
      );

      // Drag left by only 10 pixels
      await tester.drag(find.text('Swipe Area'), const Offset(-10, 0));
      await tester.pumpAndSettle();

      expect(leftCount, 0);
      expect(rightCount, 0);
    });

    testWidgets('triggers on fast velocity fling even if drag distance is short', (tester) async {
      int leftCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TactileSwipeDetector(
              onSwipeLeft: () => leftCount++,
              velocityThreshold: 100.0,
              child: const SizedBox(
                width: 300,
                height: 300,
                child: Text('Fling Area'),
              ),
            ),
          ),
        ),
      );

      await tester.fling(find.text('Fling Area'), const Offset(-40, 0), 1000.0);
      await tester.pumpAndSettle();

      expect(leftCount, 1);
    });
  });

  group('TransactionTypeSwitch Swipe & Tap Tests', () {
    testWidgets('swipe left changes to Pemasukan and swipe right changes to Pengeluaran', (tester) async {
      bool isExpense = true;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return TransactionTypeSwitch(
                  isExpense: isExpense,
                  onChanged: (val) {
                    setState(() => isExpense = val);
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(isExpense, isTrue);

      // Swipe left on switch
      await tester.drag(find.byType(TransactionTypeSwitch), const Offset(-100, 0));
      await tester.pumpAndSettle();
      expect(isExpense, isFalse);

      // Swipe right on switch
      await tester.drag(find.byType(TransactionTypeSwitch), const Offset(100, 0));
      await tester.pumpAndSettle();
      expect(isExpense, isTrue);
    });
  });

  group('AddTransactionScreen Swipe Navigation Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late CategoryRepository categoryRepo;

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();
      TransactionRepository.instance = TransactionRepository(firestore: fakeFirestore);
      categoryRepo = CategoryRepository(firestore: fakeFirestore);
      CategoryRepository.instance = categoryRepo;
      await categoryRepo.seedDefaultCategoriesIfEmpty(testUser.uid);
    });

    testWidgets('swipe left toggles to Pemasukan and swipe right toggles back to Pengeluaran, preserving amount', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: AddTransactionScreen(user: testUser),
        ),
      );
      await tester.pumpAndSettle();

      // Verify initially Pengeluaran
      expect(find.text('Keluar'), findsOneWidget);
      expect(find.text('Kas Masuk'), findsNothing);

      // Enter nominal 150.000
      final amountField = find.byType(TextField).first;
      await tester.enterText(amountField, '150000');
      await tester.pump();
      expect(find.text('150.000'), findsOneWidget);

      // Swipe left on screen canvas
      await tester.drag(find.byType(SingleChildScrollView).first, const Offset(-120, 0));
      await tester.pumpAndSettle();

      // Now on Pemasukan
      expect(find.text('Kas Masuk'), findsOneWidget);
      expect(find.text('Keluar'), findsNothing);
      // Nominal is preserved!
      expect(find.text('150.000'), findsOneWidget);

      // Swipe right on screen canvas to go back to Pengeluaran
      await tester.drag(find.byType(SingleChildScrollView).first, const Offset(120, 0));
      await tester.pumpAndSettle();

      // Back to Pengeluaran
      expect(find.text('Keluar'), findsOneWidget);
      expect(find.text('Kas Masuk'), findsNothing);
      expect(find.text('150.000'), findsOneWidget);
    });

    testWidgets('full body accessibility: swipe on header bar toggles between Pengeluaran and Pemasukan', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: AddTransactionScreen(user: testUser),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Keluar'), findsOneWidget);

      // Swipe left on the top header title
      await tester.drag(find.text('Tambah Transaksi'), const Offset(-120, 0));
      await tester.pumpAndSettle();

      // Successfully toggled to Pemasukan from top header!
      expect(find.text('Kas Masuk'), findsOneWidget);
      expect(find.text('Keluar'), findsNothing);

      // Swipe right on the top header title
      await tester.drag(find.text('Tambah Transaksi'), const Offset(120, 0));
      await tester.pumpAndSettle();

      // Successfully toggled back to Pengeluaran!
      expect(find.text('Keluar'), findsOneWidget);
      expect(find.text('Kas Masuk'), findsNothing);
    });
  });

  group('CategoryTabBar Swipe Tests', () {
    testWidgets('swipe left changes to Pemasukan and swipe right changes to Pengeluaran', (tester) async {
      bool isExpense = true;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return CategoryTabBar(
                  isExpenseSelected: isExpense,
                  onTabChanged: (val) {
                    setState(() => isExpense = val);
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(isExpense, isTrue);

      // Swipe left on CategoryTabBar
      await tester.drag(find.byType(CategoryTabBar), const Offset(-100, 0));
      await tester.pumpAndSettle();
      expect(isExpense, isFalse);

      // Swipe right on CategoryTabBar
      await tester.drag(find.byType(CategoryTabBar), const Offset(100, 0));
      await tester.pumpAndSettle();
      expect(isExpense, isTrue);
    });
  });

  group('CategoryScreen Swipe Navigation Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late CategoryRepository categoryRepo;

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();
      categoryRepo = CategoryRepository(firestore: fakeFirestore);
      await categoryRepo.seedDefaultCategoriesIfEmpty(testUser.uid);
    });

    testWidgets('swipe left on CategoryScreen shows Income categories and swipe right shows Expense categories', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: CategoryScreen(
            user: testUser,
            repository: categoryRepo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially in Pengeluaran tab
      expect(find.text('Makanan & Minuman'), findsOneWidget);
      expect(find.text('Gaji Pokok'), findsNothing);

      // Swipe left on screen canvas
      await tester.drag(find.byType(SingleChildScrollView), const Offset(-150, 0));
      await tester.pumpAndSettle();

      // Now in Pemasukan tab
      expect(find.text('Gaji Pokok'), findsOneWidget);
      expect(find.text('Makanan & Minuman'), findsNothing);

      // Swipe right on screen canvas
      await tester.drag(find.byType(SingleChildScrollView), const Offset(150, 0));
      await tester.pumpAndSettle();

      // Back in Pengeluaran tab
      expect(find.text('Makanan & Minuman'), findsOneWidget);
      expect(find.text('Gaji Pokok'), findsNothing);
    });

    testWidgets('swipe down (pull to refresh) on CategoryScreen triggers RefreshIndicator and refreshes data', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: CategoryScreen(
            user: testUser,
            repository: categoryRepo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(RefreshIndicator), findsOneWidget);

      // Perform pull-to-refresh swipe down
      await tester.fling(find.byType(SingleChildScrollView), const Offset(0, 300), 1000);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 700));
      await tester.pumpAndSettle();

      // Screen is still fully rendered and intact
      expect(find.text('Makanan & Minuman'), findsOneWidget);
    });

    testWidgets('full body accessibility: swipe on category header toggles between Expense and Income', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: CategoryScreen(
            user: testUser,
            repository: categoryRepo,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Makanan & Minuman'), findsOneWidget);

      // Swipe left on the top header title
      await tester.drag(find.text('Kategori'), const Offset(-120, 0));
      await tester.pumpAndSettle();

      // Successfully toggled to Pemasukan from top header!
      expect(find.text('Gaji Pokok'), findsOneWidget);
      expect(find.text('Makanan & Minuman'), findsNothing);

      // Swipe right on the top header title
      await tester.drag(find.text('Kategori'), const Offset(120, 0));
      await tester.pumpAndSettle();

      // Successfully toggled back to Pengeluaran!
      expect(find.text('Makanan & Minuman'), findsOneWidget);
      expect(find.text('Gaji Pokok'), findsNothing);
    });
  });

  group('ExportImportSegmentedControl Swipe Tests', () {
    testWidgets('swipe left changes to Ekspor and swipe right changes to Impor', (tester) async {
      bool isImport = true;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return ExportImportSegmentedControl(
                  isImportSelected: isImport,
                  onSelectionChanged: (val) {
                    setState(() => isImport = val);
                  },
                );
              },
            ),
          ),
        ),
      );

      expect(isImport, isTrue);

      // Swipe left on ExportImportSegmentedControl
      await tester.drag(find.byType(ExportImportSegmentedControl), const Offset(-100, 0));
      await tester.pumpAndSettle();
      expect(isImport, isFalse);

      // Swipe right on ExportImportSegmentedControl
      await tester.drag(find.byType(ExportImportSegmentedControl), const Offset(100, 0));
      await tester.pumpAndSettle();
      expect(isImport, isTrue);
    });
  });

  group('ExportDataScreen Swipe Navigation Tests', () {
    testWidgets('swipe left on ExportDataScreen switches to Ekspor tab and swipe right switches to Impor tab', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      final fakeFirestore = FakeFirebaseFirestore();
      SyncExportRepository.instance = SyncExportRepository(firestore: fakeFirestore);
      SyncImportRepository.instance = SyncImportRepository(firestore: fakeFirestore);

      await tester.pumpWidget(
        const MaterialApp(
          home: ExportDataScreen(
            user: testUser,
            initialIsLoading: false,
            initialIsExport: false, // starts on Impor tab
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Initially on Impor tab: Unduh template is visible
      expect(find.text('Unduh template'), findsOneWidget);
      expect(find.text('Periode'), findsNothing);

      // Swipe left on screen canvas
      await tester.drag(find.byType(SingleChildScrollView), const Offset(-150, 0));
      await tester.pumpAndSettle();

      // Now on Ekspor tab: Periode filter is visible
      expect(find.text('Periode'), findsOneWidget);
      expect(find.text('Unduh template'), findsNothing);

      // Swipe right on screen canvas
      await tester.drag(find.byType(SingleChildScrollView), const Offset(150, 0));
      await tester.pumpAndSettle();

      // Back on Impor tab
      expect(find.text('Unduh template'), findsOneWidget);
      expect(find.text('Periode'), findsNothing);
    });

    testWidgets('full body accessibility: swipe on export header switches between Impor and Ekspor', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      final fakeFirestore = FakeFirebaseFirestore();
      SyncExportRepository.instance = SyncExportRepository(firestore: fakeFirestore);
      SyncImportRepository.instance = SyncImportRepository(firestore: fakeFirestore);

      await tester.pumpWidget(
        const MaterialApp(
          home: ExportDataScreen(
            user: testUser,
            initialIsLoading: false,
            initialIsExport: false, // starts on Impor tab
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Unduh template'), findsOneWidget);

      // Swipe left on the top header title
      await tester.drag(find.text('Ekspor & Impor'), const Offset(-120, 0));
      await tester.pumpAndSettle();

      // Successfully toggled to Ekspor from top header!
      expect(find.text('Periode'), findsOneWidget);
      expect(find.text('Unduh template'), findsNothing);

      // Swipe right on the top header title
      await tester.drag(find.text('Ekspor & Impor'), const Offset(120, 0));
      await tester.pumpAndSettle();

      // Successfully toggled back to Impor!
      expect(find.text('Unduh template'), findsOneWidget);
      expect(find.text('Periode'), findsNothing);
    });
  });
}
