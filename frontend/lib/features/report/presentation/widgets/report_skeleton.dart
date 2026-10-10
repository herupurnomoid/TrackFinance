import 'package:flutter/material.dart';
import '../../../../core/widgets/app_shimmer.dart';

/// Skeleton Loading Shimmer untuk Halaman Laporan Keuangan
/// Menampilkan placeholder kartu tren, grafik donut, daftar kategori,
/// dan indikator kesehatan dengan animasi light-sweep terus menerus.
class ReportSkeleton extends StatelessWidget {
  const ReportSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Pill Filter Skeleton
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ShimmerBox.pill(width: 110, height: 36),
          ),

          // 2. Kartu Tren Keuangan Skeleton
          _buildCardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerBox.pill(width: 120, height: 16),
                    ShimmerBox.pill(width: 90, height: 14),
                  ],
                ),
                const SizedBox(height: 20),
                // Chart Area Skeleton
                SizedBox(
                  height: 140,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      ShimmerBox(width: 14, height: 40, borderRadius: BorderRadius.circular(6)),
                      ShimmerBox(width: 14, height: 110, borderRadius: BorderRadius.circular(6)),
                      ShimmerBox(width: 14, height: 30, borderRadius: BorderRadius.circular(6)),
                      ShimmerBox(width: 14, height: 120, borderRadius: BorderRadius.circular(6)),
                      ShimmerBox(width: 14, height: 45, borderRadius: BorderRadius.circular(6)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Summary Boxes
                Row(
                  children: [
                    Expanded(child: ShimmerBox(height: 52, borderRadius: BorderRadius.circular(12))),
                    const SizedBox(width: 12),
                    Expanded(child: ShimmerBox(height: 52, borderRadius: BorderRadius.circular(12))),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 3. Kartu Struktur Transaksi Skeleton
          _buildCardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerBox.pill(width: 140, height: 16),
                    ShimmerBox.pill(width: 100, height: 28),
                  ],
                ),
                const SizedBox(height: 20),
                // Donut placeholder
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ShimmerBox.circle(size: 140),
                      Container(
                        width: 92,
                        height: 92,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // 3 Category list items
                _buildCategoryItemSkeleton(),
                const SizedBox(height: 10),
                _buildCategoryItemSkeleton(),
                const SizedBox(height: 10),
                _buildCategoryItemSkeleton(),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 4. Kartu Indikator Kesehatan Skeleton
          _buildCardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerBox.pill(width: 150, height: 16),
                    ShimmerBox.pill(width: 80, height: 22),
                  ],
                ),
                const SizedBox(height: 20),
                ShimmerBox.pill(height: 12),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ShimmerBox.pill(width: 30, height: 12),
                    ShimmerBox.pill(width: 90, height: 14),
                    ShimmerBox.pill(width: 30, height: 12),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0F172A),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildCategoryItemSkeleton() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              ShimmerBox(width: 36, height: 36, borderRadius: BorderRadius.circular(10)),
              const SizedBox(width: 12),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox.pill(width: 110, height: 14),
                  const SizedBox(height: 6),
                  ShimmerBox.pill(width: 50, height: 10),
                ],
              ),
            ],
          ),
          ShimmerBox.pill(width: 80, height: 14),
        ],
      ),
    );
  }
}
