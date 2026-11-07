import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_finance/core/models/user_profile.dart';
import 'package:track_finance/core/theme/app_theme.dart';
import 'package:track_finance/features/category/data/category_repository.dart';
import 'package:track_finance/features/category/presentation/screens/category_screen.dart';
import 'package:track_finance/features/category/presentation/widgets/category_tab_bar.dart';

void main() {
  group('CategoryTabBar & Switcher Animation Unit & Widget Tests', () {
    testWidgets('CategoryTabBar displays tactile styling matching export/import switcher', (tester) async {
      bool isExpense = true;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return CategoryTabBar(
                  isExpenseSelected: isExpense,
                  expenseCount: 8,
                  incomeCount: 6,
                  onTabChanged: (val) {
                    setState(() => isExpense = val);
                  },
                );
              },
            ),
          ),
        ),
      );

      // Verify track container styling
      final outerContainerFinder = find.byType(Container).first;
      final outerContainer = tester.widget<Container>(outerContainerFinder);
      final outerDec = outerContainer.decoration as BoxDecoration;
      expect(outerDec.color, const Color(0xFFDAE2FD));
      expect(outerDec.borderRadius, BorderRadius.circular(999));
      expect(outerContainer.constraints?.maxHeight, 48);

      // Verify initial AnimatedAlign for active sliding pill (Pengeluaran = left)
      final alignFinder = find.byType(AnimatedAlign);
      expect(alignFinder, findsOneWidget);
      final alignWidget = tester.widget<AnimatedAlign>(alignFinder);
      expect(alignWidget.alignment, Alignment.centerLeft);
      expect(alignWidget.duration, const Duration(milliseconds: 250));
      expect(alignWidget.curve, Curves.easeOutCubic);

      // Verify pill decoration
      final pillContainer = tester.widget<Container>(find.descendant(
        of: alignFinder,
        matching: find.byType(Container),
      ));
      final pillDec = pillContainer.decoration as BoxDecoration;
      expect(pillDec.borderRadius, BorderRadius.circular(999));
      final gradient = pillDec.gradient as LinearGradient;
      expect(gradient.colors, [
        const Color(0xFF2563EB),
        const Color(0xFF004AC6),
      ]);

      // Tap Pemasukan tab to test sliding animation to right
      await tester.tap(find.text('Pemasukan'));
      await tester.pump(); // start animation
      expect(isExpense, false);

      // Settle animation
      await tester.pumpAndSettle();
      final updatedAlignWidget = tester.widget<AnimatedAlign>(alignFinder);
      expect(updatedAlignWidget.alignment, Alignment.centerRight);

      // Tap Pengeluaran tab to test sliding animation back to left
      await tester.tap(find.text('Pengeluaran'));
      await tester.pumpAndSettle();
      expect(isExpense, true);
      final finalAlignWidget = tester.widget<AnimatedAlign>(alignFinder);
      expect(finalAlignWidget.alignment, Alignment.centerLeft);
    });

    testWidgets('CategoryScreen integrates CategoryTabBar with smooth AnimatedSwitcher between Pengeluaran and Pemasukan', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      final fakeFirestore = FakeFirebaseFirestore();
      final repository = CategoryRepository(firestore: fakeFirestore);
      const testUser = UserProfile(
        uid: 'user_switcher_test_1',
        email: 'switcher@trackfinance.app',
        displayName: 'Switcher Tester',
      );
      await repository.seedDefaultCategoriesIfEmpty(testUser.uid);

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

      // CategoryTabBar should be present on screen
      expect(find.byType(CategoryTabBar), findsOneWidget);

      // AnimatedSwitcher should be present for smooth content transition
      expect(find.byType(AnimatedSwitcher), findsWidgets);

      // Initially in Pengeluaran tab
      expect(find.text('Makanan & Minuman'), findsOneWidget);
      expect(find.text('Gaji Pokok'), findsNothing);

      // Switch to Pemasukan tab
      await tester.tap(find.text('Pemasukan'));
      await tester.pumpAndSettle();

      // Income categories should now be visible
      expect(find.text('Gaji Pokok'), findsOneWidget);
      expect(find.text('Makanan & Minuman'), findsNothing);

      // Switch back to Pengeluaran tab
      await tester.tap(find.text('Pengeluaran'));
      await tester.pumpAndSettle();

      // Expense categories visible again
      expect(find.text('Makanan & Minuman'), findsOneWidget);
      expect(find.text('Gaji Pokok'), findsNothing);
    });
  });
}
