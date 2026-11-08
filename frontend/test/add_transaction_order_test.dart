import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_finance/core/theme/app_theme.dart';
import 'package:track_finance/features/transaction/presentation/screens/add_transaction_screen.dart';
import 'package:track_finance/features/transaction/presentation/widgets/add_transaction_skeleton.dart';
import 'package:track_finance/features/transaction/presentation/widgets/additional_details_section.dart';
import 'package:track_finance/features/transaction/presentation/widgets/amount_hero_card.dart';
import 'package:track_finance/features/transaction/presentation/widgets/category_selector_grid.dart';
import 'package:track_finance/features/transaction/presentation/widgets/transaction_type_switch.dart';

void main() {
  group('AddTransactionScreen Form Order Tests', () {
    testWidgets(
        'Verify vertical order of inputs: Switch -> Amount -> Date&Time -> Category -> Description/Note -> CTA Button',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: AddTransactionScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final switchFinder = find.byType(TransactionTypeSwitch);
      final amountFinder = find.byType(AmountHeroCard);
      final dateTimeFinder = find.byType(TransactionDateTimeSection);
      final categoryFinder = find.byType(CategorySelectorGrid);
      final noteFinder = find.byType(TransactionNoteInput);
      final ctaFinder = find.text('Simpan Transaksi');

      expect(switchFinder, findsOneWidget);
      expect(amountFinder, findsOneWidget);
      expect(dateTimeFinder, findsOneWidget);
      expect(categoryFinder, findsOneWidget);
      expect(noteFinder, findsOneWidget);
      expect(ctaFinder, findsOneWidget);

      final switchY = tester.getTopLeft(switchFinder).dy;
      final amountY = tester.getTopLeft(amountFinder).dy;
      final dateTimeY = tester.getTopLeft(dateTimeFinder).dy;
      final categoryY = tester.getTopLeft(categoryFinder).dy;
      final noteY = tester.getTopLeft(noteFinder).dy;
      final ctaY = tester.getTopLeft(ctaFinder).dy;

      // Pastikan urutan vertikalnya:
      // Switch < Amount < Date&Time < Category < Note/Description < CTA Button
      expect(switchY, lessThan(amountY),
          reason: 'Switch must be above Amount');
      expect(amountY, lessThan(dateTimeY),
          reason: 'Amount must be above Date&Time');
      expect(dateTimeY, lessThan(categoryY),
          reason: 'Date&Time must be above Category');
      expect(categoryY, lessThan(noteY),
          reason: 'Category must be above Note/Description (Description at bottom)');
      expect(noteY, lessThan(ctaY),
          reason: 'Note/Description must be above CTA Button');
    });

    testWidgets('Verify AddTransactionSkeleton renders properly',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: AddTransactionSkeleton(),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(AddTransactionSkeleton), findsOneWidget);
    });
  });
}
