import 'package:flutter/material.dart';

class CategoryItem {
  final String id;
  final String name;
  final IconData icon;
  final bool isExpense;
  final bool isCustom;

  const CategoryItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.isExpense,
    this.isCustom = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'iconCode': icon.codePoint,
      'isExpense': isExpense,
      'isCustom': isCustom,
    };
  }

  factory CategoryItem.fromMap(Map<String, dynamic> map) {
    return CategoryItem(
      id: map['id'] as String,
      name: map['name'] as String,
      icon: Icons.category_rounded,
      isExpense: map['isExpense'] as bool,
      isCustom: map['isCustom'] as bool? ?? false,
    );
  }
}

class DefaultCategories {
  static List<CategoryItem> get defaultExpenseCategories => [
        const CategoryItem(
          id: 'exp-1',
          name: 'Makanan',
          icon: Icons.restaurant_rounded,
          isExpense: true,
        ),
        const CategoryItem(
          id: 'exp-2',
          name: 'Transportasi',
          icon: Icons.directions_car_rounded,
          isExpense: true,
        ),
        const CategoryItem(
          id: 'exp-3',
          name: 'Belanja',
          icon: Icons.shopping_bag_rounded,
          isExpense: true,
        ),
        const CategoryItem(
          id: 'exp-4',
          name: 'Tagihan',
          icon: Icons.receipt_long_rounded,
          isExpense: true,
        ),
        const CategoryItem(
          id: 'exp-5',
          name: 'Hiburan',
          icon: Icons.movie_rounded,
          isExpense: true,
        ),
        const CategoryItem(
          id: 'exp-6',
          name: 'Kesehatan',
          icon: Icons.favorite_rounded,
          isExpense: true,
        ),
        const CategoryItem(
          id: 'exp-7',
          name: 'Pendidikan',
          icon: Icons.school_rounded,
          isExpense: true,
        ),
        const CategoryItem(
          id: 'exp-8',
          name: 'Investasi',
          icon: Icons.trending_up_rounded,
          isExpense: true,
        ),
        const CategoryItem(
          id: 'exp-9',
          name: 'Keluarga',
          icon: Icons.diversity_1_rounded,
          isExpense: true,
        ),
      ];

  static List<CategoryItem> get defaultIncomeCategories => [
        const CategoryItem(
          id: 'inc-1',
          name: 'Gaji Utama',
          icon: Icons.account_balance_wallet_rounded,
          isExpense: false,
        ),
        const CategoryItem(
          id: 'inc-2',
          name: 'Bonus',
          icon: Icons.redeem_rounded,
          isExpense: false,
        ),
        const CategoryItem(
          id: 'inc-3',
          name: 'Investasi',
          icon: Icons.savings_rounded,
          isExpense: false,
        ),
        const CategoryItem(
          id: 'inc-4',
          name: 'Penjualan',
          icon: Icons.storefront_rounded,
          isExpense: false,
        ),
        const CategoryItem(
          id: 'inc-5',
          name: 'Hadiah',
          icon: Icons.card_giftcard_rounded,
          isExpense: false,
        ),
        const CategoryItem(
          id: 'inc-6',
          name: 'Freelance',
          icon: Icons.laptop_mac_rounded,
          isExpense: false,
        ),
      ];
}
