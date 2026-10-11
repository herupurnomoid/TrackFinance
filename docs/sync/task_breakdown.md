# 📋 Task Breakdown: Fitur Ekspor & Impor Data (Sync)

Dokumen ini memuat rincian tugas terstruktur (*task breakdown*) untuk implementasi **Fitur Ekspor, Impor Data, dan Sinkronisasi Cloud** menggunakan **Firebase SDK** pada aplikasi TrackFinance.

---

## 🎯 Target Fitur
- Pengguna dapat mengekspor riwayat transaksi ke format **CSV**, **PDF**, dan **JSON** berdasarkan rentang tanggal yang dipilih (Semua, Bulan, Tahun, atau Rentang Kustom).
- Berkas yang diekspor dapat langsung dibagikan atau disimpan ke penyimpanan perangkat melalui *System Share Sheet*.
- Pengguna dapat mengimpor catatan transaksi dari berkas CSV lokal via *File Picker*.
- Sistem memvalidasi setiap baris berkas CSV secara cerdas (format tanggal, nominal, tipe, dan kategori), memisahkan baris valid, duplikat, dan baris bermasalah sebelum disimpan.
- Eksekusi penyimpanan data impor berjalan secara atomik menggunakan *Chunked Batch Writes* (maksimal 500 dokumen per batch) dengan pembaruan otomatis pada ringkasan bulanan dan saldo akun.
- Feedback antarmuka interaktif: pratinjau data, modal rincian baris error, dan dialog konfirmasi sukses.

---

## 📝 Tabel Rincian Tugas (Checklist)

| ID Task | Nama Tugas | Detail Pekerjaan Teknis | Estimasi | Prioritas | Status |
| :--- | :--- | :--- | :---: | :---: | :---: |
| **SYNC-01** | **Pasang Dependensi Flutter** | Tambahkan package `csv`, `share_plus`, `path_provider`, `file_picker`, dan `pdf` pada `frontend/pubspec.yaml`. | 15 menit | **P0** | [x] Selesai |
| **SYNC-02** | **Generator Berkas CSV** | Buat service `ExportCsvService` untuk mengonversi kumpulan `TransactionModel` menjadi teks CSV bertaraf RFC 4180 lengkap dengan baris header standar. | 35 menit | **P0** | [x] Selesai |
| **SYNC-03** | **Generator Berkas PDF** | Buat service `ExportPdfService` untuk menghasilkan dokumen laporan PDF resmi TrackFinance dengan header visual, ringkasan arus kas, dan tabel transaksi. | 45 menit | **P0** | [x] Selesai |
| **SYNC-04** | **Integrasi Share Sheet & Storage** | Buat utility penyimpanan berkas sementara ke direktori cache lokal (`path_provider`) dan pemicu dialog bagikan sistem (`share_plus`). | 25 menit | **P0** | [x] Selesai |
| **SYNC-05** | **Kueri Transaksi per Rentang** | Implementasikan fungsi `getTransactionsByDateRange(uid, startDate, endDate)` pada repository untuk memasok data transaksi riil yang akan diekspor. | 30 menit | **P0** | [x] Selesai |
| **SYNC-06** | **Integrasi Ekspor di UI** | Hubungkan tombol "Ekspor Berkas Sekarang" pada `ExportDataScreen` dengan pipeline ekspor riil lengkap dengan tactile loading state dan modal sukses. | 35 menit | **P0** | [x] Selesai |
| **SYNC-07** | **Estimasi Transaksi Dinamis** | Tampilkan jumlah transaksi riil dan estimasi nominal pada kartu ringkasan ekspor saat pengguna mengubah filter bulan/rentang tanggal. | 25 menit | **P1** | [x] Selesai |
| **SYNC-08** | **Integrasi File Picker CSV** | Hubungkan area sentuh `ImportDropZone` untuk membuka pemilih berkas perangkat (*system file picker*) dan membaca data berkas CSV. | 30 menit | **P0** | [x] Selesai |
| **SYNC-09** | **Parser & Validator Baris CSV** | Buat `CsvImportParser` untuk memvalidasi setiap baris data CSV (validasi tanggal `YYYY-MM-DD`, nominal positif, tipe `PENGELUARAN`/`PEMASUKAN`). | 45 menit | **P0** | [x] Selesai |
| **SYNC-10** | **Deteksi Duplikasi Transaksi** | Bandingkan data baris CSV dengan transaksi yang telah tercatat di Firestore untuk mendeteksi transaksi ganda (tanggal, nominal, dan kategori sama). | 35 menit | **P1** | [x] Selesai |
| **SYNC-11** | **Model Pratinjau & Error Rows** | Petakan hasil validasi ke objek `ImportFileModel`, daftar pratinjau `ImportTransactionPreview`, dan daftar baris bermasalah `ImportProblematicRow`. | 30 menit | **P0** | [x] Selesai |
| **SYNC-12** | **Integrasi Pratinjau & Modal Error** | Tampilkan pratinjau data pada tab Impor dan hubungkan tombol "Lihat Detail" dengan modal `ProblematicRowsModal`. | 25 menit | **P0** | [x] Selesai |
| **SYNC-13** | **Chunked Batch Ingestion Firestore** | Implementasikan eksekusi impor data massal menggunakan Firestore `WriteBatch` (chunking per 500 transaksi) yang otomatis memperbarui `monthly_summaries` dan saldo akun. | 50 menit | **P0** | [x] Selesai |
| **SYNC-14** | **Integrasi Eksekusi Impor di UI** | Hubungkan tombol "Impor Transaksi Sekarang" dengan pipeline batch commit, tampilkan dialog sukses, dan segarkan data transaksi di Dashboard. | 30 menit | **P0** | [x] Selesai |
| **SYNC-15** | **Pengujian Otomatis (Unit & Widget Tests)** | Buat unit test parser CSV, kalkulasi validasi error, ekspor PDF/CSV, serta pengujian widget `ExportDataScreen`. | 40 menit | **P1** | [x] Selesai |

---

## 🏆 Definition of Done (DoD)

Fitur Ekspor & Impor Data dinyatakan selesai (*Done*) jika memenuhi kriteria berikut:
1. **Ekspor Berfungsi Nyata**:
   - Menekan tombol ekspor menghasilkan berkas CSV atau PDF sungguhan dan memunculkan Share Sheet bawaan ponsel untuk disimpan atau dikirim.
   - Isi berkas ekspor memuat data transaksi riil dari Cloud Firestore sesuai rentang tanggal yang dipilih.
2. **Impor Akurat & Aman**:
   - Memilih berkas CSV memvalidasi isi data, mendeteksi baris salah/duplikat, dan menampilkan pratinjau yang transparan.
   - Menekan tombol impor menyimpan seluruh baris valid ke Cloud Firestore secara atomik tanpa inkonsistensi saldo.
3. **Penyelarasan Dashboard**:
   - Setelah proses impor selesai, total saldo di Dashboard langsung ter-update dengan nominal baru tanpa perlu me-restart aplikasi.
4. **Penanganan Error Elegan**:
   - Pengguna membatalkan file picker atau mengunggah berkas rusak tidak menyebabkan crash aplikasi.
5. **Kualitas Kode**:
   - Seluruh automated tests di `frontend/test/` berstatus passing 100%.
   - Analisis kode `flutter analyze` bersih tanpa pesan warning atau error.
