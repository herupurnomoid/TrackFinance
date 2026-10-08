import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class CategoryTabBar extends StatelessWidget {
  final bool isExpenseSelected;
  final ValueChanged<bool> onTabChanged;

  const CategoryTabBar({
    super.key,
    required this.isExpenseSelected,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(99),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D2C3A).withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.85),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Pengeluaran Tab
          Expanded(
            child: _buildTabButton(
              title: 'Pengeluaran',
              icon: Icons.trending_down_rounded,
              isSelected: isExpenseSelected,
              onTap: () => onTabChanged(true),
            ),
          ),

          // Pemasukan Tab
          Expanded(
            child: _buildTabButton(
              title: 'Pemasukan',
              icon: Icons.trending_up_rounded,
              isSelected: !isExpenseSelected,
              onTap: () => onTabChanged(false),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(99),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryContainer.withValues(alpha: 0.45),
                    blurRadius: 18,
                    spreadRadius: -2,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : AppColors.secondary,
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: AppTextStyles.labelLg.copyWith(
                color: isSelected ? Colors.white : AppColors.secondary,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
