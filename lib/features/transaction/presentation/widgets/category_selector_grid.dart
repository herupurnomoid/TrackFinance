import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/animations.dart';

class TransactionCategoryOption {
  final String id;
  final String name;
  final IconData icon;

  const TransactionCategoryOption({
    required this.id,
    required this.name,
    required this.icon,
  });
}

class CategorySelectorGrid extends StatelessWidget {
  final bool isExpense;
  final String selectedCategoryId;
  final ValueChanged<TransactionCategoryOption> onSelect;
  final VoidCallback onManageTap;

  const CategorySelectorGrid({
    super.key,
    required this.isExpense,
    required this.selectedCategoryId,
    required this.onSelect,
    required this.onManageTap,
  });

  static const List<TransactionCategoryOption> expenseCategories = [
    TransactionCategoryOption(
      id: 'cat-food',
      name: 'Makanan &\nMinuman',
      icon: Icons.restaurant_rounded,
    ),
    TransactionCategoryOption(
      id: 'cat-shop',
      name: 'Belanja\nPasar',
      icon: Icons.shopping_bag_rounded,
    ),
    TransactionCategoryOption(
      id: 'cat-trans',
      name: 'Transportasi',
      icon: Icons.directions_car_rounded,
    ),
    TransactionCategoryOption(
      id: 'cat-bill',
      name: 'Tagihan &\nWiFi',
      icon: Icons.receipt_long_rounded,
    ),
    TransactionCategoryOption(
      id: 'cat-health',
      name: 'Kesehatan',
      icon: Icons.medical_services_rounded,
    ),
    TransactionCategoryOption(
      id: 'cat-other-exp',
      name: 'Lainnya',
      icon: Icons.more_horiz_rounded,
    ),
  ];

  static const List<TransactionCategoryOption> incomeCategories = [
    TransactionCategoryOption(
      id: 'cat-salary',
      name: 'Gaji\nUtama',
      icon: Icons.account_balance_wallet_rounded,
    ),
    TransactionCategoryOption(
      id: 'cat-bonus',
      name: 'Bonus &\nTunjangan',
      icon: Icons.redeem_rounded,
    ),
    TransactionCategoryOption(
      id: 'cat-invest',
      name: 'Hasil\nInvestasi',
      icon: Icons.savings_rounded,
    ),
    TransactionCategoryOption(
      id: 'cat-sales',
      name: 'Penjualan\nBisnis',
      icon: Icons.storefront_rounded,
    ),
    TransactionCategoryOption(
      id: 'cat-freelance',
      name: 'Freelance\n& Proyek',
      icon: Icons.laptop_mac_rounded,
    ),
    TransactionCategoryOption(
      id: 'cat-other-inc',
      name: 'Lainnya',
      icon: Icons.more_horiz_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final list = isExpense ? expenseCategories : incomeCategories;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header: Title & Action "Kelola"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pilih Kategori',
                style: AppTextStyles.headlineSm.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              InkWell(
                onTap: onManageTap,
                borderRadius: BorderRadius.circular(999),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8.0,
                    vertical: 4.0,
                  ),
                  child: Text(
                    'Kelola',
                    style: AppTextStyles.labelMd.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 3-Column Grid
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.88,
          ),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final cat = list[index];
            final isSelected = cat.id == selectedCategoryId;

            return PressableScale(
              onTap: () => onSelect(cat),
              scaleFactor: 0.94,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryContainer
                      : AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF65D0F4).withValues(alpha: 0.45),
                            blurRadius: 20,
                            spreadRadius: -3,
                            offset: const Offset(0, 10),
                          ),
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.65),
                            blurRadius: 5,
                            offset: const Offset(0, -2),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: const Color(0xFF65D0F4).withValues(alpha: 0.16),
                            blurRadius: 16,
                            spreadRadius: -3,
                            offset: const Offset(0, 7),
                          ),
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.9),
                            blurRadius: 4,
                            offset: const Offset(0, -2),
                          ),
                          BoxShadow(
                            color: const Color(0xFF0D2C3A).withValues(alpha: 0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Circular Icon Container
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.32)
                            : AppColors.secondaryContainer.withValues(alpha: 0.55),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.8),
                            blurRadius: 3,
                            offset: const Offset(0, -1),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          cat.icon,
                          size: 24,
                          color: isSelected ? Colors.white : AppColors.primary,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Label
                    Text(
                      cat.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelMd.copyWith(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected ? Colors.white : AppColors.onSurface,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
