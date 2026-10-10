import 'package:flutter/material.dart';
import '../../../../core/widgets/app_shimmer.dart';

/// Shimmer Skeleton Loading untuk Dashboard Modern Tactile Finance
/// Memberikan efek gelombang kilau cahaya halus di atas tata letak layout yang presisi.
class DashboardTactileSkeleton extends StatelessWidget {
  const DashboardTactileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      baseColor: const Color(0xFFE2E8F0),
      highlightColor: const Color(0xFFF8FAFC),
      duration: const Duration(milliseconds: 1400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Section Skeleton
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF2563EB),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 38),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Baris 1: Greeting Skeleton & Logout Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShimmerBox.pill(width: 100, height: 12),
                            const SizedBox(height: 6),
                            ShimmerBox.pill(width: 160, height: 22),
                          ],
                        ),
                        ShimmerBox.circle(size: 44),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Baris 2: Month Pill & Nav Arrows
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ShimmerBox.pill(width: 160, height: 44),
                        Row(
                          children: [
                            ShimmerBox.circle(size: 44),
                            const SizedBox(width: 8),
                            ShimmerBox.circle(size: 44),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Baris 3: Summary Cards
                    ShimmerBox(
                      width: double.infinity,
                      height: 58,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    const SizedBox(height: 8),
                    ShimmerBox(
                      width: double.infinity,
                      height: 58,
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Content Panel Skeleton Overlapping Header
          Transform.translate(
            offset: const Offset(0, -24),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 4 Shortcuts Skeleton
                  Row(
                    children: List.generate(4, (index) {
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: index < 3 ? 8.0 : 0.0),
                          child: ShimmerBox(
                            width: double.infinity,
                            height: 76,
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 14),

                  // Search Box Skeleton
                  ShimmerBox(
                    width: double.infinity,
                    height: 46,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  const SizedBox(height: 12),

                  // Filter Pills Skeleton
                  ShimmerBox(
                    width: double.infinity,
                    height: 44,
                    borderRadius: BorderRadius.circular(100),
                  ),
                  const SizedBox(height: 22),

                  // Group Date Header Skeleton
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ShimmerBox.pill(width: 120, height: 14),
                      ShimmerBox.pill(width: 90, height: 14),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 4 Transaction Cards Skeleton
                  ...List.generate(4, (index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ShimmerBox(
                        width: double.infinity,
                        height: 70,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
