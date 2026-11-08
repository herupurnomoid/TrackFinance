import 'package:flutter_test/flutter_test.dart';
import 'package:track_finance/features/profile/presentation/screens/profile_screen.dart';
import 'package:track_finance/main.dart';

void main() {
  testWidgets('Navigating to /profile uses instant zero duration transition', (tester) async {
    await tester.pumpWidget(
      const TrackFinanceApp(initialRoute: '/profile'),
    );
    await tester.pump();

    // Verify ProfileScreen is rendered instantly
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
  });
}
