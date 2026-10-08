import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_shimmer.dart';

class CategorySkeleton extends StatelessWidget {
  const CategorySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Intro Card Skeleton
          _buildIntroCardSkeleton(),

          const SizedBox(height: 18),

          // 2. Tab Bar Skeleton
          _buildTabBarSkeleton(),

          const SizedBox(height: 16),

          // 3. Search Bar Skeleton
          ShimmerBox.pill(height: 48),

          const SizedBox(height: 20),

          // 4. Category Grid Skeleton (3 Columns x 3 Rows = 9 items)
          _buildGridSkeleton(),

          const SizedBox(height: 28),

          // 5. Bottom CTA Button Skeleton
          ShimmerBox.pill(height: 56),
        ],
      ),
    );
  }

  Widget _buildIntroCardSkeleton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
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
                  ShimmerBox.pill(width: 140, height: 16),
                  const SizedBox(height: 8),
                  ShimmerBox.pill(width: 210, height: 12),
                ],
              ),
              ShimmerBox.circle(size: 48),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ShimmerBox.pill(width: 120, height: 26),
              const SizedBox(width: 8),
              ShimmerBox.pill(width: 110, height: 26),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabBarSkeleton() {
    return Container(
      height: 50,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Expanded(
            child: ShimmerBox(
              height: 40,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ShimmerBox(
              height: 40,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGridSkeleton() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.90,
      ),
      itemCount: 9,
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
              ShimmerBox.pill(width: 60, height: 11),
            ],
          ),
        );
      },
    );
  }
}
