import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../data/dummy_dashboard_data.dart';

class CashflowChartCard extends StatelessWidget {
  final List<CashflowDataPoint> dataPoints;

  const CashflowChartCard({
    super.key,
    required this.dataPoints,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3865D0F4), // rgba(101,208,244,0.22)
            blurRadius: 24,
            spreadRadius: -6,
            offset: Offset(0, 12),
          ),
          BoxShadow(
            color: Color(0x0A0D2C3A),
            blurRadius: 10,
            spreadRadius: -2,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.white,
            blurRadius: 6,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Title, Subtitle & Legends
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tren Arus Kas',
                      style: AppTextStyles.headlineSm.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Perbandingan Masuk & Keluar',
                      style: AppTextStyles.bodySm.copyWith(
                        color: AppColors.secondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Legends
              Row(
                children: [
                  _buildLegend(
                    color: AppColors.primaryContainer,
                    label: 'Masuk',
                  ),
                  const SizedBox(width: 10),
                  _buildLegend(
                    color: AppColors.surfaceContainerHighest,
                    label: 'Keluar',
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Clay Bar Chart Container with Y-Axis and 5 Horizontal Grid Lines
          _buildChartWithGrid(),
        ],
      ),
    );
  }

  Widget _buildLegend({
    required Color color,
    required String label,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: AppTextStyles.labelSm.copyWith(
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildChartWithGrid() {
    const double chartHeight = 144.0;
    final List<String> yAxisLabels = ['10 Jt', '7,5 Jt', '5 Jt', '2,5 Jt', '0'];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Left Y-Axis Scale Labels (10 Jt, 7,5 Jt, 5 Jt, 2,5 Jt, 0)
        SizedBox(
          height: chartHeight,
          width: 38,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: yAxisLabels.map((label) {
              return Text(
                label,
                style: AppTextStyles.labelSm.copyWith(
                  color: AppColors.secondary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(width: 10),

        // 2. Chart Grid & Bars & Dates Area
        Expanded(
          child: Column(
            children: [
              // Grid Lines + Bar Pairs Stack
              SizedBox(
                height: chartHeight,
                child: Stack(
                  children: [
                    // 5 Horizontal Reference Grid Lines
                    Positioned.fill(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(5, (_) {
                          return Container(
                            width: double.infinity,
                            height: 1,
                            color: AppColors.outlineVariant.withValues(alpha: 0.30),
                          );
                        }),
                      ),
                    ),

                    // Bar Pairs (Positioned to touch bottom baseline 0 line)
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: dataPoints.map((point) {
                            return _buildBarPair(point, chartHeight: chartHeight);
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Date Labels below the chart (aligned under each bar pair)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: dataPoints.map((point) {
                    return SizedBox(
                      width: 38,
                      child: Text(
                        point.day,
                        textAlign: TextAlign.center,
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.secondary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBarPair(CashflowDataPoint point, {required double chartHeight}) {
    // Proportional height up to chartHeight, with a minimum touch of 12px
    final incomeH = (point.incomePercentage * chartHeight).clamp(12.0, chartHeight);
    final expenseH = (point.expensePercentage * chartHeight).clamp(12.0, chartHeight);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, factor, child) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Masuk Bar (Cyan Primary Container with top-rounded clay pill shape)
            Container(
              width: 14,
              height: incomeH * factor,
              decoration: const BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x5965D0F4), // rgba(101,208,244,0.35)
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 5),

            // Keluar Bar (Surface Container Highest with top-rounded clay pill shape)
            Container(
              width: 14,
              height: expenseH * factor,
              decoration: const BoxDecoration(
                color: AppColors.surfaceContainerHighest,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x10000000),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
