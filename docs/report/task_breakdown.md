# 📋 Task Breakdown: Fitur Laporan Keuangan (Reports)

Dokumen ini memuat rincian tugas terstruktur (*task breakdown*) untuk implementasi **Fitur Laporan Keuangan & Analisis Finansial** menggunakan **Firebase SDK** pada aplikasi TrackFinance.

---

## 🎯 Target Fitur
- Pengguna dapat melihat laporan analisis keuangan berdasarkan bulan dan tahun yang dipilih secara fleksibel.
- Seluruh grafik dan kartu (Kesehatan Finansial, Tren Harian, dan Struktur Donut Kategori) menampilkan data riil dari Cloud Firestore, menggantikan data statis/dummy.
- Kalkulasi skor kesehatan keuangan dan rasio tabungan dihitung secara dinamis dari selisih pemasukan dan pengeluaran.
- Pengguna dapat beralih antara analisis kategori **Pengeluaran** (*Keluar*) dan **Pemasukan** (*Masuk*).
- Tampilan status kosong (*Empty State*) ditampilkan dengan rapi jika bulan yang dipilih belum memiliki data transaksi.
- Performa muat halaman sangat cepat dengan memanfaatkan dokumen agregasi `monthly_summaries`.

---

## 📝 Tabel Rincian Tugas (Checklist)

| ID Task | Nama Tugas | Detail Pekerjaan Teknis | Estimasi | Prioritas | Status |
| :--- | :--- | :--- | :---: | :---: | :---: |
| **REP-01** | **Domain Model Analisis Laporan** | Buat model komprehensif `MonthlyReportData` yang memuat ringkasan moneter, daftar tren harian (`ReportDailyTrendItem`), daftar proporsi kategori (`ReportCategoryItem`), dan metadata kesehatan finansial. | 30 menit | **P0** | [x] Selesai |
| **REP-02** | **Engine Skor Kesehatan Finansial** | Implementasikan kalkulator metrik keuangan: rasio tabungan (`Savings Rate`), formula skor (0–100), label status (*Sehat*, *Waspada*, *Kritis*), dan saran cerdas dinamis. | 35 menit | **P0** | [x] Selesai |
| **REP-03** | **Generator Tren Harian** | Buat fungsi utility yang mengelompokkan riwayat transaksi bulanan berdasarkan tanggal (`dayStr: '01', '02', ...`) menjadi titik grafik batang pemasukan vs pengeluaran. | 35 menit | **P0** | [x] Selesai |
| **REP-04** | **Generator Proporsi Kategori** | Buat fungsi kalkulasi persentase kontribusi per kategori, pengurutan nominal terbesar, serta pemetaan warna dan ikon dari subkoleksi `categories`. | 30 menit | **P0** | [x] Selesai |
| **REP-05** | **Implementasi `ReportRepository`** | Buat service `ReportRepository` dengan metode `getMonthlyReport(String uid, String monthKey)` yang menggabungkan pembacaan `monthly_summaries` dan kueri transaksi bulanan. | 40 menit | **P0** | [x] Selesai |
| **REP-06** | **Realtime Stream Laporan** | Tambahkan metode stream `watchMonthlyReport(String uid, String monthKey)` untuk memperbarui laporan seketika jika ada transaksi baru yang dicatat di latar belakang. | 30 menit | **P0** | [x] Selesai |
| **REP-07** | **Penanganan Mode Bulan Kosong** | Pastikan status kosong (*Empty State*) terdeteksi secara otomatis jika `totalIncome == 0` dan `totalExpense == 0`, tanpa memicu error kalkulasi pembagian dengan nol. | 20 menit | **P0** | [x] Selesai |
| **REP-08** | **Integrasi `ReportMonthPickerModal`** | Hubungkan modal pemilihan bulan & tahun dengan state `ReportScreen`, sehingga memilih bulan baru langsung memicu pengambilan data laporan bulan tersebut. | 30 menit | **P0** | [x] Selesai |
| **REP-09** | **Integrasi `ReportHealthCard`** | Sambungkan kartu kesehatan finansial dengan skor riil, rasio tabungan, serta teks saran finansial hasil perhitungan `ReportRepository`. | 25 menit | **P0** | [x] Selesai |
| **REP-10** | **Integrasi `ReportTrendCard`** | Pasok daftar `ReportDailyTrendItem` riil ke kartu tren harian, lengkap dengan tooltip nominal dinamis dan penyesuaian skala sumbu Y. | 35 menit | **P0** | [x] Selesai |
| **REP-11** | **Integrasi `ReportStructureCard`** | Pasok daftar `ReportCategoryItem` riil ke diagram donat dan daftar rincian kategori sesuai tab yang aktif (Keluar atau Masuk). | 35 menit | **P0** | [x] Selesai |
| **REP-12** | **Toggle Tab Keluar & Masuk** | Pastikan tombol toggle segment (*Keluar* / *Masuk*) memperbarui diagram donat, kartu tren, dan total nominal dengan animasi halus. | 20 menit | **P0** | [x] Selesai |
| **REP-13** | **Optimasi Kueri & Offline Cache** | Pastikan kueri transaksi bulanan memanfaatkan index komposit (`monthKey` ASC + `date` ASC) dan dapat diakses saat perangkat offline. | 20 menit | **P1** | [x] Selesai |
| **REP-14** | **Pengujian Unit & Widget Tests** | Buat unit test `report_repository_test.dart` untuk menguji akurasi kalkulasi skor finansial, persentase kategori, dan pengelompokan harian. | 35 menit | **P1** | [x] Selesai |

---

## 🏆 Definition of Done (DoD)

Fitur Laporan Keuangan dinyatakan selesai (*Done*) jika memenuhi kriteria berikut:
1. **Dinamis & Akurat**:
   - Memilih bulan dan tahun pada modal langsung memuat data yang sesuai dari Firestore.
   - Angka total pengeluaran dan pemasukan pada halaman Laporan identik dengan ringkasan di Dashboard untuk bulan yang sama.
2. **Visualisasi Berfungsi Sempurna**:
   - Grafik batang tren harian menampilkan batang pengeluaran (merah) dan pemasukan (hijau) sesuai tanggal transaksi sebenarnya.
   - Diagram donat membagi persentase kategori secara proporsional dengan total 100%.
3. **Analisis Cerdas**:
   - Skor kesehatan finansial berubah secara logis (misal: jika defisit, status menampilkan peringatan "Kritis" dengan rekomendasi penghematan).
4. **Resiliensi Data**:
   - Bulan tanpa transaksi menampilkan *Empty State* ramah pengguna tanpa crash atau error UI.
5. **Kualitas Kode**:
   - Seluruh automated tests di `frontend/test/` berstatus passing 100%.
   - Analisis kode `flutter analyze` tidak memiliki pesan warning atau error.
