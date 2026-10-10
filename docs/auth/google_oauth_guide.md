# 🔑 Panduan Setup Google OAuth & Firebase Authentication

Dokumen ini memandu langkah-langkah teknis pengesetan autentikasi **Google Sign-In** menggunakan **Firebase SDK** pada aplikasi TrackFinance.

---

## 🎯 Luaran Teknis
- Pengguna dapat masuk menggunakan akun Google asli di platform **Android**, **iOS**, dan **Web**.
- Menggantikan `MockAuthService` dengan `FirebaseAuthService` secara mulus tanpa mengubah kode UI.
- Saat pertama kali login, data profil pengguna otomatis tersinkronisasi ke Cloud Firestore di koleksi `users/{uid}` (*upsert user profile*).

---

## 📋 Langkah 1: Ekstraksi SHA-1 & SHA-256 (Android)

Firebase Auth untuk Google Sign-In di Android mewajibkan sertifikat SHA-1.

Jalankan perintah ini di terminal macOS untuk keystore debug lokal:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
# Atau menggunakan path JDK Android Studio:
"/Applications/Android Studio.app/Contents/jbr/Contents/Home/bin/keytool" -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

#### 📌 Hasil Ekstraksi Mesin Pengembang (Debug Keystore):
- **SHA-1**:
  ```text
  F5:7A:B9:25:37:C4:83:DE:14:46:F3:67:CB:BB:5B:0F:DE:8E:1B:28
  ```
- **SHA-256**:
  ```text
  9A:33:91:12:20:F7:C5:A1:9C:F1:26:A1:72:1C:02:AA:61:91:B5:1E:72:A1:58:C1:EA:52:54:89:E6:17:F0:CD
  ```

---

## ☁️ Langkah 2: Konfigurasi di Firebase Console

1. **Buat / Buka Proyek Firebase**:
   - Buka [Firebase Console](https://console.firebase.google.com/).
   - Proyek: **TrackFinance** (Project ID: `trackfinance-6ccfd`).
2. **Aktifkan Google Authentication**:
   - Masuk ke menu **Build** > **Authentication** > tab **Sign-in method**.
   - Aktifkan provider **Google**.
   - Isi nama aplikasi publik (*TrackFinance*) dan masukkan email dukungan proyek (*Support Email*).
   - Klik **Simpan**.
3. **Daftarkan Aplikasi Android**:
   - Package Name: `com.trackfinance.TrackFinance`
   - Masukkan fingerprint **SHA-1** dan **SHA-256** yang didapat pada tahap sebelumnya.
   - Unduh file `google-services.json` dan letakkan di:
     `frontend/android/app/google-services.json`
4. **Daftarkan Aplikasi iOS**:
   - Bundle ID: `com.trackfinance.trackFinance`
   - Unduh file `GoogleService-Info.plist` dan letakkan di:
     `frontend/ios/Runner/GoogleService-Info.plist` (pastikan ditambahkan ke project Runner via Xcode).

---

## 📦 Langkah 3: Penambahan Dependensi Flutter

Tambahkan package berikut ke file [frontend/pubspec.yaml](file:///Users/heru/Development/TrackFinance/frontend/pubspec.yaml):

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Firebase SDK
  firebase_core: ^3.12.1
  firebase_auth: ^5.5.1
  cloud_firestore: ^5.6.5
  google_sign_in: ^6.2.2
```

Jalankan:
```bash
cd frontend
flutter pub get
```

---

## ⚙️ Langkah 4: Konfigurasi Native Platform

### A. Android (Kotlin DSL / Modern Gradle)

1. Di file [frontend/android/settings.gradle.kts](file:///Users/heru/Development/TrackFinance/frontend/android/settings.gradle.kts), tambahkan plugin Google Services:
```kotlin
plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "9.0.1" apply false
    id("org.jetbrains.kotlin.android") version "2.3.20" apply false
    // Tambahkan Google Services plugin
    id("com.google.gms.google-services") version "4.4.2" apply false
}
```

2. Di file [frontend/android/app/build.gradle.kts](file:///Users/heru/Development/TrackFinance/frontend/android/app/build.gradle.kts), aktifkan plugin:
```kotlin
plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
    // Tambahkan baris ini
    id("com.google.gms.google-services")
}
```

### B. iOS (`Info.plist`)

Buka `frontend/ios/Runner/Info.plist` dan tambahkan `CFBundleURLTypes` dengan nilai `REVERSED_CLIENT_ID` yang tertera di dalam `GoogleService-Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
	<dict>
		<key>CFBundleTypeRole</key>
		<string>Editor</string>
		<key>CFBundleURLSchemes</key>
		<array>
			<!-- Ganti dengan REVERSED_CLIENT_ID dari GoogleService-Info.plist -->
			<string>com.googleusercontent.apps.1234567890-abcdef</string>
		</array>
	</dict>
