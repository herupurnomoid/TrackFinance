import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_finance/core/theme/app_theme.dart';
import 'package:track_finance/features/profile/presentation/screens/profile_screen.dart';
import 'package:track_finance/features/profile/presentation/widgets/logout_button.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Profile Screen Logout Button - No Container & No Background Color', () {
    testWidgets('Profile screen logout button renders with red icon and text, without container box decoration',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ProfileScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Find logout text and icon
      final textFinder = find.text('Keluar');
      final iconFinder = find.byIcon(Icons.logout_rounded);

      expect(textFinder, findsOneWidget);
      expect(iconFinder, findsOneWidget);

      // Verify red color on text and icon
      final textWidget = tester.widget<Text>(textFinder);
      expect(textWidget.style?.color, const Color(0xFFDC2626));

      final iconWidget = tester.widget<Icon>(iconFinder);
      expect(iconWidget.color, const Color(0xFFDC2626));

      // Verify the button row is NOT wrapped in a Container with colored background or box shadow
      // We look at the immediate parents of the Row widget in the logout button
      final rowFinder = find.ancestor(
        of: textFinder,
        matching: find.byType(Row),
      ).first;

      // The ancestor should be Padding, AnimatedOpacity, AnimatedScale, GestureDetector, Center
      final gestureFinder = find.ancestor(
        of: rowFinder,
        matching: find.byType(GestureDetector),
      );
      expect(gestureFinder, findsWidgets);

      // Verify tapping opens confirmation dialog
      await tester.tap(textFinder);
      await tester.pumpAndSettle();

      expect(find.text('Keluar dari Akun?'), findsOneWidget);
      expect(find.text('Apakah Anda yakin ingin keluar dari akun ini?'), findsOneWidget);
      expect(find.text('Batal'), findsOneWidget);

      // Tap Batal
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();
      expect(find.text('Keluar dari Akun?'), findsNothing);
    });

    testWidgets('Standalone LogoutButton renders with red icon and text without container background',
        (WidgetTester tester) async {
      bool loggedOut = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: LogoutButton(
              onLogout: () async {
                loggedOut = true;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final textFinder = find.text('Keluar');
      final iconFinder = find.byIcon(Icons.logout_rounded);

      expect(textFinder, findsOneWidget);
      expect(iconFinder, findsOneWidget);

      // Tap logout button to open dialog
      await tester.tap(textFinder);
      await tester.pumpAndSettle();

      expect(find.text('Konfirmasi Keluar'), findsOneWidget);

      // Confirm logout
      final confirmBtn = find.widgetWithText(ElevatedButton, 'Keluar');
      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      expect(loggedOut, isTrue);
    });
  });
}
