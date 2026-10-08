import 'dart:async';
import '../models/user_profile.dart';
import 'auth_service.dart';

/// Mock authentication service providing dummy data for the prototype stage.
class MockAuthService implements AuthService {
  final _authStateController = StreamController<UserProfile?>.broadcast();
  UserProfile? _currentUser;

  @override
  Stream<UserProfile?> get authStateChanges => _authStateController.stream;

  @override
  UserProfile? get currentUser => _currentUser;

  @override
  Future<UserProfile?> signInWithGoogle() async {
    // Simulate realistic network delay for OAuth authentication
    await Future.delayed(const Duration(milliseconds: 1200));

    // Dummy user profile
    _currentUser = const UserProfile(
      uid: 'mock-user-12345',
      displayName: 'Heru Purnomo',
      email: 'heru@trackfinance.app',
      photoUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
    );

    _authStateController.add(_currentUser);
    return _currentUser;
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 400));
    _currentUser = null;
    _authStateController.add(null);
  }

  void dispose() {
    _authStateController.close();
  }
}
