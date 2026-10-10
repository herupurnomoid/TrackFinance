import 'auth_service.dart';
import 'mock_auth_service.dart';

/// Single access point for AuthService.
/// When switching to Firebase SDK:
/// Replace [MockAuthService()] with [FirebaseAuthService()].
class AuthServiceProvider {
  AuthServiceProvider._();

  static final AuthService instance = MockAuthService();
}
