# 🛠️ Panduan Implementasi Teknis: Fitur Transaksi (Transactions)

Dokumen ini memandu langkah-demi-langkah implementasi kode Flutter untuk mengintegrasikan **Fitur Pencatatan Pemasukan dan Pengeluaran** dengan **Cloud Firestore SDK**.

---

## 🎯 Target Implementasi
1. Membuat model data serialisasi Firestore: `TransactionModel` dan `MonthlySummaryModel`.
2. Membuat service layer `TransactionRepository` dengan operasi atomik `WriteBatch` (Sinkronisasi transaksi, ringkasan bulanan, dan saldo akun).
3. Mengintegrasikan form input [`AddTransactionScreen`](file:///Users/heru/Development/TrackFinance/frontend/lib/features/transaction/presentation/screens/add_transaction_screen.dart) untuk Mode Tambah, Mode Edit, dan Mode Hapus.
4. Menghubungkan antarmuka `DashboardScreen` dengan data realtime dari Firestore.

---

## 📂 Langkah 1: Buat Model `TransactionModel`

Buat file baru di [frontend/lib/features/transaction/data/transaction_model.dart](file:///Users/heru/Development/TrackFinance/frontend/lib/features/transaction/data/transaction_model.dart):

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../dashboard/data/dashboard_transaction_model.dart';

class TransactionModel {
  final String id;
  final String type; // 'expense' atau 'income'
  final int amount; // Bilangan bulat positif dalam Rupiah
  final String categoryId;
  final String categoryName;
  final int categoryIconCode;
  final String notes;
  final String timeStr;
  final DateTime date;
  final String dateKey; // YYYY-MM-DD
  final String monthKey; // YYYY-MM
  final int year;
  final int month; // 0-based
  final int day;

  const TransactionModel({
    required this.id,
    required this.type,
    required this.amount,
    required this.categoryId,
    required this.categoryName,
    required this.categoryIconCode,
    required this.notes,
    required this.timeStr,
    required this.date,
    required this.dateKey,
    required this.monthKey,
    required this.year,
    required this.month,
    required this.day,
  });

  bool get isExpense => type == 'expense';

  // Deserialisasi dari dokumen Firestore
  factory TransactionModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final timestamp = data['date'] as Timestamp? ?? Timestamp.now();
    final dt = timestamp.toDate();

    return TransactionModel(
      id: doc.id,
      type: data['type'] as String? ?? 'expense',
      amount: (data['amount'] as num? ?? 0).toInt(),
      categoryId: data['categoryId'] as String? ?? '',
      categoryName: data['categoryName'] as String? ?? '',
      categoryIconCode: data['categoryIconCode'] as int? ?? Icons.receipt_long_rounded.codePoint,
      notes: data['notes'] as String? ?? '',
      timeStr: data['timeStr'] as String? ?? '',
      date: dt,
      dateKey: data['dateKey'] as String? ?? '',
      monthKey: data['monthKey'] as String? ?? '',
      year: data['year'] as int? ?? dt.year,
      month: data['month'] as int? ?? (dt.month - 1),
      day: data['day'] as int? ?? dt.day,
    );
  }

  // Serialisasi ke format dokumen Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'amount': amount,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'categoryIconCode': categoryIconCode,
      'notes': notes,
      'timeStr': timeStr,
      'date': Timestamp.fromDate(date),
      'dateKey': dateKey,
      'monthKey': monthKey,
      'year': year,
      'month': month,
      'day': day,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Konversi ke DashboardTransaction untuk kompatibilitas UI yang sudah ada
  DashboardTransaction toDashboardTransaction() {
    final metaStr = notes.isNotEmpty ? '$timeStr · $notes' : timeStr;
    final dateStr = '$day ${DashboardDataStore.monthsName[month]} $year';

    return DashboardTransaction(
      id: id,
      dateStr: dateStr,
      dateKey: dateKey,
      year: year,
      month: month,
      day: day,
      category: categoryName,
      meta: metaStr,
      amount: isExpense ? -amount : amount,
      type: isExpense ? TransactionType.expense : TransactionType.income,
      icon: IconData(categoryIconCode, fontFamily: 'MaterialIcons'),
    );
  }
}
```

---

## 📂 Langkah 2: Buat Model `MonthlySummaryModel`

Buat file baru di [frontend/lib/features/transaction/data/monthly_summary_model.dart](file:///Users/heru/Development/TrackFinance/frontend/lib/features/transaction/data/monthly_summary_model.dart):

```dart
import 'package:cloud_firestore/cloud_firestore.dart';

class MonthlySummaryModel {
  final String monthKey;
  final int year;
  final int month;
  final int totalIncome;
  final int totalExpense;
  final int netCashflow;
  final int transactionCount;
  final Map<String, dynamic> categoryBreakdown;

  const MonthlySummaryModel({
    required this.monthKey,
    required this.year,
    required this.month,
    required this.totalIncome,
    required this.totalExpense,
    required this.netCashflow,
    required this.transactionCount,
    this.categoryBreakdown = const {},
  });

  factory MonthlySummaryModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return MonthlySummaryModel(
      monthKey: doc.id,
      year: data['year'] as int? ?? 0,
      month: data['month'] as int? ?? 0,
      totalIncome: (data['totalIncome'] as num? ?? 0).toInt(),
      totalExpense: (data['totalExpense'] as num? ?? 0).toInt(),
      netCashflow: (data['netCashflow'] as num? ?? 0).toInt(),
      transactionCount: (data['transactionCount'] as num? ?? 0).toInt(),
      categoryBreakdown: data['categoryBreakdown'] as Map<String, dynamic>? ?? {},
    );
  }
}
```

---

## 📂 Langkah 3: Implementasi `TransactionRepository`

Buat file di [frontend/lib/features/transaction/data/transaction_repository.dart](file:///Users/heru/Development/TrackFinance/frontend/lib/features/transaction/data/transaction_repository.dart):

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'transaction_model.dart';
import 'monthly_summary_model.dart';

class TransactionRepository {
  final FirebaseFirestore _firestore;

  TransactionRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  static final TransactionRepository instance = TransactionRepository();

  DocumentReference<Map<String, dynamic>> _userRef(String uid) {
    return _firestore.collection('users').doc(uid);
  }

  CollectionReference<Map<String, dynamic>> _txCol(String uid) {
    return _userRef(uid).collection('transactions');
  }

  DocumentReference<Map<String, dynamic>> _summaryRef(String uid, String monthKey) {
    return _userRef(uid).collection('monthly_summaries').doc(monthKey);
  }

  /// 1. Tambah Transaksi Atomik
  Future<void> addTransaction(String uid, TransactionModel tx) async {
    final batch = _firestore.batch();
    final txDoc = _txCol(uid).doc(tx.id);
    final summaryDoc = _summaryRef(uid, tx.monthKey);
    final userDoc = _userRef(uid);

    final isExp = tx.isExpense;
    final signedAmount = isExp ? -tx.amount : tx.amount;

    // A. Tulis dokumen transaksi
    batch.set(txDoc, {
      ...tx.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    // B. Perbarui ringkasan bulanan
    batch.set(summaryDoc, {
      'monthKey': tx.monthKey,
      'year': tx.year,
      'month': tx.month,
      'totalExpense': FieldValue.increment(isExp ? tx.amount : 0),
      'totalIncome': FieldValue.increment(!isExp ? tx.amount : 0),
      'netCashflow': FieldValue.increment(signedAmount),
      'transactionCount': FieldValue.increment(1),
      'categoryBreakdown.${tx.categoryId}.name': tx.categoryName,
      'categoryBreakdown.${tx.categoryId}.total': FieldValue.increment(tx.amount),
      'categoryBreakdown.${tx.categoryId}.count': FieldValue.increment(1),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // C. Perbarui total saldo pengguna
    batch.update(userDoc, {
      'totalBalance': FieldValue.increment(signedAmount),
    });

    await batch.commit();
  }

  /// 2. Hapus Transaksi Atomik
  Future<void> deleteTransaction(String uid, TransactionModel tx) async {
    final batch = _firestore.batch();
    final txDoc = _txCol(uid).doc(tx.id);
    final summaryDoc = _summaryRef(uid, tx.monthKey);
    final userDoc = _userRef(uid);

    final isExp = tx.isExpense;
    final reverseAmount = isExp ? tx.amount : -tx.amount;

    // A. Hapus dokumen transaksi
    batch.delete(txDoc);

    // B. Kurangkan ringkasan bulanan
    batch.update(summaryDoc, {
      'totalExpense': FieldValue.increment(isExp ? -tx.amount : 0),
      'totalIncome': FieldValue.increment(!isExp ? -tx.amount : 0),
      'netCashflow': FieldValue.increment(reverseAmount),
      'transactionCount': FieldValue.increment(-1),
      'categoryBreakdown.${tx.categoryId}.total': FieldValue.increment(-tx.amount),
      'categoryBreakdown.${tx.categoryId}.count': FieldValue.increment(-1),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // C. Kembalikan saldo pengguna
    batch.update(userDoc, {
      'totalBalance': FieldValue.increment(reverseAmount),
    });

    await batch.commit();
  }

  /// 3. Stream 5 Transaksi Terakhir (Dashboard)
  Stream<List<TransactionModel>> watchRecentTransactions(String uid, {int limit = 5}) {
    return _txCol(uid)
        .orderBy('date', descending: true)
        .limit(limit)
        .snapshots()
        .map((s) => s.docs.map((d) => TransactionModel.fromFirestore(d)).toList());
  }

  /// 4. Stream Ringkasan Bulan Ini (Dashboard)
  Stream<MonthlySummaryModel?> watchMonthlySummary(String uid, String monthKey) {
    return _summaryRef(uid, monthKey).snapshots().map((snapshot) {
      if (!snapshot.exists) return null;
      return MonthlySummaryModel.fromFirestore(snapshot);
    });
  }

  /// 5. Stream Riwayat Transaksi per Bulan
  Stream<List<TransactionModel>> watchTransactionsByMonth(String uid, String monthKey) {
    return _txCol(uid)
        .where('monthKey', isEqualTo: monthKey)
        .orderBy('date', descending: true)
        .snapshots()
        .map((s) => s.docs.map((d) => TransactionModel.fromFirestore(d)).toList());
  }
}
```

