import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'monthly_summary_model.dart';
import 'transaction_model.dart';

/// Repository untuk mengelola operasi data subkoleksi Cloud Firestore `users/{uid}/transactions`
/// dan subkoleksi agregasi `users/{uid}/monthly_summaries` secara atomik (WriteBatch).
class TransactionRepository {
  final FirebaseFirestore? _customFirestore;

  TransactionRepository({FirebaseFirestore? firestore})
      : _customFirestore = firestore;

  FirebaseFirestore get _firestore =>
      _customFirestore ?? FirebaseFirestore.instance;

  static TransactionRepository? _instance;

  /// Singleton instance default untuk [TransactionRepository]
  static TransactionRepository get instance =>
      _instance ??= TransactionRepository();

  /// Setter untuk pengujian unit / dependency injection
  @visibleForTesting
  static set instance(TransactionRepository repo) => _instance = repo;

  /// Referensi dokumen root pengguna `users/{uid}`
  DocumentReference<Map<String, dynamic>> _userRef(String uid) {
    return _firestore.collection('users').doc(uid);
  }

  /// Referensi subkoleksi transaksi `users/{uid}/transactions`
  CollectionReference<Map<String, dynamic>> _txCol(String uid) {
    return _userRef(uid).collection('transactions');
  }

  /// Referensi dokumen ringkasan bulanan `users/{uid}/monthly_summaries/{monthKey}`
  DocumentReference<Map<String, dynamic>> _summaryRef(
      String uid, String monthKey) {
    return _userRef(uid).collection('monthly_summaries').doc(monthKey);
  }

  // ===========================================================================
  // ⚡ OPERASI ATOMIK WRITE BATCH (TX-03, TX-04, TX-05)
  // ===========================================================================

