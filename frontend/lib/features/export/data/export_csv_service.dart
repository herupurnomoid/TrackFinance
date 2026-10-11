import 'dart:convert';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import '../../transaction/data/transaction_model.dart';

/// Service untuk mengonversi kumpulan data [TransactionModel] menjadi berkas CSV
/// bertaraf RFC 4180 lengkap dengan baris header standar TrackFinance (SYNC-02).
class ExportCsvService {
  /// Header resmi berkas CSV transaksi TrackFinance
  static const List<String> csvHeaders = [
    'No',
    'Tanggal',
    'Waktu',
    'Tipe',
    'Kategori',
    'Nominal',
    'Catatan',
  ];

  const ExportCsvService();

  /// Mengonversi daftar [transactions] menjadi teks CSV sesuai standar RFC 4180.
  ///
  /// Kolom:
  /// 1. No: Nomor urut (1-indexed)
  /// 2. Tanggal: Format YYYY-MM-DD
  /// 3. Waktu: Format HH:mm (contoh: 14:30)
  /// 4. Tipe: `PENGELUARAN` atau `PEMASUKAN`
  /// 5. Kategori: Nama kategori transaksi
  /// 6. Nominal: Bilangan bulat positif dalam Rupiah
  /// 7. Catatan: Keterangan transaksi
  String generateCsv(List<TransactionModel> transactions) {
    final List<List<dynamic>> rows = [
      csvHeaders,
    ];

    for (int i = 0; i < transactions.length; i++) {
      final tx = transactions[i];
      final typeLabel = tx.isExpense ? 'PENGELUARAN' : 'PEMASUKAN';
      final timeLabel = _resolveTimeStr(tx);
      rows.add([
        i + 1,
        tx.dateKey,
        timeLabel,
        typeLabel,
        tx.categoryName,
        tx.amount,
        tx.notes,
      ]);
    }

    return const ListToCsvConverter(eol: '\n').convert(rows);
  }

  /// Mengambil representasi waktu transaksi yang konsisten (HH:mm)
  static String _resolveTimeStr(TransactionModel tx) {
    if (tx.timeStr.trim().isNotEmpty) {
      return tx.timeStr.trim();
    }
    final hour = tx.date.hour.toString().padLeft(2, '0');
    final minute = tx.date.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Mengonversi daftar [transactions] menjadi byte stream UTF-8 CSV.
  Uint8List generateCsvBytes(List<TransactionModel> transactions) {
    final csvContent = generateCsv(transactions);
    return Uint8List.fromList(utf8.encode(csvContent));
  }
}
