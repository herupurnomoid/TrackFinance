# 📋 Task Breakdown: Fitur Pencatatan Transaksi (Transactions)

Dokumen ini memuat rincian tugas terstruktur (*task breakdown*) untuk implementasi **Fitur Pencatatan Pemasukan dan Pengeluaran** menggunakan **Firebase SDK** pada aplikasi TrackFinance.

---

## 🎯 Target Fitur
- Pengguna dapat mencatat transaksi pemasukan dan pengeluaran secara cepat dan presisi.
- Setiap transaksi baru secara atomik memperbarui dokumen riwayat, ringkasan arus kas bulanan (`monthly_summaries`), dan saldo pengguna (`totalBalance`).
- Pengguna dapat mengedit transaksi yang telah dibuat (nominal, kategori, tanggal, catatan) dan perubahan langsung mengoreksi akumulasi saldo.
- Pengguna dapat menghapus transaksi dengan dialog konfirmasi aman.
- Dashboard aplikasi menampilkan data transaksi riil dan ringkasan bulan berjalan secara realtime (*stream listener*).
- Aplikasi memiliki ketahanan offline (*offline-first*) saat mencatat transaksi di area tanpa sinyal.

---

## 📝 Tabel Rincian Tugas (Checklist)

| ID Task | Nama Tugas | Detail Pekerjaan Teknis | Estimasi | Prioritas | Status |
| :--- | :--- | :--- | :---: | :---: | :---: |
| **TX-01** | **Model DTO Transaksi** | Buat model serialisasi `TransactionModel` yang mengonversi dokumen Firestore `users/{uid}/transactions/{id}` ke objek domain `DashboardTransaction` dan sebaliknya. | 30 menit | **P0** | [x] Selesai |
| **TX-02** | **Model DTO Ringkasan Bulanan** | Buat model `MonthlySummaryModel` untuk dokumen agregasi `users/{uid}/monthly_summaries/{monthKey}` yang mencatat total pemasukan, pengeluaran, net cashflow, dan rincian per kategori. | 30 menit | **P0** | [x] Selesai |
| **TX-03** | **Atomic Batch: Tambah Transaksi** | Implementasikan fungsi `addTransaction(String uid, TransactionModel tx)` pada `TransactionRepository` menggunakan `WriteBatch` yang serentak mengupdate transaksi, ringkasan bulanan, dan saldo user. | 45 menit | **P0** | [x] Selesai |
| **TX-04** | **Atomic Batch: Edit Transaksi** | Implementasikan fungsi `updateTransaction(String uid, TransactionModel oldTx, TransactionModel newTx)` yang menghitung selisih nominal dan mengoreksi `monthly_summaries` serta saldo user secara atomik. | 45 menit | **P0** | [x] Selesai |
| **TX-05** | **Atomic Batch: Hapus Transaksi** | Implementasikan fungsi `deleteTransaction(String uid, TransactionModel tx)` yang menghapus dokumen transaksi dan mengurangkan nilainya dari ringkasan bulanan dan saldo user. | 35 menit | **P0** | [x] Selesai |
| **TX-06** | **Stream: Transaksi Terakhir** | Buat query `watchRecentTransactions(String uid, {int limit = 5})` dengan pengurutan `date` DESC untuk disajikan pada kartu "Transaksi Terakhir" di Dashboard. | 25 menit | **P0** | [x] Selesai |
| **TX-07** | **Stream: Transaksi Bulanan** | Buat query `watchTransactionsByMonth(String uid, String monthKey)` untuk menampilkan seluruh riwayat transaksi pada bulan tertentu. | 25 menit | **P0** | [x] Selesai |
| **TX-08** | **Stream: Ringkasan Bulan Ini** | Buat listener realtime `watchMonthlySummary(String uid, String monthKey)` untuk menyuplai data kartu Pemasukan & Pengeluaran Bulan Ini di Dashboard. | 25 menit | **P0** | [x] Selesai |
| **TX-09** | **Integrasi Form Tambah Transaksi** | Hubungkan form `AddTransactionScreen` (Mode Tambah) dengan `TransactionRepository.addTransaction()` lengkap dengan tactile loading state dan floating snackbar feedback. | 40 menit | **P0** | [x] Selesai |
| **TX-10** | **Integrasi Form Edit Transaksi** | Hubungkan form `AddTransactionScreen` (Mode Edit) dengan `TransactionRepository.updateTransaction()` untuk menyimpan koreksi data transaksi. | 35 menit | **P0** | [x] Selesai |
| **TX-11** | **Integrasi Dialog Hapus Transaksi** | Hubungkan aksi konfirmasi `TransactionDeleteDialog` dengan `TransactionRepository.deleteTransaction()` dan navigasikan kembali ke layar sebelumnya. | 25 menit | **P0** | [x] Selesai |
| **TX-12** | **Integrasi Data Riil Dashboard** | Ganti data statis `DashboardScreen` dengan data realtime dari `watchMonthlySummary()` dan `watchRecentTransactions()`. | 45 menit | **P0** | [x] Selesai |
| **TX-13** | **Indexing Cloud Firestore** | Daftarkan composite index di Firebase Console: subkoleksi `transactions` dengan field `monthKey` (ASC) dan `date` (DESC). | 15 menit | **P1** | [x] Selesai |
| **TX-14** | **Firestore Security Rules** | Terapkan validasi di `firestore.rules`: nominal `amount > 0`, tipe hanya `income`/`expense`, `date` adalah timestamp, dan akses terbatas ke pemilik UID. | 25 menit | **P0** | [x] Selesai |
| **TX-15** | **Pengujian Unit & Widget Tests** | Buat automated test `transaction_repository_test.dart` untuk menguji kalkulasi batch, penambahan, pengeditan, dan penghapusan transaksi. | 40 menit | **P1** | [x] Selesai |

---

## 🏆 Definition of Done (DoD)

Fitur Pencatatan Transaksi dinyatakan selesai (*Done*) jika memenuhi kriteria berikut:
1. **Integritas Moneter Terjamin (ACID Guarantee)**:
   - Setiap transaksi yang berhasil disimpan langsung tercermin pada saldo akun dan kartu ringkasan arus kas tanpa selisih sepeser pun.
2. **Sinkronisasi Otomatis**:
   - Menambahkan transaksi baru dari FAB (+) langsung memunculkan transaksi tersebut di urutan teratas daftar "Transaksi Terakhir" di Dashboard seketika.
3. **Pengeditan & Penghapusan Bersih**:
   - Mengubah nilai atau menghapus transaksi otomatis mengoreksi akumulasi ringkasan bulanan dengan benar.
4. **Validasi Input Ketat**:
   - Nominal Rp 0 atau negatif ditolak oleh form dan diblokir oleh Firestore Security Rules di level database.
5. **Kualitas & Ketahanan Kode**:
   - Seluruh automated widget tests (`flutter test`) lulus 100% tanpa regresi.
   - Analisis kode `flutter analyze` bersih tanpa warning atau error.
