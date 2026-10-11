import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../transaction/data/transaction_model.dart';
import 'export_csv_service.dart';
import 'export_pdf_service.dart';
import 'export_share_service.dart';

/// Repository untuk kueri data transaksi per rentang waktu,
/// konversi berkas (CSV & PDF), serta integrasi berbagi berkas ke sistem perangkat (SYNC-02 s/d SYNC-05).
class SyncExportRepository {
  final FirebaseFirestore _firestore;
  final ExportCsvService _csvService;
  final ExportPdfService _pdfService;
  final ExportShareService _shareService;

  SyncExportRepository({
    FirebaseFirestore? firestore,
    ExportCsvService? csvService,
    ExportPdfService? pdfService,
    ExportShareService? shareService,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _csvService = csvService ?? const ExportCsvService(),
        _pdfService = pdfService ?? const ExportPdfService(),
        _shareService = shareService ?? ExportShareService.instance;

  static SyncExportRepository? _instance;

  /// Singleton instance default untuk [SyncExportRepository]
  static SyncExportRepository get instance => _instance ??= SyncExportRepository();

  /// Setter untuk unit testing / dependency injection
  @visibleForTesting
  static set instance(SyncExportRepository repo) => _instance = repo;

  /// 1. Kueri Transaksi per Rentang Tanggal (SYNC-05)
  ///
  /// Mengambil riwayat transaksi pengguna antara [startDate] dan [endDate].
  Future<List<TransactionModel>> getTransactions(
    String uid, {
    required DateTime startDate,
    required DateTime endDate,
    bool descending = false,
  }) async {
    return getTransactionsByDateRange(
      uid,
      startDate: startDate,
      endDate: endDate,
      descending: descending,
    );
  }

  /// Alias metode sesuai penamaan eksplisit task breakdown SYNC-05
  Future<List<TransactionModel>> getTransactionsByDateRange(
    String uid, {
    required DateTime startDate,
    required DateTime endDate,
    bool descending = false,
  }) async {
    if (uid.trim().isEmpty) return [];

    final normalizedStart = startDate.isBefore(endDate) ? startDate : endDate;
    final normalizedEnd = startDate.isBefore(endDate) ? endDate : startDate;

    final startTimestamp = Timestamp.fromDate(DateTime(
      normalizedStart.year,
      normalizedStart.month,
      normalizedStart.day,
      0,
      0,
      0,
    ));
    final endTimestamp = Timestamp.fromDate(DateTime(
      normalizedEnd.year,
      normalizedEnd.month,
      normalizedEnd.day,
      23,
      59,
      59,
      999,
    ));

    final snapshot = await _firestore
        .collection('users')
        .doc(uid)
        .collection('transactions')
        .where('date', isGreaterThanOrEqualTo: startTimestamp)
        .where('date', isLessThanOrEqualTo: endTimestamp)
        .orderBy('date', descending: descending)
        .get();

    return snapshot.docs
        .map((doc) => TransactionModel.fromFirestore(doc))
        .toList();
  }

  /// Menghasilkan byte CSV transaksi tanpa memicu dialog bagikan
  Future<Uint8List> exportCsvBytes({
    required String uid,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final transactions = await getTransactionsByDateRange(
      uid,
      startDate: startDate,
      endDate: endDate,
      descending: false,
    );
    return _csvService.generateCsvBytes(transactions);
  }

  /// Menghasilkan byte PDF transaksi tanpa memicu dialog bagikan
  Future<Uint8List> exportPdfBytes({
    required String uid,
    required DateTime startDate,
    required DateTime endDate,
    String? userName,
    String? periodLabel,
    String? logoSvg,
  }) async {
    final transactions = await getTransactionsByDateRange(
      uid,
      startDate: startDate,
      endDate: endDate,
      descending: false,
    );
    return await _pdfService.generatePdfBytes(
      transactions: transactions,
      userName: userName,
      periodLabel: periodLabel,
      startDate: startDate,
      endDate: endDate,
      logoSvg: logoSvg,
    );
  }

  /// 2. Ekspor ke Berkas CSV dan Buka Share Sheet (SYNC-02 & SYNC-04)
  Future<File> exportCsvAndShare({
    required String uid,
    required DateTime startDate,
    required DateTime endDate,
    required String fileName,
    Rect? sharePositionOrigin,
  }) async {
    final bytes = await exportCsvBytes(
      uid: uid,
      startDate: startDate,
      endDate: endDate,
    );

    return await _shareService.saveAndShareFile(
      fileName: fileName,
      bytes: bytes,
      mimeType: 'text/csv',
      subject: 'Ekspor Data Keuangan TrackFinance',
      text: 'Berikut berkas riwayat transaksi TrackFinance Anda.',
      sharePositionOrigin: sharePositionOrigin,
    );
  }

  /// 3. Ekspor ke Berkas PDF dan Buka Share Sheet (SYNC-03 & SYNC-04)
  Future<File> exportPdfAndShare({
    required String uid,
    required DateTime startDate,
    required DateTime endDate,
    required String fileName,
    String? userName,
    String? periodLabel,
    String? logoSvg,
    Rect? sharePositionOrigin,
  }) async {
    final bytes = await exportPdfBytes(
      uid: uid,
      startDate: startDate,
      endDate: endDate,
      userName: userName,
      periodLabel: periodLabel,
      logoSvg: logoSvg,
    );

    return await _shareService.saveAndShareFile(
      fileName: fileName,
      bytes: bytes,
      mimeType: 'application/pdf',
      subject: 'Laporan Riwayat Transaksi TrackFinance',
      text: 'Berikut berkas dokumen PDF riwayat transaksi TrackFinance Anda.',
      sharePositionOrigin: sharePositionOrigin,
    );
  }

  /// 4. Ekspor Berkas Dinamis Berdasarkan Format ('CSV' atau 'PDF')
  Future<File> exportAndShare({
    required String uid,
    required DateTime startDate,
    required DateTime endDate,
    required String format,
    required String fileName,
    String? userName,
    String? periodLabel,
    String? logoSvg,
    Rect? sharePositionOrigin,
  }) async {
    if (format.toUpperCase() == 'CSV') {
      return await exportCsvAndShare(
        uid: uid,
        startDate: startDate,
        endDate: endDate,
        fileName: fileName,
        sharePositionOrigin: sharePositionOrigin,
      );
    } else {
      return await exportPdfAndShare(
        uid: uid,
        startDate: startDate,
        endDate: endDate,
        fileName: fileName,
        userName: userName,
        periodLabel: periodLabel,
        logoSvg: logoSvg,
        sharePositionOrigin: sharePositionOrigin,
      );
    }
  }
}
