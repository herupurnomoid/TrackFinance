import 'package:flutter/material.dart';

class CategoryItem {
  final String id;
  final String name;
  final IconData icon;
  final bool isExpense;
  final bool isCustom;
  final Color color;
  final bool isLocked;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.isExpense,
    this.isCustom = false,
    this.color = const Color(0xFF2563EB),
    this.isLocked = false,
  });

  CategoryItem copyWith({
    String? id,
    String? name,
    IconData? icon,
    bool? isExpense,
    bool? isCustom,
    Color? color,
    bool? isLocked,
  }) {
    return CategoryItem(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      isExpense: isExpense ?? this.isExpense,
      isCustom: isCustom ?? this.isCustom,
      color: color ?? this.color,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconCode': icon.codePoint,
      'isExpense': isExpense,
      'isCustom': isCustom,
      'color': color.toARGB32(),
      'isLocked': isLocked,
    };
  }

  factory CategoryItem.fromMap(Map<String, dynamic> map) {
    return CategoryItem(
      id: map['id'] as String,
      name: map['name'] as String,
      icon: Icons.category_rounded,
      isExpense: map['isExpense'] as bool,
      isCustom: map['isCustom'] as bool? ?? false,
      color: map['color'] != null ? Color(map['color'] as int) : const Color(0xFF2563EB),
      isLocked: map['isLocked'] as bool? ?? false,
    );
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
        ),
        const CategoryItem(
          id: 'exp-2',
          name: 'Transportasi',
          icon: Icons.two_wheeler_rounded,
          isExpense: true,
          color: Color(0xFF2563EB), // Blue
        ),
        const CategoryItem(
          id: 'exp-3',
          name: 'Belanja Harian',
          icon: Icons.shopping_bag_rounded,
          isExpense: true,
          color: Color(0xFF16A34A), // Green
        ),
        const CategoryItem(
          id: 'exp-4',
          name: 'Tagihan & Pulsa',
          icon: Icons.receipt_long_rounded,
          isExpense: true,
          color: Color(0xFFDC2626), // Red
        ),
        const CategoryItem(
          id: 'exp-5',
          name: 'Kesehatan',
          icon: Icons.medical_services_rounded,
          isExpense: true,
          color: Color(0xFF16A34A), // Green
        ),
        const CategoryItem(
          id: 'exp-6',
          name: 'Hiburan Seru',
          icon: Icons.sports_esports_rounded,
          isExpense: true,
          color: Color(0xFF2563EB), // Blue
        ),
        const CategoryItem(
          id: 'exp-7',
          name: 'Pendidikan',
          icon: Icons.school_rounded,
          isExpense: true,
          color: Color(0xFF1E40AF), // Dark Blue
        ),
        const CategoryItem(
          id: 'exp-8',
          name: 'Lainnya',
          icon: Icons.more_horiz_rounded,
          isExpense: true,
          color: Color(0xFF2563EB),
          isLocked: true, // Kategori bawaan sistem terkunci
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
        ),
        const CategoryItem(
          id: 'inc-2',
          name: 'Bonus',
          icon: Icons.card_giftcard_rounded,
          isExpense: false,
          color: Color(0xFF2563EB), // Blue
        ),
        const CategoryItem(
          id: 'inc-3',
          name: 'Investasi',
          icon: Icons.trending_up_rounded,
          isExpense: false,
          color: Color(0xFF16A34A), // Green
        ),
        const CategoryItem(
          id: 'inc-4',
          name: 'Penjualan',
          icon: Icons.storefront_rounded,
          isExpense: false,
          color: Color(0xFF1E40AF), // Dark Blue
        ),
        const CategoryItem(
          id: 'inc-5',
          name: 'Freelance',
          icon: Icons.laptop_mac_rounded,
          isExpense: false,
          color: Color(0xFF2563EB), // Blue
        ),
        const CategoryItem(
          id: 'inc-6',
          name: 'Lainnya',
          icon: Icons.more_horiz_rounded,
          isExpense: false,
          color: Color(0xFF16A34A),
          isLocked: true, // Kategori bawaan sistem terkunci
        ),
      ];
}
