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

  const ImportFileModel({
    required this.fileName,
    required this.totalRows,
    required this.validCount,
    required this.duplicateCount,
    required this.errorCount,
    required this.previews,
    required this.problematicRows,
  });

  /// Data bawaan sesuai referensi mockup: transaksi_oktober.csv (128 baris)
  static ImportFileModel defaultMock() {
    return const ImportFileModel(
      fileName: 'transaksi_oktober.csv',
      totalRows: 128,
      validCount: 120,
      duplicateCount: 5,
      errorCount: 3,
      previews: [
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
      problematicRows: [
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
    );
  }
}
