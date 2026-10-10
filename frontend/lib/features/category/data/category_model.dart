import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CategoryItem {
  final String id;
  final String name;
  final IconData icon;
  final bool isExpense;
  final bool isCustom;
  final Color color;
  final bool isLocked;
  final int order;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.isExpense,
    this.isCustom = false,
    this.color = const Color(0xFF2563EB),
    this.isLocked = false,
    this.order = 0,
    this.createdAt,
    this.updatedAt,
  });

  CategoryItem copyWith({
    String? id,
    String? name,
    IconData? icon,
    bool? isExpense,
    bool? isCustom,
    Color? color,
    bool? isLocked,
    int? order,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      isExpense: isExpense ?? this.isExpense,
      isCustom: isCustom ?? this.isCustom,
      color: color ?? this.color,
      isLocked: isLocked ?? this.isLocked,
      order: order ?? this.order,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Konversi model ke Map standar
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconCode': icon.codePoint,
      'isExpense': isExpense,
      'isCustom': isCustom,
      'color': color.toARGB32(),
      'isLocked': isLocked,
      'order': order,
      if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
    };
  }

  /// Konversi Map ke model CategoryItem
  factory CategoryItem.fromMap(Map<String, dynamic> map, {String? documentId}) {
    final id = documentId ?? (map['id'] as String? ?? '');
    final name = map['name'] as String? ?? 'Kategori';
    final iconCode = map['iconCode'] as int? ?? Icons.category_rounded.codePoint;
    final colorInt = map['color'] as int? ?? 0xFF2563EB;
    final isExpense = map['isExpense'] as bool? ?? true;
    final isCustom = map['isCustom'] as bool? ?? false;
    final isLocked = map['isLocked'] as bool? ?? false;
    final order = map['order'] as int? ?? 0;

    DateTime? createdAt;
    final rawCreatedAt = map['createdAt'];
    if (rawCreatedAt is Timestamp) {
      createdAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is String) {
      createdAt = DateTime.tryParse(rawCreatedAt);
    } else if (rawCreatedAt is int) {
      createdAt = DateTime.fromMillisecondsSinceEpoch(rawCreatedAt);
    }

    DateTime? updatedAt;
    final rawUpdatedAt = map['updatedAt'];
    if (rawUpdatedAt is Timestamp) {
      updatedAt = rawUpdatedAt.toDate();
    } else if (rawUpdatedAt is String) {
      updatedAt = DateTime.tryParse(rawUpdatedAt);
    } else if (rawUpdatedAt is int) {
      updatedAt = DateTime.fromMillisecondsSinceEpoch(rawUpdatedAt);
    }

    return CategoryItem(
      id: id,
      name: name,
      // ignore: non_const_argument_for_const_parameter
      icon: IconData(iconCode, fontFamily: 'MaterialIcons'),
      isExpense: isExpense,
      isCustom: isCustom,
      color: Color(colorInt),
      isLocked: isLocked,
      order: order,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Konversi dokumen Firestore ke Model CategoryItem
  factory CategoryItem.fromFirestore(DocumentSnapshot doc) {
    final rawData = doc.data();
    final data = rawData is Map<String, dynamic>
        ? rawData
        : (rawData is Map ? Map<String, dynamic>.from(rawData) : <String, dynamic>{});
    return CategoryItem.fromMap(data, documentId: doc.id);
  }

  /// Konversi Model ke format Map Cloud Firestore
  Map<String, dynamic> toFirestore() {
    return {
      if (id.isNotEmpty) 'id': id,
      'name': name,
      'iconCode': icon.codePoint,
      'color': color.toARGB32(),
      'isExpense': isExpense,
      'isCustom': isCustom,
      'isLocked': isLocked,
      'order': order,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          icon == other.icon &&
          isExpense == other.isExpense &&
          isCustom == other.isCustom &&
          color == other.color &&
          isLocked == other.isLocked &&
          order == other.order;

  @override
  int get hashCode => Object.hash(
        id,
        name,
        icon,
        isExpense,
        isCustom,
        color,
        isLocked,
        order,
      );

  @override
  String toString() {
    return 'CategoryItem(id: $id, name: $name, isExpense: $isExpense, isCustom: $isCustom, isLocked: $isLocked, order: $order)';
  }
}

class DefaultCategories {
  /// Kategori Pengeluaran Bawaan (8 Kategori sesuai Modern Tactile Finance)
  static List<CategoryItem> get defaultExpenseCategories => [
        const CategoryItem(
          id: 'exp-1',
          name: 'Makanan & Minuman',
          icon: Icons.restaurant_rounded,
          isExpense: true,
          color: Color(0xFFDC2626), // Red
          order: 1,
        ),
        const CategoryItem(
          id: 'exp-2',
          name: 'Transportasi',
          icon: Icons.two_wheeler_rounded,
          isExpense: true,
          color: Color(0xFF2563EB), // Blue
          order: 2,
        ),
        const CategoryItem(
          id: 'exp-3',
          name: 'Belanja Harian',
          icon: Icons.shopping_bag_rounded,
          isExpense: true,
          color: Color(0xFF16A34A), // Green
          order: 3,
        ),
        const CategoryItem(
          id: 'exp-4',
          name: 'Tagihan & Pulsa',
          icon: Icons.receipt_long_rounded,
          isExpense: true,
          color: Color(0xFFDC2626), // Red
          order: 4,
        ),
        const CategoryItem(
          id: 'exp-5',
          name: 'Kesehatan',
          icon: Icons.medical_services_rounded,
          isExpense: true,
          color: Color(0xFF16A34A), // Green
          order: 5,
        ),
        const CategoryItem(
          id: 'exp-6',
          name: 'Hiburan Seru',
          icon: Icons.sports_esports_rounded,
          isExpense: true,
          color: Color(0xFF2563EB), // Blue
          order: 6,
        ),
        const CategoryItem(
          id: 'exp-7',
          name: 'Pendidikan',
          icon: Icons.school_rounded,
          isExpense: true,
          color: Color(0xFF1E40AF), // Dark Blue
          order: 7,
        ),
        const CategoryItem(
          id: 'exp-8',
          name: 'Lainnya',
          icon: Icons.more_horiz_rounded,
          isExpense: true,
          color: Color(0xFF2563EB),
          isLocked: true, // Kategori bawaan sistem terkunci
          order: 8,
        ),
      ];

  /// Kategori Pemasukan Bawaan (6 Kategori sesuai Modern Tactile Finance)
  static List<CategoryItem> get defaultIncomeCategories => [
        const CategoryItem(
          id: 'inc-1',
          name: 'Gaji Pokok',
          icon: Icons.payments_rounded,
          isExpense: false,
          color: Color(0xFF16A34A), // Green
          order: 1,
        ),
        const CategoryItem(
          id: 'inc-2',
          name: 'Bonus',
          icon: Icons.card_giftcard_rounded,
          isExpense: false,
          color: Color(0xFF2563EB), // Blue
          order: 2,
        ),
        const CategoryItem(
          id: 'inc-3',
          name: 'Investasi',
          icon: Icons.trending_up_rounded,
          isExpense: false,
          color: Color(0xFF16A34A), // Green
          order: 3,
        ),
        const CategoryItem(
          id: 'inc-4',
          name: 'Penjualan',
          icon: Icons.storefront_rounded,
          isExpense: false,
          color: Color(0xFF1E40AF), // Dark Blue
          order: 4,
        ),
        const CategoryItem(
          id: 'inc-5',
          name: 'Freelance',
          icon: Icons.laptop_mac_rounded,
          isExpense: false,
          color: Color(0xFF2563EB), // Blue
          order: 5,
        ),
        const CategoryItem(
          id: 'inc-6',
          name: 'Lainnya',
          icon: Icons.more_horiz_rounded,
          isExpense: false,
          color: Color(0xFF16A34A),
          isLocked: true, // Kategori bawaan sistem terkunci
          order: 6,
        ),
      ];
}
