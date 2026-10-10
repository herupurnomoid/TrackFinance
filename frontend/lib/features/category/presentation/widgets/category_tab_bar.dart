import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/animations.dart';

class CategoryTabBar extends StatelessWidget {
  final bool isExpenseSelected;
  final ValueChanged<bool> onTabChanged;
  final int expenseCount;
  final int incomeCount;

  const CategoryTabBar({
    super.key,
    required this.isExpenseSelected,
    required this.onTabChanged,
    this.expenseCount = 9,
    this.incomeCount = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
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
              count: expenseCount,
              icon: Icons.trending_down_rounded,
              isSelected: isExpenseSelected,
              onTap: () {
                if (!isExpenseSelected) onTabChanged(true);
              },
            ),
          ),

          // Pemasukan Tab
          Expanded(
            child: _buildTabButton(
              title: 'Pemasukan',
              count: incomeCount,
              icon: Icons.trending_up_rounded,
              isSelected: !isExpenseSelected,
              onTap: () {
                if (isExpenseSelected) onTabChanged(false);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required int count,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return PressableScale(
      onTap: onTap,
      scaleFactor: 0.95,
      translateY: 2.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF65D0F4).withValues(alpha: 0.45),
                    blurRadius: 18,
                    spreadRadius: -2,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.65),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : AppColors.secondary,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelLg.copyWith(
                  color: isSelected ? Colors.white : AppColors.secondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 6),
            // Count badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.28)
                    : AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                '$count',
                style: AppTextStyles.labelSm.copyWith(
                  fontSize: 10,
                  color: isSelected ? Colors.white : AppColors.secondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
