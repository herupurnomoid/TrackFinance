import '../../transaction/data/transaction_model.dart';

/// Model Data untuk Pratinjau File Impor dan Validasi CSV
class ImportTransactionPreview {
  final String category;
  final String date;
  final double amount;
  final bool isExpense;

  const ImportTransactionPreview({
    required this.category,
    required this.date,
    required this.amount,
    required this.isExpense,
  });

  String get formattedAmount {
    // Format mata uang sederhana (cth: -Rp21.000 atau +Rp1.500.000)
    final prefix = isExpense ? '-Rp' : '+Rp';
    final rawNumber = amount.toInt().toString();
    final chars = rawNumber.split('').reversed.toList();
    final parts = <String>[];
    for (int i = 0; i < chars.length; i++) {
      if (i > 0 && i % 3 == 0) parts.add('.');
      parts.add(chars[i]);
    }
    final formatted = parts.reversed.join('');
    return '$prefix$formatted';
  }
}

class ImportProblematicRow {
  final int rowNumber;
  final String reason;
  final String rawData;

  const ImportProblematicRow({
    required this.rowNumber,
    required this.reason,
    required this.rawData,
  });
}

class ImportFileModel {
  final String fileName;
  final int totalRows;
  final int validCount;
  final int duplicateCount;
  final int errorCount;
  final List<ImportTransactionPreview> previews;
  final List<ImportProblematicRow> problematicRows;
  final List<TransactionModel> validTransactions;

  const ImportFileModel({
    required this.fileName,
    required this.totalRows,
    required this.validCount,
    required this.duplicateCount,
    required this.errorCount,
    required this.previews,
    required this.problematicRows,
    this.validTransactions = const [],
  });

  bool get hasErrors => errorCount > 0;
  bool get hasDuplicates => duplicateCount > 0;
  bool get canImport => validCount > 0;
  double get totalValidAmount => validTransactions.fold(0.0, (sum, tx) => sum + tx.amount);

  /// Data bawaan sesuai referensi mockup: transaksi_oktober.csv (128 baris)
  static ImportFileModel defaultMock() {
    return ImportFileModel(
      fileName: 'transaksi_oktober.csv',
      totalRows: 128,
      validCount: 120,
      duplicateCount: 5,
      errorCount: 3,
      previews: const [
        ImportTransactionPreview(
          category: 'Makanan & Minuman',
          date: '01 Okt 2024',
          amount: 21000,
          isExpense: true,
        ),
        ImportTransactionPreview(
          category: 'Transportasi',
          date: '02 Okt 2024',
          amount: 35000,
          isExpense: true,
        ),
        ImportTransactionPreview(
          category: 'Gaji & Pendapatan',
          date: '03 Okt 2024',
          amount: 1500000,
          isExpense: false,
        ),
      ],
      problematicRows: const [
        ImportProblematicRow(
          rowNumber: 42,
          reason: 'Nominal tidak valid atau kosong',
          rawData: '42, 2024-10-12, PENGELUARAN, Belanja, [kosong], minimarket',
        ),
        ImportProblematicRow(
          rowNumber: 77,
          reason: 'Format tanggal tidak sesuai standar YYYY-MM-DD',
          rawData: '77, 15/10/24, PENGELUARAN, Hiburan, 50000, bioskop',
        ),
        ImportProblematicRow(
          rowNumber: 104,
          reason: 'Kategori tidak dikenali oleh sistem',
          rawData: '104, 2024-10-22, PEMASUKAN, Lain-lain, 250000, freelance',
        ),
      ],
      validTransactions: [
        TransactionModel(
          id: 'mock_tx_1',
          type: 'expense',
          amount: 21000,
          categoryId: 'exp-1',
          categoryName: 'Makanan & Minuman',
          categoryIconCode: 58737,
          notes: 'Makan siang',
          timeStr: '12:00',
          date: DateTime(2024, 10, 1, 12, 0),
          dateKey: '2024-10-01',
          monthKey: '2024-10',
          year: 2024,
          month: 9,
          day: 1,
        ),
        TransactionModel(
          id: 'mock_tx_2',
          type: 'expense',
          amount: 35000,
          categoryId: 'exp-2',
          categoryName: 'Transportasi',
          categoryIconCode: 57790,
          notes: 'Bensin motor',
          timeStr: '12:00',
          date: DateTime(2024, 10, 2, 12, 0),
          dateKey: '2024-10-02',
          monthKey: '2024-10',
          year: 2024,
          month: 9,
          day: 2,
        ),
        TransactionModel(
          id: 'mock_tx_3',
          type: 'income',
          amount: 1500000,
          categoryId: 'inc-1',
          categoryName: 'Gaji & Pendapatan',
          categoryIconCode: 58941,
          notes: 'Gaji pokok',
          timeStr: '12:00',
          date: DateTime(2024, 10, 3, 12, 0),
          dateKey: '2024-10-03',
          monthKey: '2024-10',
          year: 2024,
          month: 9,
          day: 3,
        ),
      ],
    );
  }
}
