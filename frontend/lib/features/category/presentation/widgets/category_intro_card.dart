import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/animations.dart';

class CategoryIntroCard extends StatelessWidget {
  final int expenseCount;
  final int incomeCount;

  const CategoryIntroCard({
    super.key,
    this.expenseCount = 9,
    this.incomeCount = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF65D0F4).withValues(alpha: 0.20),
            blurRadius: 26,
            spreadRadius: -4,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: const Color(0xFF0D2C3A).withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.95),
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          children: [
            // Ambient sky glow circle
            Positioned(
              right: -24,
              bottom: -24,
              child: Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryFixed.withValues(alpha: 0.35),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Kelola kategori transaksi dan alokasi anggaran Anda secara terarah',
                              style: AppTextStyles.bodySm.copyWith(
                                color: AppColors.secondary,
                                fontSize: 12,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 14),

                      // Animated Clay Icon Pod (50x50)
                      PressableScale(
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.9),
                                blurRadius: 4,
                                offset: const Offset(0, -2),
                              ),
                              BoxShadow(
                                color: AppColors.primaryContainer.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.pie_chart_rounded,
                              size: 26,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Stat Badges Wrap (Never overflows)
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _buildStatChip(
                        label: '$expenseCount Pengeluaran',
                        dotColor: AppColors.expense,
                        bgColor: AppColors.errorContainer.withValues(alpha: 0.6),
                        textColor: AppColors.onErrorContainer,
                      ),
                      _buildStatChip(
                        label: '$incomeCount Pemasukan',
                        dotColor: AppColors.income,
                        bgColor: AppColors.secondaryContainer.withValues(alpha: 0.7),
                        textColor: AppColors.primary,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip({
    required String label,
    required Color dotColor,
    required Color bgColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.labelSm.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 10.5,
              letterSpacing: 0.1,
            ),
          ),
        ],
      ),
    );
  }
}
