import 'package:flutter_test/flutter_test.dart';
import 'package:track_finance/features/category/data/category_model.dart';
import 'package:track_finance/features/export/data/csv_import_parser.dart';
import 'package:track_finance/features/transaction/data/transaction_model.dart';

void main() {
  group('CsvImportParser Unit Tests (SYNC-09 & SYNC-10)', () {
    const parser = CsvImportParser();
    final categories = [
      ...DefaultCategories.defaultExpenseCategories,
      ...DefaultCategories.defaultIncomeCategories,
    ];

    test('Throws FormatException if CSV is empty or only has headers', () {
      expect(
        () => parser.parse(
          csvString: '',
          fileName: 'empty.csv',
          categories: categories,
        ),
        throwsA(isA<FormatException>()),
      );

      expect(
        () => parser.parse(
          csvString: 'No,Tanggal,Tipe,Kategori,Nominal,Catatan',
          fileName: 'headers_only.csv',
          categories: categories,
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('Successfully parses valid expense and income rows', () {
      const csv = '''No,Tanggal,Tipe,Kategori,Nominal,Catatan
1,2026-10-01,PENGELUARAN,Makanan & Minuman,25000,Makan siang
2,2026-10-02,PEMASUKAN,Gaji Pokok,5000000,Gaji bulanan''';

      final model = parser.parse(
        csvString: csv,
        fileName: 'valid.csv',
        categories: categories,
      );

      expect(model.totalRows, equals(2));
      expect(model.validCount, equals(2));
      expect(model.duplicateCount, equals(0));
      expect(model.errorCount, equals(0));
      expect(model.previews.length, equals(2));
      expect(model.problematicRows, isEmpty);

      expect(model.validTransactions.length, equals(2));
      expect(model.validTransactions[0].isExpense, isTrue);
      expect(model.validTransactions[0].amount, equals(25000));
      expect(model.validTransactions[0].categoryName, equals('Makanan & Minuman'));

      expect(model.validTransactions[1].isIncome, isTrue);
      expect(model.validTransactions[1].amount, equals(5000000));
      expect(model.validTransactions[1].categoryName, equals('Gaji Pokok'));
    });

    test('Maps category case-insensitively and falls back to Lainnya if unmapped', () {
      const csv = '''No,Tanggal,Tipe,Kategori,Nominal,Catatan
1,2026-10-01,PENGELUARAN,makanan & minuman,25000,Case insensitive
2,2026-10-02,PENGELUARAN,Kategori Aneh Tidak Ada,30000,Fallback test''';

      final model = parser.parse(
        csvString: csv,
        fileName: 'fallback.csv',
        categories: categories,
      );

      expect(model.validCount, equals(2));
      expect(model.validTransactions[0].categoryName, equals('Makanan & Minuman'));
      expect(model.validTransactions[1].categoryName, equals('Lainnya'));
    });

    test('Flags rows with missing columns (< 5) as problematic', () {
      const csv = '''No,Tanggal,Tipe,Kategori,Nominal,Catatan
1,2026-10-01,PENGELUARAN,Makanan''';

      final model = parser.parse(
        csvString: csv,
        fileName: 'incomplete.csv',
        categories: categories,
      );

      expect(model.validCount, equals(0));
      expect(model.errorCount, equals(1));
      expect(model.problematicRows.first.reason, contains('Struktur kolom'));
    });

    test('Flags rows with invalid date formats', () {
      const csv = '''No,Tanggal,Tipe,Kategori,Nominal,Catatan
1,invalid-date,PENGELUARAN,Makanan & Minuman,20000,Test''';

      final model = parser.parse(
        csvString: csv,
        fileName: 'bad_date.csv',
        categories: categories,
      );

      expect(model.validCount, equals(0));
      expect(model.errorCount, equals(1));
      expect(model.problematicRows.first.reason, contains('Format tanggal tidak sesuai'));
    });

    test('Flags rows with unrecognized transaction type', () {
      const csv = '''No,Tanggal,Tipe,Kategori,Nominal,Catatan
1,2026-10-01,TRANSFER_SALDO,Makanan & Minuman,20000,Test''';

      final model = parser.parse(
        csvString: csv,
        fileName: 'bad_type.csv',
        categories: categories,
      );

      expect(model.validCount, equals(0));
      expect(model.errorCount, equals(1));
      expect(model.problematicRows.first.reason, contains('Tipe transaksi harus bernilai'));
    });

    test('Flags rows with invalid or zero amount', () {
      const csv = '''No,Tanggal,Tipe,Kategori,Nominal,Catatan
1,2026-10-01,PENGELUARAN,Makanan & Minuman,0,Zero
2,2026-10-02,PENGELUARAN,Makanan & Minuman,bukan_angka,Non number''';

      final model = parser.parse(
        csvString: csv,
        fileName: 'bad_amount.csv',
        categories: categories,
      );

      expect(model.validCount, equals(0));
      expect(model.errorCount, equals(2));
      expect(model.problematicRows.first.reason, contains('Nominal tidak valid'));
    });

    test('Detects duplicate transactions against existing database records (SYNC-10)', () {
      final existingTx = TransactionModel(
        id: 'tx_exist',
        type: 'expense',
        amount: 25000,
        categoryId: 'exp-1',
        categoryName: 'Makanan & Minuman',
        categoryIconCode: 123,
        notes: 'Makan',
        timeStr: '12:00',
        date: DateTime(2026, 10, 1),
        dateKey: '2026-10-01',
        monthKey: '2026-10',
        year: 2026,
        month: 9,
        day: 1,
      );

      const csv = '''No,Tanggal,Tipe,Kategori,Nominal,Catatan
1,2026-10-01,PENGELUARAN,Makanan & Minuman,25000,Duplicate with DB
2,2026-10-05,PENGELUARAN,Makanan & Minuman,35000,Fresh transaction''';

      final model = parser.parse(
        csvString: csv,
        fileName: 'dup_db.csv',
        categories: categories,
        existingTransactions: [existingTx],
      );

      expect(model.validCount, equals(1));
      expect(model.duplicateCount, equals(1));
      expect(model.validTransactions.length, equals(1));
      expect(model.validTransactions.first.amount, equals(35000));
    });

    test('Detects in-file identical duplicates (SYNC-10)', () {
      const csv = '''No,Tanggal,Tipe,Kategori,Nominal,Catatan
1,2026-10-01,PENGELUARAN,Makanan & Minuman,25000,First
2,2026-10-01,PENGELUARAN,Makanan & Minuman,25000,Second identical''';

      final model = parser.parse(
        csvString: csv,
        fileName: 'dup_file.csv',
        categories: categories,
      );

      expect(model.validCount, equals(1));
      expect(model.duplicateCount, equals(1));
      expect(model.validTransactions.length, equals(1));
    });

    test('Caps preview list to a maximum of 10 items', () {
      final buffer = StringBuffer('No,Tanggal,Tipe,Kategori,Nominal,Catatan\n');
      for (int i = 1; i <= 15; i++) {
        buffer.writeln('$i,2026-10-${i.toString().padLeft(2, '0')},PENGELUARAN,Makanan & Minuman,${i * 1000},Item $i');
      }

      final model = parser.parse(
        csvString: buffer.toString(),
        fileName: 'many.csv',
        categories: categories,
      );

      expect(model.validCount, equals(15));
      expect(model.previews.length, equals(10));
    });

    test('Correctly parses user actual CSV with float amounts ending in .0 and resolves smart categories', () {
      const userCsv = '''No,Tanggal,Tipe,Kategori,Jumlah (IDR),Catatan,Sumber
1,2026-01-07,PENGELUARAN,Tagihan,20000.0,Pulsa,MANUAL
2,2026-01-07,PENGELUARAN,Makanan & Minuman,10000.0,esteh dan susu,MANUAL
3,2026-01-23,PEMASUKAN,Gaji,409091.0,,MANUAL
4,2026-01-24,PENGELUARAN,Tagihan,401821.0,,MANUAL
5,2026-01-25,PENGELUARAN,Gaya Hidup,23500.0,"Badminton 
",MANUAL
6,2026-01-30,PENGELUARAN,Hewan Peliharaan,15000.0,makanan kucing,MANUAL
7,2026-01-30,PENGELUARAN,Makanan & Minuman,5000.0,gorengan,MANUAL''';

      final model = parser.parse(
        csvString: userCsv,
        fileName: 'transaksi_2026-01.csv',
        categories: categories,
      );

      expect(model.totalRows, equals(7));
      expect(model.validCount, equals(7));
      expect(model.duplicateCount, equals(0));
      expect(model.errorCount, equals(0));
      expect(model.problematicRows, isEmpty);

      final txs = model.validTransactions;
      // 1. 20000.0 -> 20000 (NOT 200000!), Tagihan -> Tagihan & Pulsa
      expect(txs[0].amount, equals(20000));
      expect(txs[0].categoryName, equals('Tagihan & Pulsa'));
      expect(txs[0].isExpense, isTrue);

      // 2. 10000.0 -> 10000 (NOT 100000!), Makanan & Minuman
      expect(txs[1].amount, equals(10000));
      expect(txs[1].categoryName, equals('Makanan & Minuman'));

      // 3. 409091.0 -> 409091 (NOT 4090910!), Gaji -> Gaji Pokok
      expect(txs[2].amount, equals(409091));
      expect(txs[2].categoryName, equals('Gaji Pokok'));
      expect(txs[2].isIncome, isTrue);

      // 4. 401821.0 -> 401821 (NOT 4018210!), Tagihan -> Tagihan & Pulsa
      expect(txs[3].amount, equals(401821));
      expect(txs[3].categoryName, equals('Tagihan & Pulsa'));

      // 5. 23500.0 -> 23500 (NOT 235000!)
      expect(txs[4].amount, equals(23500));

      // 6. 15000.0 -> 15000 (NOT 150000!)
      expect(txs[5].amount, equals(15000));

      // 7. 5000.0 -> 5000 (NOT 50000!)
      expect(txs[6].amount, equals(5000));
      expect(txs[6].categoryName, equals('Makanan & Minuman'));
    });

    test('Correctly parses various currency amount formats (Rp, IDR, thousands separators)', () {
      const csv = '''No,Tanggal,Tipe,Kategori,Nominal,Catatan
1,2026-10-01,PENGELUARAN,Makanan & Minuman,Rp 25.000,Rupiah format
2,2026-10-02,PEMASUKAN,Gaji Pokok,"IDR 5.000.000",IDR format
3,2026-10-03,PENGELUARAN,Makanan & Minuman,"15,000.00",International float
4,2026-10-04,PENGELUARAN,Makanan & Minuman,"30.000,00",Indonesian decimal
5,2026-10-05,PENGELUARAN,Makanan & Minuman,-45000,Negative value''';

      final model = parser.parse(
        csvString: csv,
        fileName: 'formats.csv',
        categories: categories,
      );

      expect(model.validCount, equals(5));
      expect(model.validTransactions[0].amount, equals(25000));
      expect(model.validTransactions[1].amount, equals(5000000));
      expect(model.validTransactions[2].amount, equals(15000));
      expect(model.validTransactions[3].amount, equals(30000));
      expect(model.validTransactions[4].amount, equals(45000));
    });

    test('Correctly parses CSV containing Waktu column and populates timeStr and transaction DateTime', () {
      const csvWithTime = '''No,Tanggal,Waktu,Tipe,Kategori,Nominal,Catatan
1,2026-10-01,14:45,PENGELUARAN,Makanan & Minuman,35000,Makan sore
2,2026-10-02,08.15,PEMASUKAN,Gaji Pokok,4500000,Bonus proyek''';

      final model = parser.parse(
        csvString: csvWithTime,
        fileName: 'export_with_time.csv',
        categories: categories,
      );

      expect(model.validCount, equals(2));
      final tx1 = model.validTransactions[0];
      expect(tx1.timeStr, equals('14:45'));
      expect(tx1.date.hour, equals(14));
      expect(tx1.date.minute, equals(45));
      expect(tx1.amount, equals(35000));

      final tx2 = model.validTransactions[1];
      expect(tx2.timeStr, equals('08:15'));
      expect(tx2.date.hour, equals(8));
      expect(tx2.date.minute, equals(15));
      expect(tx2.amount, equals(4500000));
    });
  });
}
