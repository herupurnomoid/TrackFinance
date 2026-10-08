import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_shimmer.dart';

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header / Salutation Skeleton
          _buildGreetingSkeleton(),

          const SizedBox(height: 20),

          // 2. Kartu Perbandingan Arus Kas Skeleton
          _buildCashflowCardSkeleton(),

          const SizedBox(height: 20),

          // 3. Search Bar & Time Period Skeleton
          _buildSearchAndPeriodSkeleton(),

          const SizedBox(height: 22),

          // 4. Analisis Grid Skeleton (2 Cards)
          _buildAnalysisSkeleton(),

          const SizedBox(height: 20),

          // 5. Menu 4-Columns Skeleton
          _buildMenuSkeleton(),

          const SizedBox(height: 22),

          // 6. Tren Arus Kas Bar Chart Skeleton
          _buildCashflowChartSkeleton(),

          const SizedBox(height: 22),

          // 7. Distribusi Kategori Donut Skeleton
          _buildCategoryDistributionSkeleton(),

          const SizedBox(height: 22),

          // 8. Rincian Transaksi Skeleton
          _buildRecentTransactionsSkeleton(),
        ],
      ),
    );
  }

  // 1. Greeting Skeleton
  Widget _buildGreetingSkeleton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBox.pill(width: 140, height: 12),
            const SizedBox(height: 8),
            ShimmerBox.pill(width: 220, height: 24),
          ],
        ),
        ShimmerBox.circle(size: 48),
      ],
    );
  }

  // 2. Cashflow Card Skeleton
  Widget _buildCashflowCardSkeleton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.30),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerBox.pill(width: 150, height: 16),
              ShimmerBox.pill(width: 72, height: 22),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ShimmerBox.circle(size: 32),
                          const SizedBox(width: 8),
                          ShimmerBox.pill(width: 70, height: 12),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ShimmerBox.pill(width: 110, height: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ShimmerBox.circle(size: 32),
                          const SizedBox(width: 8),
                          ShimmerBox.pill(width: 70, height: 12),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ShimmerBox.pill(width: 110, height: 18),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 3. Search & Period Skeleton
  Widget _buildSearchAndPeriodSkeleton() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ShimmerBox.pill(height: 48),
            ),
            const SizedBox(width: 12),
            ShimmerBox.pill(width: 110, height: 48),
          ],
        ),
        const SizedBox(height: 12),
        ShimmerBox.pill(height: 44),
      ],
    );
  }

  // 4. Analisis Grid Skeleton
  Widget _buildAnalysisSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: ShimmerBox.pill(width: 80, height: 12),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                height: 144,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerBox.circle(size: 40),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox.pill(width: 90, height: 10),
                        const SizedBox(height: 6),
                        ShimmerBox.pill(width: 120, height: 14),
                        const SizedBox(height: 6),
                        ShimmerBox.pill(width: 80, height: 12),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                height: 144,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerBox.circle(size: 40),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox.pill(width: 90, height: 14),
                        const SizedBox(height: 6),
                        ShimmerBox.pill(width: 70, height: 11),
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

  // 5. Menu 4-Columns Skeleton
  Widget _buildMenuSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: ShimmerBox.pill(width: 50, height: 14),
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(4, (index) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  right: index < 3 ? 8.0 : 0.0,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      ShimmerBox.circle(size: 40),
                      const SizedBox(height: 8),
                      ShimmerBox.pill(width: 42, height: 10),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  // 6. Tren Arus Kas Bar Chart Skeleton
  Widget _buildCashflowChartSkeleton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox.pill(width: 120, height: 16),
                  const SizedBox(height: 4),
                  ShimmerBox.pill(width: 160, height: 11),
                ],
              ),
              Row(
                children: [
                  ShimmerBox.pill(width: 45, height: 12),
                  const SizedBox(width: 8),
                  ShimmerBox.pill(width: 45, height: 12),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Y Axis
              SizedBox(
                height: 144,
                width: 38,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(5, (_) => ShimmerBox.pill(width: 28, height: 10)),
                ),
              ),
              const SizedBox(width: 10),
              // Chart area with bars
              Expanded(
                child: Column(
                  children: [
                    SizedBox(
                      height: 144,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          _buildSkeletonBarPair(60, 40),
                          _buildSkeletonBarPair(45, 70),
                          _buildSkeletonBarPair(90, 50),
                          _buildSkeletonBarPair(35, 60),
                          _buildSkeletonBarPair(105, 45),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: List.generate(5, (_) => ShimmerBox.pill(width: 34, height: 10)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonBarPair(double h1, double h2) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ShimmerBox(
          width: 14,
          height: h1,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        ),
        const SizedBox(width: 5),
        ShimmerBox(
          width: 14,
          height: h2,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        ),
      ],
    );
  }

  // 7. Distribusi Kategori Skeleton
  Widget _buildCategoryDistributionSkeleton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox.pill(width: 140, height: 16),
          const SizedBox(height: 16),
          ShimmerBox.pill(height: 40),
          const SizedBox(height: 24),
          Center(
            child: ShimmerBox.circle(size: 150),
          ),
          const SizedBox(height: 24),
          Column(
            children: List.generate(4, (_) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6.0),
                child: Row(
                  children: [
                    ShimmerBox.circle(size: 14),
                    const SizedBox(width: 10),
                    Expanded(child: ShimmerBox.pill(height: 12)),
                    const SizedBox(width: 16),
                    ShimmerBox.pill(width: 70, height: 12),
                    const SizedBox(width: 8),
                    ShimmerBox.pill(width: 28, height: 12),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // 8. Rincian Transaksi Skeleton
  Widget _buildRecentTransactionsSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ShimmerBox.pill(width: 130, height: 16),
            ShimmerBox.pill(width: 60, height: 16),
          ],
        ),
        const SizedBox(height: 14),
        ShimmerBox.pill(width: 100, height: 12),
        const SizedBox(height: 8),
        Column(
          children: List.generate(3, (_) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    ShimmerBox.circle(size: 40),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerBox.pill(width: 120, height: 14),
                          const SizedBox(height: 6),
                          ShimmerBox.pill(width: 170, height: 11),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ShimmerBox.pill(width: 75, height: 14),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
