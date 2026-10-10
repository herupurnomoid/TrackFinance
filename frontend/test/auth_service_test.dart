import 'package:flutter_test/flutter_test.dart';
import 'package:track_finance/core/models/user_profile.dart';
import 'package:track_finance/core/services/auth_service_provider.dart';
import 'package:track_finance/core/services/mock_auth_service.dart';

void main() {
  group('Auth Unit & Service Tests', () {
    test('UserProfile model serialization and properties test', () {
      const profile = UserProfile(
        uid: 'user-abc-123',
        email: 'test@trackfinance.app',
        displayName: 'Test User',
        photoUrl: 'https://example.com/avatar.png',
      );

      expect(profile.uid, 'user-abc-123');
      expect(profile.email, 'test@trackfinance.app');
      expect(profile.displayName, 'Test User');
      expect(profile.photoUrl, 'https://example.com/avatar.png');

      final map = profile.toMap();
      expect(map['uid'], 'user-abc-123');
      expect(map['email'], 'test@trackfinance.app');

      final fromMap = UserProfile.fromMap(map);
      expect(fromMap.uid, profile.uid);
      expect(fromMap.email, profile.email);
      expect(fromMap.displayName, profile.displayName);
      expect(fromMap.photoUrl, profile.photoUrl);
      expect(fromMap.toString(), contains('user-abc-123'));
    });

    test('AuthServiceProvider provides an AuthService instance', () {
      expect(AuthServiceProvider.instance, isNotNull);
    });

    test('MockAuthService sign in and sign out reactive lifecycle test', () async {
      final mockAuth = MockAuthService();
      addTearDown(() => mockAuth.dispose());

      expect(mockAuth.currentUser, isNull);

      final List<UserProfile?> authStates = [];
      final subscription = mockAuth.authStateChanges.listen(authStates.add);
      addTearDown(() => subscription.cancel());

      final user = await mockAuth.signInWithGoogle();
      expect(user, isNotNull);
      expect(mockAuth.currentUser?.uid, 'mock-user-12345');
      expect(mockAuth.currentUser?.displayName, 'Heru Purnomo');

      await mockAuth.signOut();
      expect(mockAuth.currentUser, isNull);

      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(authStates.length, 2);
      expect(authStates[0]?.displayName, 'Heru Purnomo');
      expect(authStates[1], isNull);
    });
  });
}
