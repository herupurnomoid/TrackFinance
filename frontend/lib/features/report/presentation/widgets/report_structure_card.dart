import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/animations.dart';
import '../../data/report_data_model.dart';

/// Kartu Struktur Transaksi Modern Tactile
/// Menyediakan toggle segmented 'Keluar' dan 'Masuk', Multi-slice Donut Chart,
/// serta daftar kartu timbul kategori dengan persentase dan nominal.
class ReportStructureCard extends StatelessWidget {
  final bool isExpenseTab;
  final ValueChanged<bool> onTabChanged;
  final int totalAmount;
  final bool isEmpty;
  final List<ReportCategoryItem>? categoryItems;

  const ReportStructureCard({
    super.key,
    required this.isExpenseTab,
    required this.onTabChanged,
    this.totalAmount = 0,
    this.isEmpty = true,
    this.categoryItems,
  });

  @override
  Widget build(BuildContext context) {
    final items = categoryItems ??
        (isExpenseTab
            ? ReportDataStore.expenseCategoriesOktober
            : ReportDataStore.incomeCategoriesOktober);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Color(0xFFF8FAFC),
          ],
        ),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x142563EB),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Color(0x0D0F172A),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Card: Judul & Segmented Toggle (Keluar / Masuk)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Struktur Transaksi',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF131B2E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _buildSegmentedToggle(),
            ],
          ),

          const SizedBox(height: 16),

          // 2. Donut Chart (Empty vs Populated Multi-Slice)
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: SizedBox(
                width: 176,
                height: 176,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Donut Chart Canvas
                    CustomPaint(
                      size: const Size(176, 176),
                      painter: isEmpty
                          ? _EmptyDonutPainter()
                          : _MultiSliceDonutPainter(items: items),
                    ),

                    // Teks Tengah (Nominal & Subtitle)
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isEmpty
                              ? 'Total Terkategori'
                              : (isExpenseTab ? 'Pengeluaran' : 'Pemasukan'),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          ReportDataStore.formatCurrency(totalAmount),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: isEmpty
                                ? const Color(0xFF737686)
                                : (isExpenseTab
                                    ? const Color(0xFFDC2626)
                                    : const Color(0xFF006329)),
                            letterSpacing: -0.3,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Daftar Kartu Kategori (Hanya ditampilkan jika tidak kosong)
          if (!isEmpty) ...[
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final cat = items[index];
                return _buildCategoryItemRow(cat);
              },
            ),
          ],
        ],
      ),
    );
  }

  /// Segmented Control Inset Pill (Keluar vs Masuk)
  Widget _buildSegmentedToggle() {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: const Color(0xFFEAEDFF),
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0F172A),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Tab Keluar
          _buildSegmentButton(
            label: 'Keluar',
            isSelected: isExpenseTab,
            activeGradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFEF4444),
                Color(0xFFDC2626),
              ],
            ),
            activeColor: Colors.white,
            shadowColor: const Color(0x4DDC2626),
            onTap: () {
              if (!isExpenseTab) {
                HapticFeedback.lightImpact();
                onTabChanged(true);
              }
            },
          ),

          // Tab Masuk
          _buildSegmentButton(
            label: 'Masuk',
            isSelected: !isExpenseTab,
            activeGradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF16A34A),
                Color(0xFF006329),
              ],
            ),
            activeColor: Colors.white,
            shadowColor: const Color(0x4D006329),
            onTap: () {
              if (isExpenseTab) {
                HapticFeedback.lightImpact();
                onTabChanged(false);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentButton({
    required String label,
    required bool isSelected,
    required Gradient activeGradient,
    required Color activeColor,
    required Color shadowColor,
    required VoidCallback onTap,
  }) {
    return PressableScale(
      onTap: onTap,
      scaleFactor: 0.94,
      translateY: 1.5,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          gradient: isSelected ? activeGradient : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: shadowColor,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: isSelected ? activeColor : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  /// Kartu Timbul Kategori (Tactile Item Row)
  Widget _buildCategoryItemRow(ReportCategoryItem cat) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => HapticFeedback.selectionClick(),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Color(0xFFF8FAFC),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F2563EB),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
              BoxShadow(
                color: Color(0x0A0F172A),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Kiri: Icon Well + Nama Kategori + Badge Persentase
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: cat.containerColor,
                        borderRadius: BorderRadius.circular(11),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0F0F172A),
                            blurRadius: 3,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          cat.icon,
                          size: 19,
                          color: cat.iconColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            cat.name,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 1.5,
                            ),
                            decoration: BoxDecoration(
                              color: cat.containerColor,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              '${cat.percentage.toStringAsFixed(1)}%',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: cat.badgeTextColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Kanan: Nominal + Ikon Chevron
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    ReportDataStore.formatCurrency(cat.amount),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: Color(0xFF737686),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// CustomPainter untuk Donut Ring Empty State
class _EmptyDonutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 14;

    final paint = Paint()
      ..color = const Color(0xFFC3C6D7).withValues(alpha: 0.65)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 22;

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// CustomPainter untuk Donut Ring Populated (Multi-Slice dengan Irisan Berwarna)
class _MultiSliceDonutPainter extends CustomPainter {
  final List<ReportCategoryItem> items;

  const _MultiSliceDonutPainter({required this.items});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 14;
    final strokeWidth = 22.0;

    // Track Background Halus
    final bgPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    if (items.isEmpty) return;

    // Mulai dari atas (-90 derajat atau -pi / 2)
    double startAngle = -math.pi / 2;
    const double gapAngle = 0.04; // celah halus antar irisan

    for (final item in items) {
      final sweepAngle = (item.percentage / 100.0) * (2 * math.pi) - gapAngle;

      if (sweepAngle > 0) {
        final slicePaint = Paint()
          ..color = item.sliceColor
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = strokeWidth;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          startAngle + (gapAngle / 2),
          sweepAngle,
          false,
          slicePaint,
        );
      }

      startAngle += (item.percentage / 100.0) * (2 * math.pi);
    }
  }

  @override
  bool shouldRepaint(covariant _MultiSliceDonutPainter oldDelegate) =>
      oldDelegate.items != items;
}
