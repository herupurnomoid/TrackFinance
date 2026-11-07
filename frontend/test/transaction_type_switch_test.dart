import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_finance/core/theme/app_theme.dart';
import 'package:track_finance/features/transaction/presentation/widgets/transaction_type_switch.dart';

void main() {
  group('TransactionTypeSwitch Tactile Styling & Animation Tests', () {
    testWidgets('displays tactile styling matching export/import and category switcher', (tester) async {
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

      // Verify track container styling (rounded 999, color #DAE2FD, height 48)
      final outerContainerFinder = find.byType(Container).first;
      final outerContainer = tester.widget<Container>(outerContainerFinder);
      final outerDec = outerContainer.decoration as BoxDecoration;
      expect(outerDec.color, const Color(0xFFDAE2FD));
      expect(outerDec.borderRadius, BorderRadius.circular(999));
      expect(outerContainer.constraints?.maxHeight, 48);

      // Verify AnimatedAlign for active sliding pill (Pengeluaran = left)
      final alignFinder = find.byType(AnimatedAlign);
      expect(alignFinder, findsOneWidget);
      final alignWidget = tester.widget<AnimatedAlign>(alignFinder);
      expect(alignWidget.alignment, Alignment.centerLeft);
      expect(alignWidget.duration, const Duration(milliseconds: 250));
      expect(alignWidget.curve, Curves.easeOutCubic);

      // Verify active pill decoration
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
      await tester.pump();
      expect(isExpense, false);

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
  });
}