  /// **TX-03: Atomic Batch - Tambah Transaksi Baru**
  ///
  /// Secara serentak dan atomik melakukan:
  /// 1. Menyimpan dokumen transaksi di `users/{uid}/transactions/{tx.id}`
  /// 2. Mengakumulasikan ringkasan bulanan di `users/{uid}/monthly_summaries/{tx.monthKey}`
  /// 3. Memperbarui total saldo pengguna `totalBalance` di `users/{uid}`
  Future<void> addTransaction(String uid, TransactionModel tx) async {
    if (uid.trim().isEmpty) {
      throw ArgumentError('UID tidak boleh kosong');
    }
    if (tx.amount <= 0) {
      throw ArgumentError('Nominal transaksi harus lebih besar dari 0');
    }

    final batch = _firestore.batch();
    final txDoc = _txCol(uid).doc(tx.id);
    final summaryDoc = _summaryRef(uid, tx.monthKey);
    final userDoc = _userRef(uid);

    final isExp = tx.isExpense;
    final signedAmount = isExp ? -tx.amount : tx.amount;

    // A. Tulis dokumen transaksi
    batch.set(txDoc, {
      ...tx.toFirestore(),
      'id': tx.id,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // B. Perbarui ringkasan arus kas bulanan
    final Map<String, dynamic> summaryUpdates = {
      'monthKey': tx.monthKey,
      'year': tx.year,
      'month': tx.month,
      'totalExpense': FieldValue.increment(isExp ? tx.amount : 0),
      'totalIncome': FieldValue.increment(!isExp ? tx.amount : 0),
      'netCashflow': FieldValue.increment(signedAmount),
      'transactionCount': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (tx.categoryId.isNotEmpty) {
      summaryUpdates['categoryBreakdown.${tx.categoryId}.name'] =
          tx.categoryName;
      summaryUpdates['categoryBreakdown.${tx.categoryId}.total'] =
          FieldValue.increment(tx.amount);
      summaryUpdates['categoryBreakdown.${tx.categoryId}.count'] =
          FieldValue.increment(1);
    }

    batch.set(summaryDoc, summaryUpdates, SetOptions(merge: true));

    // C. Perbarui total saldo pengguna
    batch.set(
      userDoc,
      {
        'totalBalance': FieldValue.increment(signedAmount),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  /// **TX-04: Atomic Batch - Edit / Update Transaksi**
  ///
  /// Menghitung selisih (delta) nominal antara [oldTx] dan [newTx],
  /// kemudian secara atomik mengoreksi dokumen transaksi, saldo user,
  /// dan ringkasan bulanan (baik pada bulan yang sama maupun lintas bulan).
  Future<void> updateTransaction(
    String uid,
    TransactionModel oldTx,
    TransactionModel newTx,
  ) async {
    if (uid.trim().isEmpty) {
      throw ArgumentError('UID tidak boleh kosong');
    }
    if (newTx.amount <= 0) {
      throw ArgumentError('Nominal transaksi harus lebih besar dari 0');
    }

    final batch = _firestore.batch();
    final txDoc = _txCol(uid).doc(newTx.id);

    // A. Perbarui dokumen transaksi
    batch.set(
      txDoc,
      {
        ...newTx.toFirestore(),
        'id': newTx.id,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    // B. Koreksi saldo total pengguna
    final oldSignedAmount = oldTx.isExpense ? -oldTx.amount : oldTx.amount;
    final newSignedAmount = newTx.isExpense ? -newTx.amount : newTx.amount;
    final balanceDelta = newSignedAmount - oldSignedAmount;

    batch.set(
      _userRef(uid),
      {
        'totalBalance': FieldValue.increment(balanceDelta),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    // C. Koreksi Ringkasan Bulanan (Monthly Summary)
    if (oldTx.monthKey == newTx.monthKey) {
      // Kasus 1: Transaksi berada pada bulan yang sama
      final oldIncome = oldTx.isIncome ? oldTx.amount : 0;
      final newIncome = newTx.isIncome ? newTx.amount : 0;
      final incomeDelta = newIncome - oldIncome;

      final oldExpense = oldTx.isExpense ? oldTx.amount : 0;
      final newExpense = newTx.isExpense ? newTx.amount : 0;
      final expenseDelta = newExpense - oldExpense;

      final netDelta = newSignedAmount - oldSignedAmount;

      final Map<String, dynamic> summaryUpdates = {
        'monthKey': newTx.monthKey,
        'year': newTx.year,
        'month': newTx.month,
        'totalExpense': FieldValue.increment(expenseDelta),
        'totalIncome': FieldValue.increment(incomeDelta),
        'netCashflow': FieldValue.increment(netDelta),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (oldTx.categoryId == newTx.categoryId) {
        if (newTx.categoryId.isNotEmpty) {
          summaryUpdates['categoryBreakdown.${newTx.categoryId}.name'] =
              newTx.categoryName;
          summaryUpdates['categoryBreakdown.${newTx.categoryId}.total'] =
              FieldValue.increment(newTx.amount - oldTx.amount);
        }
      } else {
        // Kategori berubah: kurangi kategori lama, tambahkan ke kategori baru
        if (oldTx.categoryId.isNotEmpty) {
          summaryUpdates['categoryBreakdown.${oldTx.categoryId}.total'] =
              FieldValue.increment(-oldTx.amount);
          summaryUpdates['categoryBreakdown.${oldTx.categoryId}.count'] =
              FieldValue.increment(-1);
        }
        if (newTx.categoryId.isNotEmpty) {
          summaryUpdates['categoryBreakdown.${newTx.categoryId}.name'] =
              newTx.categoryName;
          summaryUpdates['categoryBreakdown.${newTx.categoryId}.total'] =
              FieldValue.increment(newTx.amount);
          summaryUpdates['categoryBreakdown.${newTx.categoryId}.count'] =
              FieldValue.increment(1);
        }
      }

      batch.set(
        _summaryRef(uid, newTx.monthKey),
        summaryUpdates,
        SetOptions(merge: true),
      );
    } else {
      // Kasus 2: Transaksi berpindah bulan (misal dari Oktober ke November)
      // 1. Kurangkan dari ringkasan bulan lama
      final Map<String, dynamic> oldSummaryUpdates = {
        'totalExpense': FieldValue.increment(oldTx.isExpense ? -oldTx.amount : 0),
        'totalIncome': FieldValue.increment(!oldTx.isExpense ? -oldTx.amount : 0),
        'netCashflow': FieldValue.increment(
            oldTx.isExpense ? oldTx.amount : -oldTx.amount),
        'transactionCount': FieldValue.increment(-1),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (oldTx.categoryId.isNotEmpty) {
        oldSummaryUpdates['categoryBreakdown.${oldTx.categoryId}.total'] =
            FieldValue.increment(-oldTx.amount);
        oldSummaryUpdates['categoryBreakdown.${oldTx.categoryId}.count'] =
            FieldValue.increment(-1);
      }
      batch.set(
        _summaryRef(uid, oldTx.monthKey),
        oldSummaryUpdates,
        SetOptions(merge: true),
      );

      // 2. Tambahkan ke ringkasan bulan baru
      final Map<String, dynamic> newSummaryUpdates = {
        'monthKey': newTx.monthKey,
        'year': newTx.year,
        'month': newTx.month,
        'totalExpense': FieldValue.increment(newTx.isExpense ? newTx.amount : 0),
        'totalIncome': FieldValue.increment(!newTx.isExpense ? newTx.amount : 0),
        'netCashflow': FieldValue.increment(newSignedAmount),
        'transactionCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (newTx.categoryId.isNotEmpty) {
        newSummaryUpdates['categoryBreakdown.${newTx.categoryId}.name'] =
            newTx.categoryName;
        newSummaryUpdates['categoryBreakdown.${newTx.categoryId}.total'] =
            FieldValue.increment(newTx.amount);
        newSummaryUpdates['categoryBreakdown.${newTx.categoryId}.count'] =
            FieldValue.increment(1);
      }
      batch.set(
        _summaryRef(uid, newTx.monthKey),
        newSummaryUpdates,
        SetOptions(merge: true),
      );
    }

    await batch.commit();
  }

  /// **TX-05: Atomic Batch - Hapus Transaksi**
  ///
  /// Secara serentak dan atomik melakukan:
  /// 1. Menghapus dokumen transaksi dari `users/{uid}/transactions/{tx.id}`
  /// 2. Mengurangkan nilai transaksi dari ringkasan bulanan
  /// 3. Mengembalikan/mengoreksi nilai saldo pengguna `totalBalance`
  Future<void> deleteTransaction(String uid, TransactionModel tx) async {
    if (uid.trim().isEmpty) {
      throw ArgumentError('UID tidak boleh kosong');
    }

    final batch = _firestore.batch();
    final txDoc = _txCol(uid).doc(tx.id);
    final summaryDoc = _summaryRef(uid, tx.monthKey);
    final userDoc = _userRef(uid);

    final isExp = tx.isExpense;
    final reverseAmount = isExp ? tx.amount : -tx.amount;

    // A. Hapus dokumen transaksi
    batch.delete(txDoc);

    // B. Kurangkan dari ringkasan bulanan
    final Map<String, dynamic> summaryUpdates = {
      'totalExpense': FieldValue.increment(isExp ? -tx.amount : 0),
      'totalIncome': FieldValue.increment(!isExp ? -tx.amount : 0),
      'netCashflow': FieldValue.increment(reverseAmount),
      'transactionCount': FieldValue.increment(-1),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (tx.categoryId.isNotEmpty) {
      summaryUpdates['categoryBreakdown.${tx.categoryId}.total'] =
          FieldValue.increment(-tx.amount);
      summaryUpdates['categoryBreakdown.${tx.categoryId}.count'] =
          FieldValue.increment(-1);
    }

    batch.set(summaryDoc, summaryUpdates, SetOptions(merge: true));

    // C. Kembalikan saldo pengguna
    batch.set(
      userDoc,
      {
        'totalBalance': FieldValue.increment(reverseAmount),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  // ===========================================================================
  // 🔍 KUERI & PEMBACAAN DATA SEKALI JALAN
  // ===========================================================================

  /// Mengambil dokumen transaksi spesifik berdasarkan ID
  Future<TransactionModel?> getTransaction(String uid, String txId) async {
    if (uid.trim().isEmpty || txId.trim().isEmpty) return null;
    final snap = await _txCol(uid).doc(txId).get();
    if (!snap.exists) return null;
    return TransactionModel.fromFirestore(snap);
  }

  /// Mengambil dokumen ringkasan bulanan berdasarkan monthKey (misal: "2026-10")
  Future<MonthlySummaryModel?> getMonthlySummary(
      String uid, String monthKey) async {
    if (uid.trim().isEmpty || monthKey.trim().isEmpty) return null;
    final snap = await _summaryRef(uid, monthKey).get();
    if (!snap.exists) return null;
    return MonthlySummaryModel.fromFirestore(snap);
  }

  /// Mengambil total saldo pengguna saat ini
  Future<int> getUserBalance(String uid) async {
    if (uid.trim().isEmpty) return 0;
    final snap = await _userRef(uid).get();
    if (!snap.exists) return 0;
    return (snap.data()?['totalBalance'] as num? ?? 0).toInt();
  }

  /// **SYNC-05: Kueri Transaksi Berdasarkan Rentang Tanggal**
  ///
  /// Mengambil daftar riwayat transaksi pengguna antara [startDate] dan [endDate].
  /// Rentang mencakup mulai pukul 00:00:00 [startDate] hingga 23:59:59.999 [endDate].
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

    final snapshot = await _txCol(uid)
        .where('date', isGreaterThanOrEqualTo: startTimestamp)
        .where('date', isLessThanOrEqualTo: endTimestamp)
        .orderBy('date', descending: descending)
        .get();

    return snapshot.docs
        .map((doc) => TransactionModel.fromFirestore(doc))
        .toList();
  }

  /// Stream total saldo pengguna saat ini secara realtime
  Stream<int> watchUserBalance(String uid) {
    if (uid.trim().isEmpty) return Stream.value(0);
    return _userRef(uid).snapshots().map((snapshot) {
      if (!snapshot.exists) return 0;
      return (snapshot.data()?['totalBalance'] as num? ?? 0).toInt();
    });
  }

  // ===========================================================================
  // 📡 REALTIME STREAM LISTENERS (TX-06, TX-07, TX-08)
  // ===========================================================================

  /// Stream daftar transaksi terbaru (default: 5 transaksi) terurut tanggal DESC
  Stream<List<TransactionModel>> watchRecentTransactions(
    String uid, {
    int limit = 5,
  }) {
    if (uid.trim().isEmpty) return Stream.value([]);
    return _txCol(uid)
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) =>
            s.docs.map((d) => TransactionModel.fromFirestore(d)).toList());
  }

  /// Stream ringkasan arus kas bulanan realtime
  Stream<MonthlySummaryModel?> watchMonthlySummary(
    String uid,
    String monthKey,
  ) {
    if (uid.trim().isEmpty || monthKey.trim().isEmpty) {
      return Stream.value(null);
    }
    return _summaryRef(uid, monthKey).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return MonthlySummaryModel.fromFirestore(snapshot);
    });
  }

  /// Stream seluruh transaksi pada bulan tertentu terurut tanggal DESC
  Stream<List<TransactionModel>> watchTransactionsByMonth(
    String uid,
    String monthKey,
  ) {
    if (uid.trim().isEmpty || monthKey.trim().isEmpty) {
      return Stream.value([]);
    }
    return _txCol(uid)
        .where('monthKey', isEqualTo: monthKey)
        .snapshots()
        .map((s) {
      final list =
          s.docs.map((d) => TransactionModel.fromFirestore(d)).toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }

  /// Stream seluruh transaksi pada tahun tertentu terurut tanggal DESC
  Stream<List<TransactionModel>> watchTransactionsByYear(
    String uid,
    int year,
  ) {
    if (uid.trim().isEmpty) {
      return Stream.value([]);
    }
    return _txCol(uid)
        .where('year', isEqualTo: year)
        .snapshots()
        .map((s) {
      final list =
          s.docs.map((d) => TransactionModel.fromFirestore(d)).toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }

  /// Stream seluruh riwayat transaksi pengguna terurut tanggal DESC
  Stream<List<TransactionModel>> watchAllTransactions(String uid) {
    if (uid.trim().isEmpty) {
      return Stream.value([]);
    }
    return _txCol(uid).snapshots().map((s) {
      final list =
          s.docs.map((d) => TransactionModel.fromFirestore(d)).toList();
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }
}
