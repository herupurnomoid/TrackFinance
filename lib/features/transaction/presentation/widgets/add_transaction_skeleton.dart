import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_shimmer.dart';

class AddTransactionSkeleton extends StatelessWidget {
  const AddTransactionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Segmented Control Skeleton (Pengeluaran vs Pemasukan)
          _buildSegmentedControlSkeleton(),

          const SizedBox(height: 24),

          // 2. Hero Input Card Skeleton
          _buildAmountCardSkeleton(),

          const SizedBox(height: 24),

          // 3. Category Selector Grid Skeleton
          _buildCategoryGridSkeleton(),

          const SizedBox(height: 24),

          // 4. Additional Details Skeleton (Date, Time, Note)
          _buildAdditionalDetailsSkeleton(),

          const SizedBox(height: 28),

          // 5. CTA Button Skeleton
          ShimmerBox.pill(height: 56),
        ],
      ),
    );
  }

  Widget _buildSegmentedControlSkeleton() {
    return Container(
      height: 52,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Expanded(
            child: ShimmerBox(
              height: 42,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ShimmerBox(
              height: 42,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountCardSkeleton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerBox.pill(width: 120, height: 14),
              ShimmerBox.pill(width: 60, height: 22),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              ShimmerBox.pill(width: 38, height: 26),
              const SizedBox(width: 12),
              ShimmerBox.pill(width: 180, height: 38),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            height: 1,
            color: AppColors.surfaceContainerHigh,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ShimmerBox.pill(width: 62, height: 32),
              const SizedBox(width: 8),
              ShimmerBox.pill(width: 72, height: 32),
              const SizedBox(width: 8),
              ShimmerBox.pill(width: 72, height: 32),
              const Spacer(),
              ShimmerBox.circle(size: 32),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGridSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ShimmerBox.pill(width: 110, height: 18),
            ShimmerBox.pill(width: 48, height: 14),
          ],
        ),
        const SizedBox(height: 14),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.92,
          ),
          itemCount: 6,
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShimmerBox.circle(size: 46),
                  const SizedBox(height: 10),
                  ShimmerBox.pill(width: 68, height: 11),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAdditionalDetailsSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerBox.pill(width: 125, height: 14),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    ShimmerBox.circle(size: 38),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerBox.pill(width: 45, height: 10),
                          const SizedBox(height: 6),
                          ShimmerBox.pill(width: 75, height: 13),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    ShimmerBox.circle(size: 38),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ShimmerBox.pill(width: 55, height: 10),
                          const SizedBox(height: 6),
                          ShimmerBox.pill(width: 65, height: 13),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox.circle(size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox.pill(width: 110, height: 11),
                    const SizedBox(height: 8),
                    ShimmerBox.pill(width: 180, height: 14),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
