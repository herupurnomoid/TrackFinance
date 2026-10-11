import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:track_finance/features/export/data/export_csv_service.dart';
import 'package:track_finance/features/transaction/data/transaction_model.dart';

void main() {
  group('ExportCsvService Unit Tests (SYNC-02)', () {
    const csvService = ExportCsvService();

    final testExpense = TransactionModel(
      id: 'tx_1',
      type: 'expense',
      amount: 25000,
      categoryId: 'exp-1',
      categoryName: 'Makanan & Minuman',
      categoryIconCode: 1234,
      notes: 'Makan siang nasi padang',
      timeStr: '12:30',
      date: DateTime(2026, 10, 5, 12, 30),
      dateKey: '2026-10-05',
      monthKey: '2026-10',
      year: 2026,
      month: 9,
      day: 5,
    );

    final testIncome = TransactionModel(
      id: 'tx_2',
      type: 'income',
      amount: 5000000,
      categoryId: 'inc-1',
      categoryName: 'Gaji Pokok',
      categoryIconCode: 5678,
      notes: 'Gaji bulan Oktober',
      timeStr: '09:00',
      date: DateTime(2026, 10, 1, 9, 0),
      dateKey: '2026-10-01',
      monthKey: '2026-10',
      year: 2026,
      month: 9,
      day: 1,
    );

    test('generateCsv with empty transactions returns header line only', () {
      final csv = csvService.generateCsv([]);
      expect(csv.trim(), equals('No,Tanggal,Waktu,Tipe,Kategori,Nominal,Catatan'));
    });

    test('generateCsv converts transactions with standard headers and RFC 4180 format', () {
      final csv = csvService.generateCsv([testExpense, testIncome]);
      final lines = const LineSplitter().convert(csv);

      expect(lines.length, equals(3));
      expect(lines[0], equals('No,Tanggal,Waktu,Tipe,Kategori,Nominal,Catatan'));
      expect(lines[1], equals('1,2026-10-05,12:30,PENGELUARAN,Makanan & Minuman,25000,Makan siang nasi padang'));
      expect(lines[2], equals('2,2026-10-01,09:00,PEMASUKAN,Gaji Pokok,5000000,Gaji bulan Oktober'));
    });

    test('generateCsv correctly escapes commas, quotes, and newlines in notes', () {
      final trickyTx = testExpense.copyWith(
        id: 'tx_tricky',
        notes: 'Beli "kopi", teh & donat\nCatatan baris 2',
      );

      final csv = csvService.generateCsv([trickyTx]);
      expect(csv, contains('"Beli ""kopi"", teh & donat\nCatatan baris 2"'));
    });

    test('generateCsvBytes returns matching UTF-8 byte stream', () {
      final bytes = csvService.generateCsvBytes([testExpense]);
      final decoded = utf8.decode(bytes);

      expect(decoded, equals(csvService.generateCsv([testExpense])));
    });
  });
}
