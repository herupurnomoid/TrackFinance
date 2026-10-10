# 📋 Task Breakdown: Fitur Autentikasi (Google OAuth)

Dokumen ini memuat rincian tugas terstruktur (*task breakdown*) untuk implementasi **Fitur Autentikasi Login Google OAuth** menggunakan **Firebase SDK** pada aplikasi TrackFinance.

---

## 🎯 Target Fitur
- Pengguna dapat masuk (*Sign-In*) dengan akun Google asli.
- Sesi pengguna (*session token*) disimpan aman dan bertahan saat aplikasi ditutup/dibuka kembali.
- Data profil pengguna otomatis terintegrasi ke dokumen Cloud Firestore `users/{uid}`.
- Pengguna dapat keluar (*Sign-Out*) secara aman dari halaman Profil.
- Zero-breaking change terhadap antarmuka UI yang sudah ada.

---

## 📝 Tabel Rincian Tugas (Checklist)

| ID Task | Nama Tugas | Detail Pekerjaan Teknis | Estimasi | Prioritas | Status |
| :--- | :--- | :--- | :---: | :---: | :---: |
| **AUTH-01** | **Ekstraksi SHA-1 & SHA-256** | Jalankan `keytool` pada mesin pengembang untuk mendapatkan fingerprint sertifikat keystore debug Android. | 15 menit | **P0** | [x] Selesai |
| **AUTH-02** | **Inisialisasi Proyek Firebase** | Buat proyek baru di [Firebase Console](https://console.firebase.google.com/) bernama `TrackFinance` (Project ID: `trackfinance-6ccfd`). | 10 menit | **P0** | [x] Selesai |
| **AUTH-03** | **Aktivasi Provider Google** | Di menu Authentication > Sign-in method, aktifkan **Google**, set nama aplikasi publik dan Support Email. | 5 menit | **P0** | [x] Selesai |
| **AUTH-04** | **Konfigurasi Native Android** | Daftarkan package `com.trackfinance.TrackFinance`, masukkan SHA-1 & SHA-256, download file `google-services.json` dan letakkan di `frontend/android/app/`. | 20 menit | **P0** | [x] Selesai |
| **AUTH-05** | **Konfigurasi Native iOS** | Daftarkan bundle ID `com.trackfinance.trackFinance`, pasang `GoogleService-Info.plist` di `frontend/ios/Runner/`, dan isi URL Schemes di `Info.plist`. | 25 menit | **P0** | [ ] Belum |
| **AUTH-06** | **Pasang Dependencies Flutter** | Tambahkan `firebase_core`, `firebase_auth`, `google_sign_in`, dan `cloud_firestore` pada `frontend/pubspec.yaml` lalu jalankan `flutter pub get`. | 10 menit | **P0** | [x] Selesai |
| **AUTH-07** | **Konfigurasi Gradle Android** | Tambahkan plugin `com.google.gms.google-services` di `settings.gradle.kts` dan apply di `app/build.gradle.kts`. | 15 menit | **P0** | [x] Selesai |
| **AUTH-08** | **Inisialisasi Firebase di `main.dart`** | Panggil `WidgetsFlutterBinding.ensureInitialized()` dan `await Firebase.initializeApp()` sebelum `runApp()`. | 10 menit | **P0** | [x] Selesai |
| **AUTH-09** | **Implementasi `FirebaseAuthService`** | Buat file `frontend/lib/core/services/firebase_auth_service.dart` yang mengimplementasikan interface `AuthService` (`signInWithGoogle`, `signOut`, `authStateChanges`, `currentUser`). | 45 menit | **P0** | [x] Selesai |
| **AUTH-10** | **Sinkronisasi User ke Firestore** | Implementasikan fungsi upsert profil `users/{uid}` yang menyimpan email, nama, foto profil, dan waktu login (`serverTimestamp`). | 30 menit | **P0** | [x] Selesai |
| **AUTH-11** | **Switch di `AuthServiceProvider`** | Ubah `MockAuthService()` menjadi `FirebaseAuthService()` di `frontend/lib/core/services/auth_service_provider.dart`. | 5 menit | **P0** | [x] Selesai |
| **AUTH-12** | **Error Handling & Loading State** | Tangani kondisi ketika pengguna membatalkan dialog sign-in (*user canceled*), ketiadaan koneksi internet, atau kegagalan token. | 25 menit | **P1** | [x] Selesai |
| **AUTH-13** | **Uji Coba Multi-Platform** | Validasi login Google di Android (Emulator/Device), iOS Simulator, dan Web. Pastikan data akun muncul di Dashboard. | 30 menit | **P1** | [x] Selesai |
| **AUTH-14** | **Verifikasi Alur Logout** | Pastikan tombol logout pada dialog konfirmasi di halaman Profil berhasil memanggil `signOut()` dan mengembalikan ke LoginScreen. | 15 menit | **P1** | [x] Selesai |
| **AUTH-15** | **Update Unit / Widget Tests** | Pastikan test suite (`flutter test`) tetap lolos dan tidak mengalami regresi. | 20 menit | **P2** | [x] Selesai |

---

## 🏆 Definition of Done (DoD)

Sebuah tugas pada fitur Autentikasi dinyatakan selesai (*Done*) jika memenuhi kriteria berikut:
1. **Fungsional**:
   - Menekan tombol "Lanjutkan dengan Google" memunculkan dialog pemilihan akun Google asli.
   - Setelah memilih akun, pengguna berhasil masuk dan diarahkan ke `DashboardScreen`.
   - Nama dan foto profil pengguna pada Dashboard sesuai dengan data akun Google yang dipilih.
2. **Database**:
   - Dokumen pengguna baru tercatat di Cloud Firestore pada `users/{uid}`.
3. **Session**:
   - Jika aplikasi ditutup dan dibuka kembali, pengguna tidak diminta login ulang (kecuali telah melakukan logout).
4. **Pembersihan Sesi**:
   - Melakukan logout di halaman profil membersihkan sesi kredensial Google dan Firebase Auth.
5. **Kualitas Kode**:
   - Tidak ada error lint (`flutter analyze` bersih).
   - Seluruh automated widget tests (`flutter test`) tetap berstatus passing.
