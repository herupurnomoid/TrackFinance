import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:track_finance/features/export/data/export_pdf_service.dart';
import 'package:track_finance/features/transaction/data/transaction_model.dart';

void main() {
  group('ExportPdfService Unit Tests (SYNC-03)', () {
    const pdfService = ExportPdfService();

    final testExpense = TransactionModel(
      id: 'tx_1',
      type: 'expense',
      amount: 45000,
      categoryId: 'exp-1',
      categoryName: 'Makanan & Minuman',
      categoryIconCode: 1234,
      notes: 'Makan siang',
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
      amount: 3500000,
      categoryId: 'inc-1',
      categoryName: 'Gaji Pokok',
      categoryIconCode: 5678,
      notes: 'Gaji bulanan',
      timeStr: '09:00',
      date: DateTime(2026, 10, 1, 9, 0),
      dateKey: '2026-10-01',
      monthKey: '2026-10',
      year: 2026,
      month: 9,
      day: 1,
    );

    test('generatePdfBytes produces valid PDF bytes with %PDF magic header', () async {
      final bytes = await pdfService.generatePdfBytes(
        transactions: [testExpense, testIncome],
        userName: 'Ahmad Faiz',
        startDate: DateTime(2026, 10, 1),
        endDate: DateTime(2026, 10, 31),
      );

      expect(bytes.isNotEmpty, isTrue);
      // Valid PDF files start with %PDF-
      final header = utf8.decode(bytes.sublist(0, 5));
      expect(header, equals('%PDF-'));
    });

    test('pw.SvgImage parses trackfinance-logo.svg and generates PDF', () async {
      final svgStr = File('assets/icons/trackfinance-logo.svg').readAsStringSync();
      final doc = pw.Document();
      doc.addPage(
        pw.Page(
          build: (context) => pw.Center(
            child: pw.SvgImage(svg: svgStr, width: 64, height: 64),
          ),
        ),
      );
      final bytes = await doc.save();
      expect(bytes.isNotEmpty, isTrue);
      expect(utf8.decode(bytes.sublist(0, 5)), equals('%PDF-'));
    });

    test('generatePdfBytes succeeds when transactions list is empty', () async {
      final bytes = await pdfService.generatePdfBytes(
        transactions: [],
        userName: 'User Empty',
        periodLabel: 'Oktober 2026',
      );

      expect(bytes.isNotEmpty, isTrue);
      final header = utf8.decode(bytes.sublist(0, 5));
      expect(header, equals('%PDF-'));
    });

    test('generatePdfBytes gracefully handles multiple pages of transactions', () async {
      final manyTransactions = List.generate(
        60,
        (i) => TransactionModel(
          id: 'tx_$i',
          type: i.isEven ? 'expense' : 'income',
          amount: (i + 1) * 10000,
          categoryId: 'cat_${i % 5}',
          categoryName: 'Kategori ${i % 5}',
          categoryIconCode: 100,
          notes: 'Transaksi nomor $i',
          timeStr: '10:00',
          date: DateTime(2026, 10, (i % 28) + 1),
          dateKey: '2026-10-${((i % 28) + 1).toString().padLeft(2, '0')}',
          monthKey: '2026-10',
          year: 2026,
          month: 9,
          day: (i % 28) + 1,
        ),
      );

      final bytes = await pdfService.generatePdfBytes(
        transactions: manyTransactions,
        userName: 'High Volume User',
      );

      expect(bytes.isNotEmpty, isTrue);
      final header = utf8.decode(bytes.sublist(0, 5));
      expect(header, equals('%PDF-'));
    });

    test('generatePdfBytes incorporates TrackFinance SVG logo', () async {
      final bytes = await pdfService.generatePdfBytes(
        transactions: [testExpense],
        userName: 'Heru Purnomo',
        logoSvg: File('assets/icons/trackfinance-logo.svg').readAsStringSync(),
      );

      expect(bytes.isNotEmpty, isTrue);
      expect(utf8.decode(bytes.sublist(0, 5)), equals('%PDF-'));
    });
  });
}
