# TrackFinance

Aplikasi pencatatan keuangan pribadi dengan arsitektur Monorepo yang memisahkan aplikasi mobile (**Frontend**) dan layanan server (**Backend**).

## 📁 Struktur Monorepo

```
TrackFinance/
├── docs/                    # Dokumentasi Teknis Backend Firebase & Task Breakdown
├── frontend/                # Aplikasi Mobile Flutter (Android, iOS, Web, macOS, Windows, Linux)
│   ├── lib/
│   │   ├── core/            # Theme, widget animations, constants, models
│   │   └── features/        # Auth, Dashboard, Category, Transaction, Export, Report, Profile, Splash
│   ├── test/                # Automated widget tests (31/31 tests passing)
│   ├── android/             # Konfigurasi native Android
│   ├── ios/                 # Konfigurasi native iOS
│   ├── pubspec.yaml         # Dependencies & assets Flutter
│   └── ...
└── backend/                 # Direktori Backend Service / API (dipersiapkan untuk backend)
    ├── .gitkeep
    └── README.md
```

> 📖 **Dokumentasi Backend Firebase**: Panduan lengkap setup Firebase SDK, Google OAuth, skema Firestore, dan task breakdown fitur Autentikasi tersedia di direktori [`docs/auth/`](docs/auth/README.md).

## 🚀 Menjalankan Frontend Mobile

Untuk menjalankan aplikasi mobile:
```bash
cd frontend
flutter pub get
flutter run
```

## 📱 Fitur Saat Ini (Prototype Phase)
- **Halaman Login OAuth Google**: Presisi sesuai referensi desain UI (Claymorphism 3D Icon, Plus Jakarta Sans, Authentic Google Button, dan Security Badge).
- **Halaman Clay Dashboard**:
  - **Top App Bar & Greeting**: Back button, judul "Clay Dashboard", profil avatar, greeting "Selamat Pagi, Alex Pratama" dengan tombol profil tactile clay.
  - **Ringkasan Arus Kas (Bulan Ini)**: Dual card Pemasukan (Rp 9.800.000) dan Pengeluaran (Rp 4.250.000) dengan badge tactile "Bulan Ini".
  - **Quick Stats (2 Kolom)**: Kartu "Pengeluaran Terbanyak" (Makanan & Minuman) dan "Kesehatan Finansial" (Sangat Sehat, Skor 85/100).
  - **Bar Chart Arus Kas**: Grafik visual perbandingan Masuk & Keluar per tanggal (18, 20, 22, 24) lengkap dengan legend dan skala sumbu Y.
  - **Menu Grid (2x2)**: Kategori, Laporan, Tanya AI (dengan indikator titik cyan), dan Data Sync.
  - **Transaksi Terakhir**: List riwayat transaksi terkini (Supermarket, Gaji Bulanan, Langganan Internet) dan tombol "Lihat Semua".
  - **Interactive Tactile FAB (+)**: Tombol tambah transaksi dengan micro-animasi rotasi 45° yang memunculkan pop-up opsi "Pemasukan" dan "Pengeluaran".
- **Halaman Manajemen Kategori (Atur Kategori & Alokasi)**:
  - **Header & Intro Card**: Judul "Atur Kategori & Alokasi", kartu "Alokasi & Kategori" lengkap dengan deskripsi dan ikon diagram lingkaran (*pie chart*).
  - **Segmented Tab Pill**: Toggle dinamis antara kategori **Pengeluaran** (9 kategori bawaan: Makanan, Transportasi, Belanja, Tagihan, Hiburan, Kesehatan, Pendidikan, Investasi, Keluarga) dan **Pemasukan** (6 kategori bawaan: Gaji Utama, Bonus, Investasi, Penjualan, Hadiah, Freelance).
  - **Grid 3 Kolom Kategori**: Kartu squircle berdesain clay dengan ikon pod melingkar dan efek sentuh tactile scale.
  - **Modal Tambah Kategori Baru**: Bottom sheet interaktif untuk menambah kategori baru dengan pilihan tipe (Pengeluaran/Pemasukan), input nama kategori, grid pemilihan 12+ ikon, dan notifikasi konfirmasi simpan (*toast pill*).
- **Halaman Profil Akun (Clay Profile)**:
  - **Top Status Pill**: Indikator status mikro dengan efek dot cyan berdenyut di bagian tengah atas.
  - **Clay Avatar Sphere**: Lingkaran profil 3D dengan gradien cyan berlapis, foto avatar keramik 3D yang ramah, dan pin lencana terverifikasi (*check circle*).
  - **Informasi Akun**: Kartu informasi *Nama Lengkap* (dengan lencana verifikasi) dan *Email Terdaftar* (dengan status pill aktif).
  - **Tombol Keluar dari Akun (Logout)**: Tombol pil warna koral/pastel merah dengan dialog konfirmasi aman dan transisi kembali ke halaman Login.
- **Tactile Micro-Interactions**: Animasi scale saat disentuh, bayangan claymorphic berlapis, dan loading state.

## 🏗️ Struktur Proyek (Clean & Scalable Architecture)

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart         # Palet warna desain (Cyan/Teal, Surface, Clay shadows)
│   │   └── app_text_styles.dart    # Tipografi Plus Jakarta Sans
│   ├── models/
│   │   └── user_profile.dart       # Entitas User (uid, email, displayName, photoUrl)
│   ├── services/
│   │   ├── auth_service.dart       # Abstract interface untuk Autentikasi
│   │   ├── mock_auth_service.dart  # Implementasi data dummy untuk fase prototype
│   │   └── auth_service_provider.dart # Central service provider (1-line switch ke Firebase)
│   └── theme/
│       └── app_theme.dart          # Konfigurasi ThemeData Material 3
├── features/
│   ├── auth/
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── login_screen.dart # Halaman OAuth Login
│   │       └── widgets/
│   │           ├── clay_app_icon.dart      # 3D Claymorphic Wallet Vault Icon
│   │           ├── google_logo.dart        # SVG 4-color Google Icon
│   │           ├── google_sign_in_button.dart # Tactile Google Pill Button
│   │           └── security_badge.dart     # Badge Aman & Terenkripsi
│   └── home/
│       └── presentation/
│           └── screens/
│               └── home_screen.dart        # Halaman demonstrasi pasca-login
└── main.dart
```

## 🚀 Cara Menjalankan

```bash
# Menjalankan di Chrome (Web)
flutter run -d chrome

# Menjalankan di macOS Desktop
flutter run -d macos

# Atau jalankan di emulator Android / iOS simulator
```

## 🔌 Kesiapan Integrasi Firebase SDK
Struktur proyek telah dirancang menggunakan pola **Dependency Inversion** melalui `AuthService`.
Ketika siap menyambungkan Firebase:
1. Pasang package `firebase_core`, `firebase_auth`, dan `google_sign_in`.
2. Buat class `FirebaseAuthService implements AuthService`.
3. Cukup ubah 1 baris di `lib/core/services/auth_service_provider.dart` dari `MockAuthService()` menjadi `FirebaseAuthService()`. Seluruh halaman UI akan langsung berfungsi dengan akun Google Firebase sungguhan tanpa perlu mengubah kode UI!