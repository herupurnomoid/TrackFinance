import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:share_plus/share_plus.dart';
import 'package:track_finance/core/models/user_profile.dart';
import 'package:track_finance/core/theme/app_theme.dart';
import 'package:track_finance/features/export/data/csv_import_parser.dart';
import 'package:track_finance/features/export/data/export_csv_service.dart';
import 'package:track_finance/features/export/data/export_pdf_service.dart';
import 'package:track_finance/features/export/data/export_share_service.dart';
import 'package:track_finance/features/export/data/sync_export_repository.dart';
import 'package:track_finance/features/export/data/sync_import_repository.dart';
import 'package:track_finance/features/export/presentation/screens/export_data_screen.dart';
import 'package:track_finance/features/transaction/data/transaction_model.dart';

void main() {
  group('ExportDataScreen Integration Tests (SYNC-06, SYNC-07, SYNC-08)', () {
    late FakeFirebaseFirestore fakeFirestore;
    late Directory tempDir;
    late SyncExportRepository exportRepo;
    late SyncImportRepository importRepo;
    const testUid = 'user_integration_123';
    final user = UserProfile(
      uid: testUid,
      email: 'user@test.com',
      displayName: 'Budi Santoso',
    );

    final tx1 = TransactionModel(
      id: 'tx_oct_01',
      type: 'expense',
      amount: 50000,
      categoryId: 'exp-1',
      categoryName: 'Makanan & Minuman',
      categoryIconCode: 1,
      notes: 'Sarapan',
      timeStr: '08:00',
      date: DateTime(2026, 10, 5, 8, 0),
      dateKey: '2026-10-05',
      monthKey: '2026-10',
      year: 2026,
      month: 9,
      day: 5,
    );

    final tx2 = TransactionModel(
      id: 'tx_oct_02',
      type: 'income',
      amount: 2500000,
      categoryId: 'inc-1',
      categoryName: 'Gaji Pokok',
      categoryIconCode: 2,
      notes: 'Bonus',
      timeStr: '10:00',
      date: DateTime(2026, 10, 7, 10, 0),
      dateKey: '2026-10-07',
      monthKey: '2026-10',
      year: 2026,
      month: 9,
      day: 7,
    );

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();
      tempDir = await Directory.systemTemp.createTemp('tf_ui_export_');

      final shareService = ExportShareService(
        tempDirProvider: () async => tempDir,
        shareFilesLauncher: (files, {subject, text, sharePositionOrigin}) async {
          return const ShareResult('success', ShareResultStatus.success);
        },
      );

      exportRepo = SyncExportRepository(
        firestore: fakeFirestore,
        csvService: const ExportCsvService(),
        pdfService: const ExportPdfService(),
        shareService: shareService,
      );
      SyncExportRepository.instance = exportRepo;

      importRepo = SyncImportRepository(
        firestore: fakeFirestore,
        parser: const CsvImportParser(),
      );
      SyncImportRepository.instance = importRepo;

      // Seed transactions
      await fakeFirestore
          .collection('users')
          .doc(testUid)
          .collection('transactions')
          .doc(tx1.id)
          .set(tx1.toFirestore());

      await fakeFirestore
          .collection('users')
          .doc(testUid)
          .collection('transactions')
          .doc(tx2.id)
          .set(tx2.toFirestore());
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    testWidgets('Dynamic transaction estimates update on real Firestore query (SYNC-07)', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ExportDataScreen(
            user: user,
            initialIsLoading: false,
            initialIsExport: true,
            initialExportPeriod: 'Rentang',
            initialExportFormat: 'CSV',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Transaksi di rentang default Oktober ada 2
      expect(find.text('2 transaksi'), findsOneWidget);

      // Switch to Bulan
      await tester.tap(find.text('Bulan'));
      await tester.pumpAndSettle();

      expect(find.text('2 transaksi'), findsOneWidget);
    });

    testWidgets('Export execution calls export pipeline and displays success dialog (SYNC-06)', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ExportDataScreen(
            user: user,
            initialIsLoading: false,
            initialIsExport: true,
            initialExportPeriod: 'Bulan',
            initialExportFormat: 'CSV',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Ekspor CSV button
      await tester.tap(find.text('Ekspor CSV'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();

      // Verify success dialog
      expect(find.text('2 transaksi diekspor'), findsOneWidget);
      expect(find.text('Selesai'), findsOneWidget);

      await tester.tap(find.text('Selesai'));
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });

    testWidgets('Import tab file picking parses real CSV and updates UI model (SYNC-08)', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      const mockCsv = '''No,Tanggal,Tipe,Kategori,Nominal,Catatan
1,2026-10-01,PENGELUARAN,Makanan & Minuman,30000,Nasi campur
2,2026-10-02,PEMASUKAN,Gaji Pokok,3500000,Gaji
3,2026-10-03,BAD_TYPE,Makanan & Minuman,50000,Error row''';

      Future<FilePickerResult?> mockFilePicker() async {
        return FilePickerResult([
          PlatformFile(
            name: 'custom_import.csv',
            size: mockCsv.length,
            bytes: utf8.encode(mockCsv),
          ),
        ]);
      }

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ExportDataScreen(
            user: user,
            initialIsLoading: false,
            initialIsExport: false,
            initialHasFile: false,
            filePicker: mockFilePicker,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap Drop Zone
      expect(find.text('Pilih file CSV'), findsOneWidget);
      await tester.tap(find.text('Pilih file CSV'));
      await tester.pumpAndSettle();

      // Verify uploaded file card & stats
      expect(find.text('custom_import.csv'), findsOneWidget);
      expect(find.text('2'), findsWidgets); // 2 valid
      expect(find.text('1'), findsWidgets); // 1 problematic
    });

    testWidgets('Import tab previews, problematic rows modal, and execute import flow (SYNC-11, SYNC-12, SYNC-14)', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ExportDataScreen(
            user: user,
            initialIsLoading: false,
            initialIsExport: false,
            initialHasFile: true,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // 1. Verify preview and stats (SYNC-11)
      expect(find.text('transaksi_oktober.csv'), findsOneWidget);
      expect(find.text('Pratinjau Data'), findsOneWidget);
      expect(find.text('Makanan & Minuman'), findsWidgets);
      expect(find.text('Transportasi'), findsWidgets);
      expect(find.text('Gaji & Pendapatan'), findsWidgets);

      // 2. Open Problematic Rows Modal (SYNC-12)
      expect(find.text('Lihat baris bermasalah'), findsOneWidget);
      await tester.tap(find.text('Lihat baris bermasalah'));
      await tester.pumpAndSettle();

      expect(find.text('Baris Bermasalah (3)'), findsOneWidget);
      expect(find.text('Baris 42'), findsOneWidget);
      expect(find.text('Nominal tidak valid atau kosong'), findsOneWidget);

      // Dismiss Problematic Rows Modal
      expect(find.text('Mengerti'), findsOneWidget);
      await tester.tap(find.text('Mengerti'));
      await tester.pumpAndSettle();

      expect(find.text('Baris Bermasalah (3)'), findsNothing);

      // 3. Execute Import (SYNC-14)
      expect(find.text('Impor 120 Transaksi'), findsOneWidget);
      await tester.tap(find.text('Impor 120 Transaksi'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pumpAndSettle();

      // Verify success dialog
      expect(find.text('120 transaksi diimpor'), findsOneWidget);
      expect(find.text('Selesai'), findsOneWidget);

      await tester.tap(find.text('Selesai'));
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });

    testWidgets('Import tab file removal dialog cancels and confirms (SYNC-12)', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ExportDataScreen(
            user: user,
            initialIsLoading: false,
            initialIsExport: false,
            initialHasFile: true,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap remove button
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Hapus File Terpilih?'), findsOneWidget);

      // Tap Batal
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      expect(find.text('transaksi_oktober.csv'), findsOneWidget);

      // Tap remove and confirm
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hapus'));
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Verify returned to empty state
      expect(find.text('Pilih file CSV'), findsOneWidget);
    });

    testWidgets('Tap disabled import button when no file chosen shows alert toast (SYNC-12)', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ExportDataScreen(
            user: user,
            initialIsLoading: false,
            initialIsExport: false,
            initialHasFile: false,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Button says "Impor" (Segmented toggle also has "Impor", so bottom CTA is last)
      final importButton = find.text('Impor').last;
      expect(importButton, findsOneWidget);
      await tester.tap(importButton);
      await tester.pump();

      expect(find.text('Pilih file CSV terlebih dahulu untuk mengimpor'), findsOneWidget);

      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
    });

    testWidgets('File picker gracefully handles Android SAF files without extension', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      const mockCsv = '''No,Tanggal,Tipe,Kategori,Nominal,Catatan
1,2026-10-01,PENGELUARAN,Makanan & Minuman,25000,Makan siang''';

      Future<FilePickerResult?> mockSafFilePicker() async {
        return FilePickerResult([
          PlatformFile(
            name: 'transaksi',
            size: mockCsv.length,
            bytes: utf8.encode(mockCsv),
          ),
        ]);
      }

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ExportDataScreen(
            user: user,
            initialIsLoading: false,
            initialIsExport: false,
            initialHasFile: false,
            filePicker: mockSafFilePicker,
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Pilih file CSV'));
      await tester.pumpAndSettle();

      // Should succeed and display effective file name
      expect(find.text('transaksi.csv'), findsOneWidget);
      expect(find.text('1'), findsWidgets);
    });

    testWidgets('File picker rejects binary non-CSV files with alert toast', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.625;
      addTearDown(() => tester.view.resetPhysicalSize());

      final pdfBytes = Uint8List.fromList([0x25, 0x50, 0x44, 0x46, 0x2D, 0x31, 0x2E, 0x35]);
      Future<FilePickerResult?> mockBinaryFilePicker() async {
        return FilePickerResult([
          PlatformFile(
            name: 'dokumen.pdf',
            size: pdfBytes.length,
            bytes: pdfBytes,
          ),
        ]);
      }

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: ExportDataScreen(
            user: user,
            initialIsLoading: false,
            initialIsExport: false,
            initialHasFile: false,
            filePicker: mockBinaryFilePicker,
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Pilih file CSV'));
      await tester.pump();

      expect(find.text('Format berkas harus .csv (contoh: transaksi.csv)'), findsOneWidget);
    });
  });
}
