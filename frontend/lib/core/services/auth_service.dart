import '../models/user_profile.dart';

/// Abstract AuthService defining the contract for Authentication.
/// In prototype mode, [MockAuthService] is used.
/// When integrating Firebase SDK, implement [FirebaseAuthService] using this interface.
abstract class AuthService {
  /// Stream to listen to auth state changes (logged in / logged out)
  Stream<UserProfile?> get authStateChanges;

  /// Current logged-in user profile, if any
  UserProfile? get currentUser;

  /// Trigger Google OAuth sign-in flow
  Future<UserProfile?> signInWithGoogle();

  /// Sign out current user
  Future<void> signOut();
}