---

## 📂 Langkah 4: Integrasi ke `AddTransactionScreen`

Di file [frontend/lib/features/transaction/presentation/screens/add_transaction_screen.dart](file:///Users/heru/Development/TrackFinance/frontend/lib/features/transaction/presentation/screens/add_transaction_screen.dart):

Ganti logika simulasi di `_handleSaveTransaction` dengan pemanggilan ke repository:

```dart
Future<void> _handleSaveTransaction() async {
  final uid = widget.user?.uid;
  if (uid == null) return;

  final amountVal = _parseAmount(_amountController.text);
  if (amountVal <= 0) return;

  setState(() => _isSaving = true);

  final catOption = _getCategoryOption(_selectedCategoryId, _isExpense);
  final timeStr = '${_selectedTime.hour.toString().padLeft(2, '0')}.${_selectedTime.minute.toString().padLeft(2, '0')}';
  final note = _noteController.text.trim();
  final monthKey = '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}';
  final dateKey = '$monthKey-${_selectedDate.day.toString().padLeft(2, '0')}';

  final txModel = TransactionModel(
    id: widget.transaction?.id ?? 'tx-${DateTime.now().millisecondsSinceEpoch}',
    type: _isExpense ? 'expense' : 'income',
    amount: amountVal,
    categoryId: _selectedCategoryId,
    categoryName: catOption.name,
    categoryIconCode: catOption.icon.codePoint,
    notes: note,
    timeStr: timeStr,
    date: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _selectedTime.hour, _selectedTime.minute),
    dateKey: dateKey,
    monthKey: monthKey,
    year: _selectedDate.year,
    month: _selectedDate.month - 1,
    day: _selectedDate.day,
  );

  if (isEditMode) {
    // Mode Edit Transaksi
    // await TransactionRepository.instance.updateTransaction(uid, oldTx, txModel);
  } else {
    // Mode Tambah Transaksi
    await TransactionRepository.instance.addTransaction(uid, txModel);
  }

  setState(() {
    _isSaving = false;
    _isSaved = true;
  });

  Navigator.of(context).pop(TransactionActionResult.updated(txModel.id, txModel.toDashboardTransaction()));
}
```

---

## 🧪 Langkah 5: Pengujian & Validasi

Jalankan test suite untuk memastikan serialisasi model dan batch transactions tidak mengalami regresi:
```bash
cd frontend
flutter test
```
Pastikan penambahan transaksi melalui tombol FAB (+) langsung terakumulasi pada kartu ringkasan Dashboard dan muncul di list "Transaksi Terakhir".
