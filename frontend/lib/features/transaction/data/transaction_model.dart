import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../dashboard/data/dashboard_transaction_model.dart';

/// Model DTO untuk entri transaksi Cloud Firestore pada path:
/// `users/{uid}/transactions/{id}`
class TransactionModel {
  final String id;
  final String type; // 'expense' atau 'income'
  final int amount; // Bilangan bulat positif dalam Rupiah
  final String categoryId;
  final String categoryName;
  final int categoryIconCode;
  final String notes;
  final String timeStr; // Contoh: "14.30"
  final DateTime date;
  final String dateKey; // Format: YYYY-MM-DD
  final String monthKey; // Format: YYYY-MM
  final int year;
  final int month; // 0-based: 0 = Jan, 9 = Okt
  final int day;
  final DateTime? createdAt;
  final DateTime? updatedAt;

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
    this.createdAt,
    this.updatedAt,
  });

  /// Mengembalikan true jika transaksi adalah pengeluaran
  bool get isExpense => type == 'expense';

  /// Mengembalikan true jika transaksi adalah pemasukan
  bool get isIncome => type == 'income';

  /// Salin objek dengan beberapa atribut diubah
  TransactionModel copyWith({
    String? id,
    String? type,
    int? amount,
    String? categoryId,
    String? categoryName,
    int? categoryIconCode,
    String? notes,
    String? timeStr,
    DateTime? date,
    String? dateKey,
    String? monthKey,
    int? year,
    int? month,
    int? day,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryIconCode: categoryIconCode ?? this.categoryIconCode,
      notes: notes ?? this.notes,
      timeStr: timeStr ?? this.timeStr,
      date: date ?? this.date,
      dateKey: dateKey ?? this.dateKey,
      monthKey: monthKey ?? this.monthKey,
      year: year ?? this.year,
      month: month ?? this.month,
      day: day ?? this.day,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Deserialisasi dari dokumen Firestore
  factory TransactionModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return TransactionModel.fromMap(doc.data() ?? {}, id: doc.id);
  }

  /// Deserialisasi dari Map umum
  factory TransactionModel.fromMap(Map<String, dynamic> data, {String? id}) {
    final timestamp = data['date'];
    final DateTime dt;
    if (timestamp is Timestamp) {
      dt = timestamp.toDate();
    } else if (timestamp is DateTime) {
      dt = timestamp;
    } else if (timestamp is String) {
      dt = DateTime.tryParse(timestamp) ?? DateTime.now();
    } else {
      dt = DateTime.now();
    }

    final createdAtRaw = data['createdAt'];
    DateTime? createdAt;
    if (createdAtRaw is Timestamp) {
      createdAt = createdAtRaw.toDate();
    } else if (createdAtRaw is DateTime) {
      createdAt = createdAtRaw;
    } else if (createdAtRaw is String) {
      createdAt = DateTime.tryParse(createdAtRaw);
    }

    final updatedAtRaw = data['updatedAt'];
    DateTime? updatedAt;
    if (updatedAtRaw is Timestamp) {
      updatedAt = updatedAtRaw.toDate();
    } else if (updatedAtRaw is DateTime) {
      updatedAt = updatedAtRaw;
    } else if (updatedAtRaw is String) {
      updatedAt = DateTime.tryParse(updatedAtRaw);
    }

    final year = data['year'] as int? ?? dt.year;
    final month = data['month'] as int? ?? (dt.month - 1);
    final day = data['day'] as int? ?? dt.day;

    final monthKey = data['monthKey'] as String? ??
        '$year-${(month + 1).toString().padLeft(2, '0')}';
    final dateKey = data['dateKey'] as String? ??
        '$monthKey-${day.toString().padLeft(2, '0')}';

    return TransactionModel(
      id: id ?? (data['id'] as String? ?? ''),
      type: data['type'] as String? ?? 'expense',
      amount: (data['amount'] as num? ?? 0).toInt().abs(),
      categoryId: data['categoryId'] as String? ?? '',
      categoryName: data['categoryName'] as String? ?? '',
      categoryIconCode: data['categoryIconCode'] as int? ?? Icons.receipt_long_rounded.codePoint,
      notes: data['notes'] as String? ?? '',
      timeStr: data['timeStr'] as String? ?? '',
      date: dt,
      dateKey: dateKey,
      monthKey: monthKey,
      year: year,
      month: month,
      day: day,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Serialisasi ke format payload Firestore (WriteBatch / DocumentReference)
  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
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

  /// Serialisasi ke Map umum (misalnya untuk local storage / export)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'categoryIconCode': categoryIconCode,
      'notes': notes,
      'timeStr': timeStr,
      'date': date.toIso8601String(),
      'dateKey': dateKey,
      'monthKey': monthKey,
      'year': year,
      'month': month,
      'day': day,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  /// Konversi ke [DashboardTransaction] domain model untuk kompatibilitas tampilan UI
  DashboardTransaction toDashboardTransaction() {
    final metaStr = notes.isNotEmpty ? '$timeStr · $notes' : timeStr;
    final monthName = (month >= 0 && month < DashboardDataStore.monthsName.length)
        ? DashboardDataStore.monthsName[month]
        : '';
    final dateStr = '$day $monthName $year';

    return DashboardTransaction(
      id: id,
      dateStr: dateStr,
      dateKey: dateKey,
      year: year,
      month: month,
      day: day,
      category: categoryName,
      meta: metaStr,
      amount: isExpense ? -amount.abs() : amount.abs(),
      type: isExpense ? TransactionType.expense : TransactionType.income,
      // ignore: non_const_argument_for_const_parameter
      icon: IconData(categoryIconCode, fontFamily: 'MaterialIcons'),
    );
  }

  /// Konversi dari [DashboardTransaction] ke [TransactionModel]
  factory TransactionModel.fromDashboardTransaction(
    DashboardTransaction dt, {
    String categoryId = '',
    String notes = '',
    String? timeStr,
    DateTime? date,
  }) {
    final isExpense = dt.type == TransactionType.expense;
    final effectiveTimeStr = timeStr ??
        (dt.meta.contains('·') ? dt.meta.split('·').first.trim() : dt.meta);
    final effectiveNotes = notes.isNotEmpty
        ? notes
        : (dt.meta.contains('·')
            ? dt.meta.split('·').sublist(1).join('·').trim()
            : (dt.meta == effectiveTimeStr ? '' : dt.meta));
    final effectiveDate = date ?? DateTime(dt.year, dt.month + 1, dt.day);
    final monthKey = '${dt.year}-${(dt.month + 1).toString().padLeft(2, '0')}';
    final dateKey = dt.dateKey.isNotEmpty
        ? dt.dateKey
        : '$monthKey-${dt.day.toString().padLeft(2, '0')}';

    return TransactionModel(
      id: dt.id,
      type: isExpense ? 'expense' : 'income',
      amount: dt.amount.abs(),
      categoryId: categoryId,
      categoryName: dt.category,
      categoryIconCode: dt.icon.codePoint,
      notes: effectiveNotes,
      timeStr: effectiveTimeStr,
      date: effectiveDate,
      dateKey: dateKey,
      monthKey: monthKey,
      year: dt.year,
      month: dt.month,
      day: dt.day,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          amount == other.amount &&
          categoryId == other.categoryId &&
          categoryName == other.categoryName &&
          categoryIconCode == other.categoryIconCode &&
          notes == other.notes &&
          timeStr == other.timeStr &&
          dateKey == other.dateKey &&
          monthKey == other.monthKey &&
          year == other.year &&
          month == other.month &&
          day == other.day;

  @override
  int get hashCode =>
      id.hashCode ^
      type.hashCode ^
      amount.hashCode ^
      categoryId.hashCode ^
      categoryName.hashCode ^
      categoryIconCode.hashCode ^
      notes.hashCode ^
      timeStr.hashCode ^
      dateKey.hashCode ^
      monthKey.hashCode ^
      year.hashCode ^
      month.hashCode ^
      day.hashCode;

  @override
  String toString() {
    return 'TransactionModel(id: $id, type: $type, amount: $amount, category: $categoryName, monthKey: $monthKey)';
  }
}
