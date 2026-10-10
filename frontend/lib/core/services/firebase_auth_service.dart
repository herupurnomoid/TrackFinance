import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_profile.dart';
import 'auth_service.dart';

/// Implementasi [AuthService] menggunakan Firebase Auth & Google Sign-In SDK.
/// Mendukung sinkronisasi profil pengguna ke Cloud Firestore (`users/{uid}`).
class FirebaseAuthService implements AuthService {
  final FirebaseAuth? _customAuth;
  final GoogleSignIn? _customGoogleSignIn;
  final FirebaseFirestore? _customFirestore;

  FirebaseAuthService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  })  : _customAuth = auth,
        _customGoogleSignIn = googleSignIn,
        _customFirestore = firestore;

  FirebaseAuth get _auth => _customAuth ?? FirebaseAuth.instance;
  GoogleSignIn get _googleSignIn => _customGoogleSignIn ?? GoogleSignIn();
  FirebaseFirestore get _firestore => _customFirestore ?? FirebaseFirestore.instance;

  UserProfile? _mapFirebaseUser(User? user) {
    if (user == null) return null;
    return UserProfile(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
    );
  }

  @override
  Stream<UserProfile?> get authStateChanges {
    return _auth.authStateChanges().map(_mapFirebaseUser);
  }

  @override
  UserProfile? get currentUser => _mapFirebaseUser(_auth.currentUser);

  @override
  Future<UserProfile?> signInWithGoogle() async {
    try {
      // 1. Trigger dialog autentikasi Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // Pengguna membatalkan alur pemilihan akun
        return null;
      }

      // 2. Ambil token otentikasi Google
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 3. Masuk ke Firebase menggunakan credential OAuth
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // 4. Sinkronisasi dokumen profil ke Cloud Firestore (users/{uid})
        await _syncUserProfileToFirestore(firebaseUser);
      }

      return _mapFirebaseUser(firebaseUser);
    } catch (e) {
      debugPrint('FirebaseAuthService signInWithGoogle error: $e');
      rethrow;
    }
  }

  /// Sinkronisasi / Upsert data profil pengguna ke Cloud Firestore.
  Future<void> _syncUserProfileToFirestore(User user) async {
    try {
      final userRef = _firestore.collection('users').doc(user.uid);
      final userDoc = await userRef.get();

      final now = FieldValue.serverTimestamp();

      if (!userDoc.exists) {
        // Pengguna baru: Simpan metadata awal profil & preferensi default
        await userRef.set({
          'uid': user.uid,
          'email': user.email,
          'displayName': user.displayName,
          'photoUrl': user.photoURL,
          'createdAt': now,
          'lastLoginAt': now,
          'currency': 'IDR',
          'financialHealthScore': 85,
        });
      } else {
        // Pengguna lama: Perbarui info profil terkini dan waktu login terakhir
        await userRef.update({
          'email': user.email,
          'displayName': user.displayName,
          'photoUrl': user.photoURL,
          'lastLoginAt': now,
        });
      }
    } catch (e) {
      // Catat peringatan agar kegagalan sync Firestore tidak membatalkan login Firebase Auth
      debugPrint('FirebaseAuthService _syncUserProfileToFirestore warning: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        _googleSignIn.signOut(),
        _auth.signOut(),
      ]);
    } catch (e) {
      debugPrint('FirebaseAuthService signOut warning: $e');
      // Pastikan auth lokal tetap sign out meskipun GoogleSignIn sign out gagal/offline
      await _auth.signOut();
    }
  }
}
