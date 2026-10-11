# 🛠️ Panduan Implementasi Teknis: Fitur Ekspor & Impor (Sync)

Dokumen ini memandu langkah-demi-langkah implementasi kode Flutter untuk mengintegrasikan **Fitur Ekspor, Impor Data, dan Sinkronisasi Cloud** dengan **Cloud Firestore SDK**.

---

## 🎯 Target Implementasi
1. Menambahkan dependensi pendukung pemrosesan file (`csv`, `share_plus`, `path_provider`, `file_picker`, `pdf`).
2. Membuat service layer `SyncExportRepository` untuk kueri data, konversi format (CSV & PDF), dan membuka lembar berbagi sistem (*Share Sheet*).
3. Membuat service layer `SyncImportRepository` untuk parsing berkas CSV, validasi skema per baris, dan eksekusi chunked batch ingestion.
4. Menghubungkan antarmuka [`ExportDataScreen`](file:///Users/heru/Development/TrackFinance/frontend/lib/features/export/presentation/screens/export_data_screen.dart) pada fungsi `_handleExecuteExport()` dan `_handleExecuteImport()`.

---

## 📦 Langkah 1: Tambahkan Dependensi di `pubspec.yaml`

Tambahkan package berikut ke [frontend/pubspec.yaml](file:///Users/heru/Development/TrackFinance/frontend/pubspec.yaml):

```yaml
dependencies:
  # Penanganan Berkas & Berbagi
  csv: ^6.0.0
  share_plus: ^10.1.4
  path_provider: ^2.1.5
  file_picker: ^8.1.7
  pdf: ^3.11.1
```

Jalankan perintah pengambilan paket:
```bash
cd frontend
flutter pub get
```

---

## 📂 Langkah 2: Buat `SyncExportRepository`

Buat file baru di [frontend/lib/features/export/data/sync_export_repository.dart](file:///Users/heru/Development/TrackFinance/frontend/lib/features/export/data/sync_export_repository.dart):

```dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../transaction/data/transaction_model.dart';

class SyncExportRepository {
  final FirebaseFirestore _firestore;

  SyncExportRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static final SyncExportRepository instance = SyncExportRepository();

  /// 1. Ambil transaksi berdasarkan rentang tanggal
  Future<List<TransactionModel>> getTransactions(
    String uid, {
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final startTimestamp = Timestamp.fromDate(DateTime(startDate.year, startDate.month, startDate.day, 0, 0, 0));
    final endTimestamp = Timestamp.fromDate(DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59));

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .where('date', isGreaterThanOrEqualTo: startTimestamp)
        .where('date', isLessThanOrEqualTo: endTimestamp)
        .orderBy('date', descending: false)
        .get();

    return snapshot.docs.map((doc) => TransactionModel.fromFirestore(doc)).toList();
  }

  /// 2. Ekspor ke Berkas CSV dan Buka Share Sheet
  Future<void> exportCsvAndShare({
    required String uid,
    required DateTime startDate,
    required DateTime endDate,
    required String fileName,
  }) async {
    final transactions = await getTransactions(uid, startDate: startDate, endDate: endDate);

    // Header CSV
    final List<List<dynamic>> rows = [
      ['No', 'Tanggal', 'Tipe', 'Kategori', 'Nominal', 'Catatan']
    ];

    // Data Baris
    for (int i = 0; i < transactions.length; i++) {
      final tx = transactions[i];
      final typeLabel = tx.isExpense ? 'PENGELUARAN' : 'PEMASUKAN';
      rows.add([
        i + 1,
        tx.dateKey,
        typeLabel,
        tx.categoryName,
        tx.amount,
        tx.notes,
      ]);
    }

    final csvString = const ListToCsvConverter().convert(rows);

    // Simpan ke direktori cache lokal sementara
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(csvString);

    // Trigger System Share Sheet
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Ekspor Data Keuangan TrackFinance',
      text: 'Berikut berkas riwayat transaksi TrackFinance Anda.',
    );
  }
}
```

---

## 📂 Langkah 3: Buat `SyncImportRepository`

Buat file baru di [frontend/lib/features/export/data/sync_import_repository.dart](file:///Users/heru/Development/TrackFinance/frontend/lib/features/export/data/sync_import_repository.dart):

```dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import '../../category/data/category_model.dart';
import '../../transaction/data/transaction_model.dart';
import 'import_data_model.dart';

class SyncImportRepository {
  final FirebaseFirestore _firestore;

  SyncImportRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static final SyncImportRepository instance = SyncImportRepository();

  /// 1. Parsing dan Validasi File CSV
  Future<ImportFileModel> parseAndValidateCsv(
    Uint8List fileBytes,
    String fileName,
    List<CategoryItem> categories,
  ) async {
    final csvString = utf8.decode(fileBytes);
    final rows = const CsvToListConverter(eol: '\n', shouldParseNumbers: false).convert(csvString);

    if (rows.isEmpty || rows.length == 1) {
      throw Exception('Berkas CSV kosong atau tidak memiliki baris transaksi.');
    }

    final List<ImportTransactionPreview> previews = [];
    final List<ImportProblematicRow> errorRows = [];
    int validCount = 0;
    int duplicateCount = 0;

    // Lewati baris header indeks 0
    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty || (row.length == 1 && row[0].toString().trim().isEmpty)) continue;

      if (row.length < 5) {
        errorRows.add(ImportProblematicRow(
          rowNumber: i + 1,
          reason: 'Struktur kolom baris tidak lengkap',
          rawData: row.join(', '),
        ));
        continue;
      }

      final dateRaw = row[1].toString().trim();
      final typeRaw = row[2].toString().trim().toUpperCase();
      final categoryRaw = row[3].toString().trim();
      final amountRaw = row[4].toString().replaceAll(RegExp(r'[^0-9]'), '');

      // Validasi Tanggal
      final parsedDate = DateTime.tryParse(dateRaw);
      if (parsedDate == null) {
        errorRows.add(ImportProblematicRow(
          rowNumber: i + 1,
          reason: 'Format tanggal tidak sesuai standar YYYY-MM-DD',
          rawData: row.join(', '),
        ));
        continue;
      }

      // Validasi Tipe
      final isExpense = typeRaw.contains('PENGELUARAN') || typeRaw.contains('EXPENSE');
      final isIncome = typeRaw.contains('PEMASUKAN') || typeRaw.contains('INCOME');
      if (!isExpense && !isIncome) {
        errorRows.add(ImportProblematicRow(
          rowNumber: i + 1,
          reason: 'Tipe transaksi harus bernilai PENGELUARAN atau PEMASUKAN',
          rawData: row.join(', '),
        ));
        continue;
      }

      // Validasi Nominal
      final amount = int.tryParse(amountRaw);
      if (amount == null || amount <= 0) {
        errorRows.add(ImportProblematicRow(
          rowNumber: i + 1,
          reason: 'Nominal tidak valid atau bernilai 0',
          rawData: row.join(', '),
        ));
        continue;
      }

      validCount++;
      if (previews.length < 10) {
        previews.add(ImportTransactionPreview(
          category: categoryRaw.isNotEmpty ? categoryRaw : 'Lainnya',
          date: dateRaw,
          amount: amount.toDouble(),
          isExpense: isExpense,
        ));
      }
    }

    return ImportFileModel(
      fileName: fileName,
      totalRows: rows.length - 1,
      validCount: validCount,
      duplicateCount: duplicateCount,
      errorCount: errorRows.length,
      previews: previews,
      problematicRows: errorRows,
    );
  }

  /// 2. Eksekusi Impor Batch Massal (Chunking per 200 Transaksi)
  Future<void> commitImport(String uid, List<TransactionModel> transactions) async {
    const chunkSize = 200;

    for (var i = 0; i < transactions.length; i += chunkSize) {
      final end = (i + chunkSize < transactions.length) ? i + chunkSize : transactions.length;
      final chunk = transactions.sublist(i, end);

      final batch = _firestore.batch();
      int totalBalanceDelta = 0;
      final Map<String, ({int income, int expense, int count})> summaryDeltas = {};

      for (final tx in chunk) {
        final txRef = _firestore.collection('users').doc(uid).collection('transactions').doc(tx.id);
        batch.set(txRef, tx.toFirestore());

        final isExp = tx.isExpense;
        final signed = isExp ? -tx.amount : tx.amount;
        totalBalanceDelta += signed;

        final current = summaryDeltas[tx.monthKey] ?? (income: 0, expense: 0, count: 0);
        summaryDeltas[tx.monthKey] = (
          income: current.income + (!isExp ? tx.amount : 0),
          expense: current.expense + (isExp ? tx.amount : 0),
          count: current.count + 1,
        );
      }

      // Perbarui ringkasan bulanan yang terdampak
      for (final entry in summaryDeltas.entries) {
        final summaryRef = _firestore.collection('users').doc(uid).collection('monthly_summaries').doc(entry.key);
        batch.set(summaryRef, {
          'totalIncome': FieldValue.increment(entry.value.income),
          'totalExpense': FieldValue.increment(entry.value.expense),
          'netCashflow': FieldValue.increment(entry.value.income - entry.value.expense),
          'transactionCount': FieldValue.increment(entry.value.count),
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      // Perbarui total saldo pengguna
      final userRef = _firestore.collection('users').doc(uid);
      batch.update(userRef, {
        'totalBalance': FieldValue.increment(totalBalanceDelta),
      });

      await batch.commit();
    }
  }
}
```

---

## 📂 Langkah 4: Integrasi ke `ExportDataScreen`

Di file [frontend/lib/features/export/presentation/screens/export_data_screen.dart](file:///Users/heru/Development/TrackFinance/frontend/lib/features/export/presentation/screens/export_data_screen.dart):

1. **Pilih File CSV dari Perangkat**:
```dart
Future<void> _handlePickFile() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['csv'],
    withData: true,
  );

  if (result == null || result.files.isEmpty) return;

  final file = result.files.first;
  final bytes = file.bytes;
  if (bytes == null) return;

  setState(() => _isLoading = true);

  try {
    final model = await SyncImportRepository.instance.parseAndValidateCsv(
      bytes,
      file.name,
      DefaultCategories.defaultExpenseCategories,
    );
    setState(() => _uploadedFile = model);
  } catch (e) {
    _showToast('Gagal membaca berkas: $e');
  } finally {
    setState(() => _isLoading = false);
  }
}
```

2. **Eksekusi Ekspor Riil**:
```dart
Future<void> _handleExecuteExport() async {
  final uid = widget.user?.uid;
  if (uid == null || _isProcessing) return;

  setState(() => _isProcessing = true);

  try {
    final fileName = 'transaksi_${DateTime.now().millisecondsSinceEpoch}.${_exportFormat.toLowerCase()}';
    await SyncExportRepository.instance.exportCsvAndShare(
      uid: uid,
      startDate: _exportStartDate,
      endDate: _exportEndDate,
      fileName: fileName,
    );

    if (mounted) {
      _showExportSuccessModal();
    }
  } catch (e) {
    _showToast('Gagal mengekspor data: $e');
  } finally {
    if (mounted) setState(() => _isProcessing = false);
  }
}
```

---

## 🧪 Langkah 5: Pengujian & Validasi

Jalankan test suite untuk memastikan seluruh pipeline parsing dan batch commit berjalan tanpa kendala:
```bash
cd frontend
flutter test
```
Pastikan berkas CSV dapat diekspor, dibagikan, dan diimpor kembali ke database secara konsisten tanpa kesalahan saldo.
