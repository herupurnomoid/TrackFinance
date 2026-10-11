import 'dart:convert';
import 'dart:io';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus/share_plus.dart';
import 'package:track_finance/features/export/data/export_csv_service.dart';
import 'package:track_finance/features/export/data/export_pdf_service.dart';
import 'package:track_finance/features/export/data/export_share_service.dart';
import 'package:track_finance/features/export/data/sync_export_repository.dart';
import 'package:track_finance/features/transaction/data/transaction_model.dart';

void main() {
  group('SyncExportRepository Unit Tests (SYNC-01 to SYNC-05)', () {
    late FakeFirebaseFirestore fakeFirestore;
    late Directory tempDir;
    late ExportShareService shareService;
    late SyncExportRepository repository;
    const testUid = 'user_sync_test';

    final txSept = TransactionModel(
      id: 'tx_sept',
      type: 'expense',
      amount: 50000,
      categoryId: 'exp-1',
      categoryName: 'Makanan',
      categoryIconCode: 1,
      notes: 'Makan September',
      timeStr: '12:00',
      date: DateTime(2026, 9, 30, 20, 0),
      dateKey: '2026-09-30',
      monthKey: '2026-09',
      year: 2026,
      month: 8,
      day: 30,
    );

    final txOct1 = TransactionModel(
      id: 'tx_oct1',
      type: 'income',
      amount: 4000000,
      categoryId: 'inc-1',
      categoryName: 'Gaji Pokok',
      categoryIconCode: 2,
      notes: 'Gaji Oktober',
      timeStr: '08:00',
      date: DateTime(2026, 10, 1, 8, 0),
      dateKey: '2026-10-01',
      monthKey: '2026-10',
      year: 2026,
      month: 9,
      day: 1,
    );

    final txOct15 = TransactionModel(
      id: 'tx_oct15',
      type: 'expense',
      amount: 75000,
      categoryId: 'exp-2',
      categoryName: 'Transportasi',
      categoryIconCode: 3,
      notes: 'Bensin',
      timeStr: '14:00',
      date: DateTime(2026, 10, 15, 14, 0),
      dateKey: '2026-10-15',
      monthKey: '2026-10',
      year: 2026,
      month: 9,
      day: 15,
    );

    final txNov = TransactionModel(
      id: 'tx_nov',
      type: 'expense',
      amount: 100000,
      categoryId: 'exp-3',
      categoryName: 'Belanja',
      categoryIconCode: 4,
      notes: 'Belanja November',
      timeStr: '10:00',
      date: DateTime(2026, 11, 1, 10, 0),
      dateKey: '2026-11-01',
      monthKey: '2026-11',
      year: 2026,
      month: 10,
      day: 1,
    );

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();
      tempDir = await Directory.systemTemp.createTemp('tf_sync_repo_test_');

      shareService = ExportShareService(
        tempDirProvider: () async => tempDir,
        shareFilesLauncher: (files, {subject, text, sharePositionOrigin}) async {
          return const ShareResult('success', ShareResultStatus.success);
        },
      );

      repository = SyncExportRepository(
        firestore: fakeFirestore,
        csvService: const ExportCsvService(),
        pdfService: const ExportPdfService(),
        shareService: shareService,
      );

      // Isi data awal transaksi
      for (final tx in [txSept, txOct1, txOct15, txNov]) {
        await fakeFirestore
            .collection('users')
            .doc(testUid)
            .collection('transactions')
            .doc(tx.id)
            .set(tx.toFirestore());
      }
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test('getTransactionsByDateRange returns only transactions within specified range', () async {
      final results = await repository.getTransactionsByDateRange(
        testUid,
        startDate: DateTime(2026, 10, 1),
        endDate: DateTime(2026, 10, 31),
      );

      expect(results.length, equals(2));
      expect(results.map((e) => e.id), containsAll(['tx_oct1', 'tx_oct15']));
      expect(results.any((e) => e.id == 'tx_sept'), isFalse);
      expect(results.any((e) => e.id == 'tx_nov'), isFalse);
    });

    test('getTransactions normalizes inverted date range automatically', () async {
      final results = await repository.getTransactions(
        testUid,
        startDate: DateTime(2026, 10, 31),
        endDate: DateTime(2026, 10, 1),
      );

      expect(results.length, equals(2));
    });

    test('getTransactionsByDateRange returns empty list for empty UID', () async {
      final results = await repository.getTransactionsByDateRange(
        '',
        startDate: DateTime(2026, 10, 1),
        endDate: DateTime(2026, 10, 31),
      );

      expect(results, isEmpty);
    });

    test('exportCsvBytes generates valid CSV content from real Firestore query', () async {
      final bytes = await repository.exportCsvBytes(
        uid: testUid,
        startDate: DateTime(2026, 10, 1),
        endDate: DateTime(2026, 10, 31),
      );

      final text = utf8.decode(bytes);
      expect(text, contains('No,Tanggal,Waktu,Tipe,Kategori,Nominal,Catatan'));
      expect(text, contains('Gaji Pokok'));
      expect(text, contains('Transportasi'));
      expect(text, isNot(contains('Belanja November')));
    });

    test('exportPdfBytes generates valid PDF bytes from real Firestore query', () async {
      final bytes = await repository.exportPdfBytes(
        uid: testUid,
        startDate: DateTime(2026, 10, 1),
        endDate: DateTime(2026, 10, 31),
        userName: 'Budi Santoso',
      );

      expect(bytes.isNotEmpty, isTrue);
      expect(utf8.decode(bytes.sublist(0, 5)), equals('%PDF-'));
    });

    test('exportCsvAndShare writes temp file and triggers share sheet', () async {
      final file = await repository.exportCsvAndShare(
        uid: testUid,
        startDate: DateTime(2026, 10, 1),
        endDate: DateTime(2026, 10, 31),
        fileName: 'october_export.csv',
      );

      expect(file.existsSync(), isTrue);
      expect(file.path.endsWith('october_export.csv'), isTrue);
    });

    test('exportPdfAndShare writes temp file and triggers share sheet', () async {
      final file = await repository.exportPdfAndShare(
        uid: testUid,
        startDate: DateTime(2026, 10, 1),
        endDate: DateTime(2026, 10, 31),
        fileName: 'october_export.pdf',
      );

      expect(file.existsSync(), isTrue);
      expect(file.path.endsWith('october_export.pdf'), isTrue);
    });

    test('exportAndShare delegates correctly based on format', () async {
      final csvFile = await repository.exportAndShare(
        uid: testUid,
        startDate: DateTime(2026, 10, 1),
        endDate: DateTime(2026, 10, 31),
        format: 'CSV',
        fileName: 'delegated.csv',
      );
      expect(csvFile.path.endsWith('delegated.csv'), isTrue);

      final pdfFile = await repository.exportAndShare(
        uid: testUid,
        startDate: DateTime(2026, 10, 1),
        endDate: DateTime(2026, 10, 31),
        format: 'PDF',
        fileName: 'delegated.pdf',
      );
      expect(pdfFile.path.endsWith('delegated.pdf'), isTrue);
    });
  });
}
