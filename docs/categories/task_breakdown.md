# 📋 Task Breakdown: Fitur Manajemen Kategori (Categories)

Dokumen ini memuat rincian tugas terstruktur (*task breakdown*) untuk implementasi **Fitur Manajemen Kategori & Alokasi** menggunakan **Firebase SDK** pada aplikasi TrackFinance.

---

## 🎯 Target Fitur
- Data kategori tersimpan di subkoleksi Cloud Firestore `users/{uid}/categories`.
- Pengguna baru otomatis mendapatkan 14 kategori default (8 pengeluaran, 6 pemasukan) via *atomic batch seeding*.
- Antarmuka `CategoryScreen` terhubung secara reaktif (*realtime stream*) dengan database Firestore.
- Pengguna dapat menambah, mengedit (nama, ikon, warna), dan menghapus kategori kustom secara langsung.
- Kategori bawaan bertanda `isLocked: true` ("Lainnya") tidak dapat dihapus demi integritas data.
- Kategori yang sedang digunakan oleh transaksi tidak dapat dihapus tanpa konfirmasi atau migrasi transaksi.

---

## 📝 Tabel Rincian Tugas (Checklist)

| ID Task | Nama Tugas | Detail Pekerjaan Teknis | Estimasi | Prioritas | Status |
| :--- | :--- | :--- | :---: | :---: | :---: |
| **CAT-01** | **Model DTO & Serialisasi** | Perbarui `CategoryItem` di `category_model.dart` agar mendukung serialisasi `fromFirestore` & `toFirestore` yang mencakup field `order`, `createdAt`, `isLocked`, dan `isCustom`. | 25 menit | **P0** | [ ] Belum |
| **CAT-02** | **Default Categories Seeder** | Buat fungsi `seedDefaultCategoriesIfEmpty(String uid)` menggunakan Firestore `WriteBatch` untuk mengisi 14 kategori default ketika subkoleksi masih kosong. | 30 menit | **P0** | [ ] Belum |
| **CAT-03** | **`CategoryRepository` Stream** | Buat repository service dengan metode `getCategoriesStream(String uid, {bool? isExpense})` yang me-listen query `snapshots()` secara realtime. | 35 menit | **P0** | [ ] Belum |
| **CAT-04** | **CRUD: Tambah Kategori** | Implementasikan fungsi `addCategory(String uid, CategoryItem category)` di repository untuk menyimpan dokumen baru ke Firestore. | 25 menit | **P0** | [ ] Belum |
| **CAT-05** | **CRUD: Edit Kategori** | Implementasikan fungsi `updateCategory(String uid, CategoryItem category)` di repository untuk memperbarui nama, ikon, dan warna kategori. | 25 menit | **P0** | [ ] Belum |
| **CAT-06** | **CRUD: Hapus Kategori** | Implementasikan fungsi `deleteCategory(String uid, String categoryId)` dengan validasi bahwa kategori tidak berstatus `isLocked`. | 25 menit | **P0** | [ ] Belum |
| **CAT-07** | **Validasi Integritas Transaksi** | Buat fungsi `countTransactionsByCategory(String uid, String categoryId)` untuk mendeteksi apakah kategori sedang digunakan oleh catatan transaksi sebelum dihapus. | 30 menit | **P1** | [ ] Belum |
| **CAT-08** | **Integrasi `CategoryScreen`** | Hubungkan `CategoryScreen` dengan stream dari `CategoryRepository` (menggantikan data array statis lokal dengan StreamBuilder/reactive state). | 45 menit | **P0** | [ ] Belum |
| **CAT-09** | **Integrasi `AddCategoryModal`** | Hubungkan tombol simpan pada modal tambah/edit kategori dengan `CategoryRepository.addCategory` dan `updateCategory` lengkap dengan indikator loading. | 35 menit | **P0** | [ ] Belum |
| **CAT-10** | **Integrasi `CategoryDeleteDialog`** | Hubungkan aksi konfirmasi dialog hapus dengan `CategoryRepository.deleteCategory` dan tampilkan feedback floating toast yang responsif. | 25 menit | **P0** | [ ] Belum |
| **CAT-11** | **Indexing Cloud Firestore** | Konfigurasikan index komposit pada subkoleksi `categories` jika diperlukan pengurutan ganda (`isExpense` ASC + `order` ASC / `createdAt` ASC). | 15 menit | **P1** | [ ] Belum |
| **CAT-12** | **Firestore Security Rules** | Terapkan aturan keamanan ketat di `firestore.rules` untuk memvalidasi panjang nama kategori (1–50 karakter), tipe boolean `isExpense`, dan pencegahan penghapusan jika `isLocked: true`. | 25 menit | **P0** | [ ] Belum |
| **CAT-13** | **Offline Persistence Testing** | Uji coba operasi tambah/edit/hapus kategori saat perangkat berada dalam mode offline / pesawat (*offline cache support*). | 20 menit | **P1** | [ ] Belum |
| **CAT-14** | **Unit & Widget Tests** | Buat file pengujian otomatis `category_repository_test.dart` dan perbarui widget tests di `frontend/test/` untuk memastikan seluruh skenario lulus tanpa regresi. | 30 menit | **P1** | [ ] Belum |

---

## 🏆 Definition of Done (DoD)

Fitur Manajemen Kategori dinyatakan selesai (*Done*) jika memenuhi kriteria berikut:
1. **Inisialisasi Otomatis**:
   - Pengguna yang baru pertama kali login langsung memiliki 8 kategori pengeluaran dan 6 kategori pemasukan di database tanpa halaman kosong (*empty state* tak berdasar).
2. **Reaktivitas Realtime**:
   - Menambah atau mengubah kategori langsung memperbarui tampilan grid kategori tanpa perlu melakukan refresh halaman manual.
3. **Proteksi Sistem**:
   - Kategori "Lainnya" (`isLocked: true`) tidak memunculkan opsi hapus dan tidak dapat dihapus oleh pengguna.
4. **Keamanan Firestore**:
   - Akses data dibatasi hanya untuk pemilik UID yang sah (`request.auth.uid == userId`).
5. **Kualitas Kode & Stabilitas**:
   - Seluruh automated tests di `frontend/test/` berhasil lulus (100% passing).
   - Analisis kode `flutter analyze` tidak memiliki pesan error atau warning.
