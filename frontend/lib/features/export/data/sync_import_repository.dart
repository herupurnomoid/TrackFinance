import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../category/data/category_model.dart';
import '../../transaction/data/transaction_model.dart';
import 'csv_import_parser.dart';
import 'import_data_model.dart';

/// Repository untuk memvalidasi dan mengimpor berkas transaksi CSV (SYNC-08 s/d SYNC-14).
class SyncImportRepository {
  final FirebaseFirestore _firestore;
  final CsvImportParser _parser;

  SyncImportRepository({
    FirebaseFirestore? firestore,
    CsvImportParser? parser,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _parser = parser ?? const CsvImportParser();

  static SyncImportRepository? _instance;

  /// Singleton instance default untuk [SyncImportRepository]
  static SyncImportRepository get instance => _instance ??= SyncImportRepository();

  /// Setter untuk unit testing / dependency injection
  @visibleForTesting
  static set instance(SyncImportRepository repo) => _instance = repo;

  /// Mengurai dan memvalidasi berkas CSV ([fileBytes]) terhadap kategori dan riwayat transaksi pengguna.
  Future<ImportFileModel> parseAndValidateCsv(
    Uint8List fileBytes,
    String fileName, {
    String? uid,
    List<CategoryItem>? categories,
  }) async {
    final csvString = utf8.decode(fileBytes);

    List<CategoryItem> resolvedCategories = categories ?? [];
    List<TransactionModel> existingTransactions = [];

    // Jika UID tersedia, ambil kategori kustom pengguna dan riwayat transaksi untuk deteksi duplikasi
    if (uid != null && uid.trim().isNotEmpty) {
      if (resolvedCategories.isEmpty) {
        try {
          final catSnap = await _firestore
              .collection('users')
              .doc(uid)
              .collection('categories')
              .get();

          if (catSnap.docs.isNotEmpty) {
            resolvedCategories = catSnap.docs
                .map((d) => CategoryItem.fromMap(d.data(), documentId: d.id))
                .toList();
          }
        } catch (_) {
          // Fallback ke default categories jika offline
        }
      }

      try {
        final txSnap = await _firestore
            .collection('users')
            .doc(uid)
            .collection('transactions')
            .get();

        existingTransactions = txSnap.docs
            .map((d) => TransactionModel.fromFirestore(d))
            .toList();
      } catch (_) {
        // Abaikan jika offline / belum ada transaksi
      }
    }

    if (resolvedCategories.isEmpty) {
      resolvedCategories = [
        ...DefaultCategories.defaultExpenseCategories,
        ...DefaultCategories.defaultIncomeCategories,
      ];
    }

    return _parser.parse(
      csvString: csvString,
      fileName: fileName,
      categories: resolvedCategories,
      existingTransactions: existingTransactions,
    );
  }

  /// 2. Eksekusi Impor Batch Massal (Chunked Batch Writes per 200 Transaksi - SYNC-13)
  ///
  /// Secara atomik per batch (maksimal [chunkSize] dokumen per operasi):
  /// 1. Menyimpan dokumen transaksi di `users/{uid}/transactions/{tx.id}`.
  /// 2. Mengakumulasikan ringkasan bulanan di `users/{uid}/monthly_summaries/{monthKey}`.
  /// 3. Memperbarui `totalBalance` pada dokumen profil `users/{uid}`.
  Future<int> commitImport(
    String uid,
    List<TransactionModel> transactions, {
    int chunkSize = 200,
  }) async {
    if (uid.trim().isEmpty) {
      throw ArgumentError('UID tidak boleh kosong');
    }
    if (transactions.isEmpty) {
      return 0;
    }

    int totalCommitted = 0;

    for (var i = 0; i < transactions.length; i += chunkSize) {
      final end = (i + chunkSize < transactions.length) ? i + chunkSize : transactions.length;
      final chunk = transactions.sublist(i, end);

      final batch = _firestore.batch();
      int totalBalanceDelta = 0;

      // Map untuk mengakumulasi ringkasan bulanan per monthKey
      final Map<String, ({
        int income,
        int expense,
        int count,
        int year,
        int month,
        Map<String, ({String name, int total, int count})> categories,
      })> monthlyDeltas = {};

      for (final tx in chunk) {
        final txRef = _firestore
            .collection('users')
            .doc(uid)
            .collection('transactions')
            .doc(tx.id);

        batch.set(txRef, {
          ...tx.toFirestore(),
          'id': tx.id,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        final isExp = tx.isExpense;
        final signedAmount = isExp ? -tx.amount : tx.amount;
        totalBalanceDelta += signedAmount;

        final current = monthlyDeltas[tx.monthKey] ??
            (
              income: 0,
              expense: 0,
              count: 0,
              year: tx.year,
              month: tx.month,
              categories: <String, ({String name, int total, int count})>{},
            );

        final catMap = Map<String, ({String name, int total, int count})>.from(current.categories);
        if (tx.categoryId.isNotEmpty) {
          final currentCat = catMap[tx.categoryId] ?? (name: tx.categoryName, total: 0, count: 0);
          catMap[tx.categoryId] = (
            name: tx.categoryName,
            total: currentCat.total + tx.amount,
            count: currentCat.count + 1,
          );
        }

        monthlyDeltas[tx.monthKey] = (
          income: current.income + (!isExp ? tx.amount : 0),
          expense: current.expense + (isExp ? tx.amount : 0),
          count: current.count + 1,
          year: tx.year,
          month: tx.month,
          categories: catMap,
        );
      }

      // Terapkan agregasi ringkasan bulanan (monthly_summaries)
      for (final entry in monthlyDeltas.entries) {
        final summaryRef = _firestore
            .collection('users')
            .doc(uid)
            .collection('monthly_summaries')
            .doc(entry.key);

        final summaryUpdates = <String, dynamic>{
          'monthKey': entry.key,
          'year': entry.value.year,
          'month': entry.value.month,
          'totalIncome': FieldValue.increment(entry.value.income),
          'totalExpense': FieldValue.increment(entry.value.expense),
          'netCashflow': FieldValue.increment(entry.value.income - entry.value.expense),
          'transactionCount': FieldValue.increment(entry.value.count),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        for (final catEntry in entry.value.categories.entries) {
          summaryUpdates['categoryBreakdown.${catEntry.key}.name'] = catEntry.value.name;
          summaryUpdates['categoryBreakdown.${catEntry.key}.total'] = FieldValue.increment(catEntry.value.total);
          summaryUpdates['categoryBreakdown.${catEntry.key}.count'] = FieldValue.increment(catEntry.value.count);
        }

        batch.set(summaryRef, summaryUpdates, SetOptions(merge: true));
      }

      // Terapkan penambahan saldo pengguna (totalBalance)
      final userRef = _firestore.collection('users').doc(uid);
      batch.set(userRef, {
        'totalBalance': FieldValue.increment(totalBalanceDelta),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      await batch.commit();
      totalCommitted += chunk.length;
    }

    return totalCommitted;
  }
}
