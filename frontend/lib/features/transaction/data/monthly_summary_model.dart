import 'package:cloud_firestore/cloud_firestore.dart';

/// Item rincian agregasi pengeluaran atau pemasukan per kategori pada [MonthlySummaryModel]
class CategoryBreakdownItem {
  final String name;
  final int total;
  final int count;

  const CategoryBreakdownItem({
    required this.name,
    required this.total,
    required this.count,
  });

  factory CategoryBreakdownItem.fromMap(Map<String, dynamic> map) {
    return CategoryBreakdownItem(
      name: map['name'] as String? ?? '',
      total: (map['total'] as num? ?? 0).toInt(),
      count: (map['count'] as num? ?? 0).toInt(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'total': total,
      'count': count,
    };
  }

  CategoryBreakdownItem copyWith({
    String? name,
    int? total,
    int? count,
  }) {
    return CategoryBreakdownItem(
      name: name ?? this.name,
      total: total ?? this.total,
      count: count ?? this.count,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryBreakdownItem &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          total == other.total &&
          count == other.count;

  @override
  int get hashCode => name.hashCode ^ total.hashCode ^ count.hashCode;

  @override
  String toString() => 'CategoryBreakdownItem(name: $name, total: $total, count: $count)';
}

/// Model DTO untuk dokumen agregasi ringkasan arus kas bulanan pada path:
/// `users/{uid}/monthly_summaries/{monthKey}`
class MonthlySummaryModel {
  final String monthKey; // Format: YYYY-MM (misal: "2026-10")
  final int year;
  final int month; // 0-based: 0 = Jan, 9 = Okt
  final int totalIncome;
  final int totalExpense;
  final int netCashflow;
  final int transactionCount;
  final Map<String, dynamic> categoryBreakdown;
  final DateTime? updatedAt;

  const MonthlySummaryModel({
    required this.monthKey,
    required this.year,
    required this.month,
    required this.totalIncome,
    required this.totalExpense,
    required this.netCashflow,
    required this.transactionCount,
    this.categoryBreakdown = const {},
    this.updatedAt,
  });

  /// Mengonversi map mentah `categoryBreakdown` menjadi map bertipe `CategoryBreakdownItem`
  Map<String, CategoryBreakdownItem> get typedCategoryBreakdown {
    final result = <String, CategoryBreakdownItem>{};
    categoryBreakdown.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        result[key] = CategoryBreakdownItem.fromMap(value);
      } else if (value is Map) {
        result[key] = CategoryBreakdownItem.fromMap(Map<String, dynamic>.from(value));
      }
    });
    return result;
  }

  /// Deserialisasi dari dokumen Firestore
  factory MonthlySummaryModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    return MonthlySummaryModel.fromMap(doc.data() ?? {}, monthKey: doc.id);
  }

  /// Deserialisasi dari Map umum
  factory MonthlySummaryModel.fromMap(Map<String, dynamic> data, {String? monthKey}) {
    final docId = monthKey ?? (data['monthKey'] as String? ?? '');

    final updatedAtRaw = data['updatedAt'];
    DateTime? updatedAt;
    if (updatedAtRaw is Timestamp) {
      updatedAt = updatedAtRaw.toDate();
    } else if (updatedAtRaw is DateTime) {
      updatedAt = updatedAtRaw;
    } else if (updatedAtRaw is String) {
      updatedAt = DateTime.tryParse(updatedAtRaw);
    }

    final categoryBreakdown = <String, dynamic>{};
    if (data['categoryBreakdown'] is Map) {
      final rawMap = data['categoryBreakdown'] as Map;
      rawMap.forEach((k, v) {
        categoryBreakdown[k.toString()] = v;
      });
    }

    // Mendukung ekstraksi field berformat dotted bila disimpan terpisah
    data.forEach((k, v) {
      if (k.startsWith('categoryBreakdown.') && k.split('.').length == 3) {
        final parts = k.split('.');
        final catId = parts[1];
        final field = parts[2];
        final currentCat = categoryBreakdown[catId] is Map
            ? Map<String, dynamic>.from(categoryBreakdown[catId] as Map)
            : <String, dynamic>{};
        currentCat[field] = v;
        categoryBreakdown[catId] = currentCat;
      }
    });

    final totalInc = (data['totalIncome'] as num? ?? 0).toInt();
    final totalExp = (data['totalExpense'] as num? ?? 0).toInt();
    final netCash = data.containsKey('netCashflow')
        ? (data['netCashflow'] as num? ?? (totalInc - totalExp)).toInt()
        : (totalInc - totalExp);

    int year = data['year'] as int? ?? 0;
    int month = data['month'] as int? ?? 0;

    // Fallback parsing year & month dari format monthKey "YYYY-MM"
    if (year == 0 && docId.contains('-')) {
      final parts = docId.split('-');
      if (parts.length >= 2) {
        year = int.tryParse(parts[0]) ?? 0;
        final m = int.tryParse(parts[1]) ?? 1;
        month = m - 1;
      }
    }

    return MonthlySummaryModel(
      monthKey: docId,
      year: year,
      month: month,
      totalIncome: totalInc,
      totalExpense: totalExp,
      netCashflow: netCash,
      transactionCount: (data['transactionCount'] as num? ?? 0).toInt(),
      categoryBreakdown: categoryBreakdown,
      updatedAt: updatedAt,
    );
  }

  /// Serialisasi ke format dokumen Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'monthKey': monthKey,
      'year': year,
      'month': month,
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'netCashflow': netCashflow,
      'transactionCount': transactionCount,
      'categoryBreakdown': categoryBreakdown,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Serialisasi ke Map standar
  Map<String, dynamic> toMap() {
    return {
      'monthKey': monthKey,
      'year': year,
      'month': month,
      'totalIncome': totalIncome,
      'totalExpense': totalExpense,
      'netCashflow': netCashflow,
      'transactionCount': transactionCount,
      'categoryBreakdown': categoryBreakdown,
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  MonthlySummaryModel copyWith({
    String? monthKey,
    int? year,
    int? month,
    int? totalIncome,
    int? totalExpense,
    int? netCashflow,
    int? transactionCount,
    Map<String, dynamic>? categoryBreakdown,
    DateTime? updatedAt,
  }) {
    return MonthlySummaryModel(
      monthKey: monthKey ?? this.monthKey,
      year: year ?? this.year,
      month: month ?? this.month,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      netCashflow: netCashflow ?? this.netCashflow,
      transactionCount: transactionCount ?? this.transactionCount,
      categoryBreakdown: categoryBreakdown ?? this.categoryBreakdown,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthlySummaryModel &&
          runtimeType == other.runtimeType &&
          monthKey == other.monthKey &&
          year == other.year &&
          month == other.month &&
          totalIncome == other.totalIncome &&
          totalExpense == other.totalExpense &&
          netCashflow == other.netCashflow &&
          transactionCount == other.transactionCount;

  @override
  int get hashCode =>
      monthKey.hashCode ^
      year.hashCode ^
      month.hashCode ^
      totalIncome.hashCode ^
      totalExpense.hashCode ^
      netCashflow.hashCode ^
      transactionCount.hashCode;

  @override
  String toString() {
    return 'MonthlySummaryModel(monthKey: $monthKey, income: $totalIncome, expense: $totalExpense, net: $netCashflow, count: $transactionCount)';
  }
}