</array>
```

---

## 💻 Langkah 5: Implementasi Kode Flutter

### 1. Inisialisasi Firebase di `main.dart`

```dart
// frontend/lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();

  runApp(const MyApp());
}
```

### 2. Implementasi `FirebaseAuthService`

Buat file baru di [frontend/lib/core/services/firebase_auth_service.dart](file:///Users/heru/Development/TrackFinance/frontend/lib/core/services/firebase_auth_service.dart):

```dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import 'auth_service.dart';

class FirebaseAuthService implements AuthService {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final FirebaseFirestore _firestore;

  FirebaseAuthService({
    FirebaseAuth? auth,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn(),
        _firestore = firestore ?? FirebaseFirestore.instance;

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
      // 1. Trigger alur Google Sign-In UI
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // Pengguna membatalkan dialog sign-in
        return null;
      }

      // 2. Dapatkan credential auth token
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 3. Masuk ke Firebase menggunakan credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser != null) {
        // 4. Sinkronisasi data profil pengguna ke Cloud Firestore
        await _syncUserProfileToFirestore(firebaseUser);
      }

      return _mapFirebaseUser(firebaseUser);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _syncUserProfileToFirestore(User user) async {
    final userRef = _firestore.collection('users').doc(user.uid);
    final userDoc = await userRef.get();

    final now = FieldValue.serverTimestamp();

    if (!userDoc.exists) {
      // Pengguna baru: simpan profil awal + waktu pembuatan
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
      // Pengguna lama: perbarui waktu login dan metadata terbaru
      await userRef.update({
        'email': user.email,
        'displayName': user.displayName,
        'photoUrl': user.photoURL,
        'lastLoginAt': now,
      });
    }
  }

  @override
  Future<void> signOut() async {
    await Future.wait([
      _googleSignIn.signOut(),
      _auth.signOut(),
    ]);
  }
}
```

### 3. Pengalihan Service di `auth_service_provider.dart`

Cukup ubah 1 baris di [frontend/lib/core/services/auth_service_provider.dart](file:///Users/heru/Development/TrackFinance/frontend/lib/core/services/auth_service_provider.dart):

```dart
import 'auth_service.dart';
import 'firebase_auth_service.dart';

class AuthServiceProvider {
  AuthServiceProvider._();

  // Ubah dari MockAuthService() menjadi FirebaseAuthService()
  static final AuthService instance = FirebaseAuthService();
}
```

---

## ⚠️ Penanganan Kesalahan Umum (Troubleshooting)

1. **Error: `PlatformException(sign_in_failed, com.google.android.gms.common.api.ApiException: 10, ...)`**:
   - **Penyebab**: Fingerprint SHA-1 belum ditambahkan di Firebase Console atau file `google-services.json` belum diperbarui.
   - **Solusi**: Tambahkan SHA-1 di Firebase Console, unduh ulang `google-services.json`, lalu jalankan `flutter clean` & `flutter run`.

2. **Error: `ApiException: 12500`**:
   - **Penyebab**: OAuth Consent Screen belum dikonfigurasi di Google Cloud Console, atau email dukungan belum dipilih.
   - **Solusi**: Pastikan Support Email terisi di Firebase Console > Project Settings > General.

3. **User Membatalkan Dialog Login**:
   - Alur akan mengembalikan `null` secara elegan tanpa menimbulkan error/crash pada aplikasi.
