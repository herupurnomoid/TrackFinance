import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_shimmer.dart';

/// Shimmer Skeleton Loader untuk Halaman Impor Data
/// Mendukung mode empty state dan mode uploaded state.
class ImportSkeleton extends StatelessWidget {
  final bool isUploadedState;

  const ImportSkeleton({
    super.key,
    this.isUploadedState = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Segmented Toggle Control Inset Track Skeleton
          _buildSegmentedSwitchSkeleton(),

          const SizedBox(height: 20),

          if (isUploadedState) ...[
            // Mode File Terunggah
            _buildUploadedFileCardSkeleton(),
            const SizedBox(height: 14),
            _buildStatsGridSkeleton(),
            const SizedBox(height: 16),
            _buildPreviewSectionSkeleton(),
          ] else ...[
            // Mode Belum Ada File (Empty State)
            _buildDropZoneSkeleton(),
            const SizedBox(height: 14),
            _buildDownloadTemplateSkeleton(),
            const SizedBox(height: 24),
            _buildCsvSpecTableSkeleton(),
          ],

          const SizedBox(height: 32),

          // Bottom Action Button Skeleton
          _buildBottomButtonSkeleton(),
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
          Expanded(
            child: ShimmerBox(
              height: 40,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(width: 4),
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

  // --- Skeletons untuk Mode Empty State ---
  Widget _buildDropZoneSkeleton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          ShimmerBox(
            width: 64,
            height: 64,
            borderRadius: BorderRadius.circular(20),
          ),
          const SizedBox(height: 16),
          ShimmerBox.pill(width: 130, height: 16),
          const SizedBox(height: 8),
          ShimmerBox.pill(width: 75, height: 12),
        ],
      ),
    );
  }

  Widget _buildDownloadTemplateSkeleton() {
    return Center(
      child: ShimmerBox.pill(width: 140, height: 32),
    );
  }

  Widget _buildCsvSpecTableSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerBox.pill(width: 90, height: 16),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEAEDFF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerBox.pill(width: 24, height: 12),
                    ShimmerBox.pill(width: 60, height: 12),
                    ShimmerBox.pill(width: 50, height: 12),
                    ShimmerBox.pill(width: 80, height: 12),
                    ShimmerBox.pill(width: 70, height: 12),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerBox.pill(width: 16, height: 14),
                    ShimmerBox.pill(width: 70, height: 14),
                    ShimmerBox.pill(width: 75, height: 18),
                    ShimmerBox.pill(width: 90, height: 14),
                    ShimmerBox.pill(width: 50, height: 14),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerBox.pill(width: 16, height: 14),
                    ShimmerBox.pill(width: 70, height: 14),
                    ShimmerBox.pill(width: 70, height: 18),
                    ShimmerBox.pill(width: 85, height: 14),
                    ShimmerBox.pill(width: 55, height: 14),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- Skeletons untuk Mode Uploaded State ---
  Widget _buildUploadedFileCardSkeleton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ShimmerBox(
                width: 44,
                height: 44,
                borderRadius: BorderRadius.circular(14),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox.pill(width: 150, height: 15),
                  const SizedBox(height: 6),
                  ShimmerBox.pill(width: 100, height: 11),
                ],
              ),
            ],
          ),
          ShimmerBox.circle(size: 32),
        ],
      ),
    );
  }

  Widget _buildStatsGridSkeleton() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatBoxSkeleton()),
            const SizedBox(width: 10),
            Expanded(child: _buildStatBoxSkeleton()),
            const SizedBox(width: 10),
            Expanded(child: _buildStatBoxSkeleton()),
          ],
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: ShimmerBox.pill(width: 130, height: 16),
        ),
      ],
    );
  }

  Widget _buildStatBoxSkeleton() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          ShimmerBox.pill(width: 40, height: 22),
          const SizedBox(height: 4),
          ShimmerBox.pill(width: 55, height: 10),
        ],
      ),
    );
  }

  Widget _buildPreviewSectionSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ShimmerBox.pill(width: 100, height: 15),
            ShimmerBox.pill(width: 120, height: 12),
          ],
        ),
        const SizedBox(height: 10),
        _buildPreviewCardSkeleton(),
        const SizedBox(height: 8),
        _buildPreviewCardSkeleton(),
        const SizedBox(height: 8),
        _buildPreviewCardSkeleton(),
      ],
    );
  }

  Widget _buildPreviewCardSkeleton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ShimmerBox.circle(size: 36),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox.pill(width: 130, height: 14),
                  const SizedBox(height: 6),
                  ShimmerBox.pill(width: 70, height: 10),
                ],
              ),
            ],
          ),
          ShimmerBox.pill(width: 75, height: 16),
        ],
      ),
    );
  }

  Widget _buildBottomButtonSkeleton() {
    return ShimmerBox(
      width: double.infinity,
      height: 52,
      borderRadius: BorderRadius.circular(16),
    );
  }
}
