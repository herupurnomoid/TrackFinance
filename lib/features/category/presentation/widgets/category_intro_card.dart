import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class CategoryIntroCard extends StatelessWidget {
  const CategoryIntroCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.clayShadow.withValues(alpha: 0.18),
            blurRadius: 24,
            spreadRadius: -6,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: const Color(0xFF0D2C3A).withValues(alpha: 0.03),
            blurRadius: 10,
            spreadRadius: -2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Text info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Alokasi & Kategori',
                  style: AppTextStyles.headlineSm.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kelola kategori transaksi dan alokasi anggaran Anda secara terarah',
                  style: AppTextStyles.bodySm,
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Icon Pod (48x48)
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.8),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
                BoxShadow(
                  color: AppColors.primaryContainer.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.pie_chart_rounded,
                size: 24,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
