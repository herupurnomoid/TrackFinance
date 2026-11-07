import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_finance/core/models/user_profile.dart';
import 'package:track_finance/core/services/auth_service_provider.dart';
import 'package:track_finance/core/services/firebase_auth_service.dart';
import 'package:track_finance/core/services/mock_auth_service.dart';
import 'package:track_finance/features/auth/presentation/screens/login_screen.dart';
import 'package:track_finance/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:track_finance/features/splash/presentation/screens/splash_screen.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:track_finance/features/transaction/data/transaction_repository.dart';
import 'package:track_finance/main.dart';

void main() {
  late MockAuthService mockAuthService;
  late FakeFirebaseFirestore fakeFirestore;

  final testUser = UserProfile(
    uid: 'test_splash_user',
    email: 'user@trackfinance.app',
    displayName: 'Track User',
    photoUrl: null,
    createdAt: DateTime(2026, 10, 1),
  );

  setUp(() {
    mockAuthService = MockAuthService();
    AuthServiceProvider.instance = mockAuthService;
    fakeFirestore = FakeFirebaseFirestore();
    TransactionRepository.instance =
        TransactionRepository(firestore: fakeFirestore);
  });

  tearDown(() {
    mockAuthService.dispose();
    AuthServiceProvider.instance = FirebaseAuthService();
  });

  test('SplashScreen has default duration of 1400ms (halved from 2800ms)', () {
    const splash = SplashScreen();
    expect(splash.duration, const Duration(milliseconds: 1400));
  });

  testWidgets(
      'SplashScreen stays visible before 1400ms and navigates to LoginScreen after 1400ms',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(() => tester.view.resetPhysicalSize());

    mockAuthService.setCurrentUser(null);

    await tester.pumpWidget(const TrackFinanceApp(initialRoute: '/splash'));
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('Track'), findsOneWidget);
    expect(find.text('Finance'), findsOneWidget);

    // Before 1400ms (at 1000ms), still on SplashScreen
    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);

    // Reach 1400ms + route transition duration
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.byType(SplashScreen), findsNothing);
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('SplashScreen navigates to DashboardScreen after 1400ms when user logged in',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(() => tester.view.resetPhysicalSize());

    mockAuthService.setCurrentUser(testUser);

    await tester.pumpWidget(const TrackFinanceApp(initialRoute: '/splash'));
    expect(find.byType(SplashScreen), findsOneWidget);

    // Advance past 1400ms duration + transition
    await tester.pump(const Duration(milliseconds: 1400));
    await tester.pump(const Duration(milliseconds: 700));

    expect(find.byType(SplashScreen), findsNothing);
    expect(find.byType(DashboardScreen), findsOneWidget);
  });
}
