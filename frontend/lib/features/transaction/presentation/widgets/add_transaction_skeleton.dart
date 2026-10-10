import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_shimmer.dart';

/// Loading Shimmer Skeleton untuk Tambah Transaksi
/// Mencerminkan struktur Soft Skeuomorphism 4-Column Matrix dan Tactile Cards.
class AddTransactionSkeleton extends StatelessWidget {
  const AddTransactionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Segmented Control Inset Track Skeleton
          _buildSegmentedSwitchSkeleton(),

          const SizedBox(height: 18),

          // 2. Elevated Nominal Card Skeleton
          _buildAmountCardSkeleton(),

          const SizedBox(height: 20),

          // 3. Category Matrix Skeleton (4-Columns x 2 Rows = 8 items + Banner)
          _buildCategoryGridSkeleton(),

          const SizedBox(height: 20),

          // 4. Date & Time Side-by-Side Cards Skeleton
          _buildDateTimeSkeleton(),

          const SizedBox(height: 16),

          // 5. Inset Note Well Skeleton
          _buildNoteWellSkeleton(),

          const SizedBox(height: 24),

          // 6. 3D CTA Button Skeleton
          _buildButtonSkeleton(),
        ],
      ),
    );
  }

  Widget _buildSegmentedSwitchSkeleton() {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E7FF),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: ShimmerBox(
              height: 40,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: ShimmerBox(
              height: 40,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountCardSkeleton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerBox.pill(width: 120, height: 14),
              ShimmerBox.pill(width: 65, height: 22),
            ],
          ),
          const SizedBox(height: 14),
          // Recessed input field skeleton
          ShimmerBox(
            width: double.infinity,
            height: 54,
            borderRadius: BorderRadius.circular(16),
          ),
          const SizedBox(height: 14),
          // Quick pills row
          Row(
            children: [
              ShimmerBox.pill(width: 65, height: 28),
              const SizedBox(width: 8),
              ShimmerBox.pill(width: 65, height: 28),
              const SizedBox(width: 8),
              ShimmerBox.pill(width: 65, height: 28),
              const SizedBox(width: 8),
              ShimmerBox.pill(width: 70, height: 28),
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
        ShimmerBox.pill(width: 90, height: 18),
        const SizedBox(height: 8),
        // 4 Columns x 2 Rows
        GridView.builder(
          padding: EdgeInsets.zero,
          clipBehavior: Clip.none,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: 80,
          ),
          itemCount: 8,
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ShimmerBox(
                    width: 36,
                    height: 36,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  const SizedBox(height: 4),
                  ShimmerBox.pill(width: 44, height: 9),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        // Kelola Banner Skeleton
        ShimmerBox(
          width: double.infinity,
          height: 46,
          borderRadius: BorderRadius.circular(16),
        ),
      ],
    );
  }

  Widget _buildDateTimeSkeleton() {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                ShimmerBox(
                  width: 36,
                  height: 36,
                  borderRadius: BorderRadius.circular(12),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox.pill(width: 45, height: 10),
                      const SizedBox(height: 6),
                      ShimmerBox.pill(width: 70, height: 13),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                ShimmerBox(
                  width: 36,
                  height: 36,
                  borderRadius: BorderRadius.circular(12),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox.pill(width: 40, height: 10),
                      const SizedBox(height: 6),
                      ShimmerBox.pill(width: 50, height: 13),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoteWellSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerBox.pill(width: 110, height: 12),
        const SizedBox(height: 6),
        ShimmerBox(
          width: double.infinity,
          height: 70,
          borderRadius: BorderRadius.circular(18),
        ),
      ],
    );
  }

  Widget _buildButtonSkeleton() {
    return ShimmerBox(
      width: double.infinity,
      height: 54,
      borderRadius: BorderRadius.circular(18),
    );
  }
}
