import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class QuickStatsCards extends StatelessWidget {
  final String topCategory;
  final String topAmount;
  final String healthStatus;
  final String healthScore;
  final VoidCallback? onTopCategoryTap;
  final VoidCallback? onHealthTap;

  const QuickStatsCards({
    super.key,
    this.topCategory = 'Makanan & Minuman',
    this.topAmount = 'Rp 1.785.000',
    this.healthStatus = 'Sangat Sehat',
    this.healthScore = 'Skor 85 / 100',
    this.onTopCategoryTap,
    this.onHealthTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header: ANALISIS
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            'ANALISIS',
            style: AppTextStyles.labelMd.copyWith(
              color: AppColors.secondary,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Grid 2 Columns
        Row(
          children: [
            // 1. Top Pengeluaran Card
            Expanded(
              child: _TactileStatCard(
                onTap: onTopCategoryTap,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryContainer,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x6665D0F4),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.restaurant_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Top Pengeluaran',
                          style: AppTextStyles.labelSm.copyWith(
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          topCategory,
                          style: AppTextStyles.headlineSm.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          topAmount,
                          style: AppTextStyles.labelLg.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 12),

            // 2. Kesehatan Finansial Card
            Expanded(
              child: _TactileStatCard(
                onTap: onHealthTap,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceContainerLow,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x2665D0F4),
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.verified_user_rounded,
                          size: 20,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          healthStatus,
                          style: AppTextStyles.headlineSm.copyWith(
                            fontSize: 16,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          healthScore,
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TactileStatCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _TactileStatCard({required this.child, this.onTap});

  @override
  State<_TactileStatCard> createState() => _TactileStatCardState();
}

class _TactileStatCardState extends State<_TactileStatCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: const BoxConstraints(minHeight: 144),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x3865D0F4), // rgba(101,208,244,0.22)
                blurRadius: 20,
                spreadRadius: -4,
                offset: Offset(0, 10),
              ),
              BoxShadow(
                color: Colors.white,
                blurRadius: 5,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
