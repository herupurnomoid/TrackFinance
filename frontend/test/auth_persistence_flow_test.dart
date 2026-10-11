import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_finance/core/models/user_profile.dart';
import 'package:track_finance/core/services/auth_service_provider.dart';
import 'package:track_finance/core/services/mock_auth_service.dart';
import 'package:track_finance/features/auth/presentation/screens/login_screen.dart';
import 'package:track_finance/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:track_finance/features/splash/presentation/screens/splash_screen.dart';
import 'package:track_finance/main.dart';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:track_finance/features/transaction/data/transaction_repository.dart';

void main() {
  late MockAuthService mockAuthService;
  late FakeFirebaseFirestore fakeFirestore;

  final testUser = UserProfile(
    uid: 'persisted_user_123',
    email: 'persisted@trackfinance.app',
    displayName: 'Heru Purnomo',
    photoUrl: null,
    createdAt: DateTime(2026, 10, 1),
  );

  setUp(() {
    mockAuthService = MockAuthService();
    AuthServiceProvider.instance = mockAuthService;
    fakeFirestore = FakeFirebaseFirestore();
    TransactionRepository.instance = TransactionRepository(firestore: fakeFirestore);
  });

  tearDown(() {
    mockAuthService.dispose();
  });

  testWidgets('Splash Screen navigates to LoginScreen when no user session is saved',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(() => tester.view.resetPhysicalSize());

    mockAuthService.setCurrentUser(null);

    await tester.pumpWidget(const TrackFinanceApp(initialRoute: '/splash'));
    expect(find.byType(SplashScreen), findsOneWidget);

    // Majukan waktu melewati durasi splash
    await tester.pump(const Duration(milliseconds: 3000));
    await tester.pump(const Duration(milliseconds: 700));

    // Harus berada di LoginScreen
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Login dengan Google'), findsOneWidget);
  });

  testWidgets(
      'Splash Screen navigates directly to DashboardScreen when user is already logged in',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 5000);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(() => tester.view.resetPhysicalSize());

    mockAuthService.setCurrentUser(testUser);

    await tester.pumpWidget(const TrackFinanceApp(initialRoute: '/splash'));
    expect(find.byType(SplashScreen), findsOneWidget);

    // Majukan waktu melewati durasi splash
    await tester.pump(const Duration(milliseconds: 3000));
    await tester.pump(const Duration(milliseconds: 700));

    // Harus langsung berada di DashboardScreen tanpa meminta login lagi
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.textContaining('Heru Purnomo'), findsOneWidget);
    expect(find.byType(LoginScreen), findsNothing);
  });

  testWidgets('LoginScreen auto-redirects to Dashboard if active session exists',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 5000);
    tester.view.devicePixelRatio = 2.625;
    addTearDown(() => tester.view.resetPhysicalSize());

    mockAuthService.setCurrentUser(testUser);

    await tester.pumpWidget(const TrackFinanceApp(initialRoute: '/login'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Harus diarahkan otomatis ke DashboardScreen
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.textContaining('Heru Purnomo'), findsOneWidget);
  });
}
