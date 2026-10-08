import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_shimmer.dart';

class ExportDataSkeleton extends StatelessWidget {
  final bool isExport;

  const ExportDataSkeleton({
    super.key,
    this.isExport = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: isExport ? _buildExportSkeleton() : _buildImportSkeleton(),
    );
  }

  Widget _buildExportSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Header Skeleton
        _buildHeaderSkeleton(),

        const SizedBox(height: 18),

        // 2. Segmented Switcher Skeleton
        _buildSegmentedSkeleton(),

        const SizedBox(height: 20),

        // 3. Periode Laporan Card Skeleton
        _buildPeriodCardSkeleton(),

        const SizedBox(height: 20),

        // 4. Format Selector Grid Skeleton (2 cards)
        _buildFormatGridSkeleton(),

        const SizedBox(height: 20),

        // 5. Data Preview Table Skeleton
        _buildPreviewTableSkeleton(),

        const SizedBox(height: 28),

        // 6. Bottom CTA Button Skeleton
        ShimmerBox.pill(height: 56),
      ],
    );
  }

  Widget _buildImportSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Segmented Switcher Skeleton at top
        _buildSegmentedSkeleton(),

        const SizedBox(height: 18),

        // 2. Guidance & Header
        Row(
          children: [
            ShimmerBox.circle(size: 8),
            const SizedBox(width: 8),
            ShimmerBox.pill(width: 140, height: 11),
          ],
        ),
        const SizedBox(height: 8),
        ShimmerBox.pill(width: 180, height: 24),
        const SizedBox(height: 8),
        ShimmerBox.pill(width: double.infinity, height: 14),
        const SizedBox(height: 4),
        ShimmerBox.pill(width: 220, height: 14),

        const SizedBox(height: 16),

        // 3. Template Download Card Skeleton
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              ShimmerBox(
                width: 42,
                height: 42,
                borderRadius: BorderRadius.circular(14),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox.pill(width: 160, height: 14),
                    const SizedBox(height: 6),
                    ShimmerBox.pill(width: 120, height: 11),
                  ],
                ),
              ),
              ShimmerBox.circle(size: 34),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // 4. Dropzone Box Skeleton
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          decoration: BoxDecoration(
            color: const Color(0xFFD8E5EA).withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            children: [
              ShimmerBox.circle(size: 64),
              const SizedBox(height: 14),
              ShimmerBox.pill(width: 190, height: 16),
              const SizedBox(height: 6),
              ShimmerBox.pill(width: 130, height: 12),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // 5. Active File Card Skeleton
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              ShimmerBox(
                width: 44,
                height: 44,
                borderRadius: BorderRadius.circular(14),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox.pill(width: 170, height: 14),
                    const SizedBox(height: 6),
                    ShimmerBox.pill(width: 110, height: 11),
                  ],
                ),
              ),
              ShimmerBox.circle(size: 34),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // 6. Preview Table Skeleton
        _buildPreviewTableSkeleton(),

        const SizedBox(height: 24),

        // 7. CTA Buttons Skeleton
        ShimmerBox.pill(height: 56),
        const SizedBox(height: 12),
        ShimmerBox.pill(height: 48),
      ],
    );
  }

  Widget _buildHeaderSkeleton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBox.pill(width: 140, height: 11),
            const SizedBox(height: 6),
            ShimmerBox.pill(width: 180, height: 22),
          ],
        ),
        ShimmerBox.circle(size: 40),
      ],
    );
  }

  Widget _buildSegmentedSkeleton() {
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

  Widget _buildPeriodCardSkeleton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
                ShimmerBox.pill(width: 90, height: 11),
                const SizedBox(height: 6),
                ShimmerBox.pill(width: 110, height: 18),
              ],
            ),
          ),
          ShimmerBox.pill(width: 76, height: 36),
        ],
      ),
    );
  }

  Widget _buildFormatGridSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: ShimmerBox.pill(width: 120, height: 14),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Container(
                height: 140,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox.circle(size: 44),
                    const SizedBox(height: 12),
                    ShimmerBox.pill(width: 80, height: 16),
                    const SizedBox(height: 6),
                    ShimmerBox.pill(width: 95, height: 11),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 140,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox.circle(size: 44),
                    const SizedBox(height: 12),
                    ShimmerBox.pill(width: 90, height: 16),
                    const SizedBox(height: 6),
                    ShimmerBox.pill(width: 75, height: 11),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPreviewTableSkeleton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ShimmerBox.pill(width: 160, height: 16),
              ShimmerBox.pill(width: 90, height: 22),
            ],
          ),
          const SizedBox(height: 12),
          ShimmerBox.pill(height: 38),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: List.generate(3, (index) {
                return Padding(
                  padding: EdgeInsets.only(bottom: index < 2 ? 8.0 : 0.0),
                  child: ShimmerBox.pill(height: 30),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
