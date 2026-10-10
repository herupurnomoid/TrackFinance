import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_shimmer.dart';

/// Shimmer Skeleton Loader untuk Halaman Ekspor Data
/// Mengikuti struktur tata letak filter periode, tanggal, format file, dan aksi tombol.
class ExportSkeleton extends StatelessWidget {
  const ExportSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Segmented Mode Switcher Skeleton
          _buildSegmentedSwitchSkeleton(),

          const SizedBox(height: 20),

          // 2. Periode Header Skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerBox.pill(width: 70, height: 16),
              ShimmerBox.pill(width: 80, height: 12),
            ],
          ),

          const SizedBox(height: 10),

          // 3. Sub-segmented 3-Tabs Skeleton
          Container(
            height: 44,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFDAE2FD),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(child: ShimmerBox(height: 36, borderRadius: BorderRadius.circular(12))),
                const SizedBox(width: 4),
                Expanded(child: ShimmerBox(height: 36, borderRadius: BorderRadius.circular(12))),
                const SizedBox(width: 4),
                Expanded(child: ShimmerBox(height: 36, borderRadius: BorderRadius.circular(12))),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 4. Two Date Cards Skeleton
          Row(
            children: [
              Expanded(child: _buildDateCardSkeleton()),
              const SizedBox(width: 10),
              Expanded(child: _buildDateCardSkeleton()),
            ],
          ),

          const SizedBox(height: 10),

          // 5. Active Range Chips Skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerBox.pill(width: 140, height: 26),
              ShimmerBox.pill(width: 120, height: 26),
            ],
          ),

          const SizedBox(height: 14),

          // 6. Micro Insight Well Skeleton
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                ShimmerBox(width: 36, height: 36, borderRadius: BorderRadius.circular(12)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox.pill(width: 120, height: 11),
                      const SizedBox(height: 6),
                      ShimmerBox.pill(width: 90, height: 15),
                    ],
                  ),
                ),
                ShimmerBox.pill(width: 65, height: 20),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 7. Format Header Skeleton
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerBox.pill(width: 60, height: 16),
              ShimmerBox.pill(width: 90, height: 12),
            ],
          ),

          const SizedBox(height: 10),

          // 8. Format Tiles 2-Grid Skeleton
          Row(
            children: [
              Expanded(child: _buildFormatCardSkeleton()),
              const SizedBox(width: 12),
              Expanded(child: _buildFormatCardSkeleton()),
            ],
          ),

          const SizedBox(height: 14),

          // 9. Visual Note Block Skeleton
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFDAE2FD).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox.circle(size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox.pill(width: double.infinity, height: 12),
                      const SizedBox(height: 6),
                      ShimmerBox.pill(width: 180, height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 10. Bottom Button Skeleton
          ShimmerBox(
            width: double.infinity,
            height: 52,
            borderRadius: BorderRadius.circular(16),
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentedSwitchSkeleton() {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFDAE2FD),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          Expanded(child: ShimmerBox(height: 40, borderRadius: BorderRadius.circular(999))),
          const SizedBox(width: 4),
          Expanded(child: ShimmerBox(height: 40, borderRadius: BorderRadius.circular(999))),
        ],
      ),
    );
  }

  Widget _buildDateCardSkeleton() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox.pill(width: 40, height: 11),
          const SizedBox(height: 8),
          Row(
            children: [
              ShimmerBox(width: 24, height: 24, borderRadius: BorderRadius.circular(8)),
              const SizedBox(width: 8),
              ShimmerBox.pill(width: 75, height: 13),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFormatCardSkeleton() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          ShimmerBox(width: 48, height: 48, borderRadius: BorderRadius.circular(16)),
          const SizedBox(height: 10),
          ShimmerBox.pill(width: 45, height: 14),
          const SizedBox(height: 4),
          ShimmerBox.pill(width: 80, height: 10),
        ],
      ),
    );
  }
}
