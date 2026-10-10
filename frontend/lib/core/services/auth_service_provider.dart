import 'auth_service.dart';
import 'firebase_auth_service.dart';

/// Single access point for AuthService.
class AuthServiceProvider {
  AuthServiceProvider._();

  static AuthService instance = FirebaseAuthService();
}
