import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Kartu Indikator Kesehatan Keuangan Modern Tactile
/// Mendukung 3 Kondisi:
/// 1. Kosong (Empty State): Badge 'Belum ada data', knob di 0%, skor 'Skor: -'
/// 2. Mode Keluar (Defisit): Badge 'Minus Kritis', knob di 0% merah, skor 'Skor: -100.0%'
/// 3. Mode Masuk (Sehat): Badge 'Sehat', knob di 95% hijau, skor 'Skor: 95.0%'
class ReportHealthCard extends StatelessWidget {
  final double? healthScore;
  final int? score;
  final double? savingsRate;
  final String? healthStatus;
  final String? recommendation;
  final int? incomeTotal;
  final int? expenseTotal;
  final bool isEmpty;
  final bool isExpenseMode;

  const ReportHealthCard({
    super.key,
    this.healthScore,
    this.score,
    this.savingsRate,
    this.healthStatus,
    this.recommendation,
    this.incomeTotal,
    this.expenseTotal,
    this.isEmpty = true,
    this.isExpenseMode = true,
  });

  @override
  Widget build(BuildContext context) {
    // Penentuan Label Badge & Warna berdasarkan Tingkat Kesehatan Finansial:
    // - Sehat / Sangat Sehat: HIJAU
    // - Waspada: KUNING
    // - Minus / Kritis / Defisit: MERAH
    // - Kosong: ABU-ABU
    final String badgeLabel;
    final Color badgeBg;
    final Color badgeText;
    final String scoreDisplay;
    final Color scoreColor;
    final double targetPercent;
    final LinearGradient trackGradient;

    if (isEmpty) {
      badgeLabel = 'Belum ada data';
      badgeBg = const Color(0xFFEAEDFF);
      badgeText = const Color(0xFF737686);
      scoreDisplay = 'Skor: -';
      scoreColor = const Color(0xFF737686);
      targetPercent = 0.0;
      trackGradient = const LinearGradient(
        colors: [Color(0xFFE2E8F0), Color(0xFFCBD5E1)],
      );
    } else if (healthScore == -100.0 || (healthScore != null && healthScore! < 0)) {
      badgeLabel = 'Minus Kritis';
      badgeBg = const Color(0xFFFFDAD6);
      badgeText = const Color(0xFF93000A);
      scoreDisplay = 'Skor: -100.0%';
      scoreColor = const Color(0xFFDC2626);
      targetPercent = 0.0;
      trackGradient = const LinearGradient(
        colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
      );
    } else if (healthScore == 95.0 && score == null && healthStatus == null) {
      badgeLabel = 'Sehat';
      badgeBg = const Color(0xFFDCFCE7);
      badgeText = const Color(0xFF006329);
      scoreDisplay = 'Skor: 95.0%';
      scoreColor = const Color(0xFF006329);
      targetPercent = 0.95;
      trackGradient = const LinearGradient(
        colors: [Color(0xFF16A34A), Color(0xFF006329)],
      );
    } else {
      final effectiveScore = score ?? (healthScore?.round() ?? 75);
      final effectiveStatus = healthStatus ??
          (effectiveScore >= 75
              ? 'Sehat'
              : (effectiveScore >= 50
                  ? 'Waspada'
                  : (isExpenseMode ? 'Minus Kritis' : 'Sehat')));

      final isHealthy = effectiveStatus.contains('Sehat');
      final isWarning = effectiveStatus.contains('Waspada');

      if (isHealthy) {
        // Indikator Sehat -> Hijau
        badgeLabel = effectiveStatus;
        badgeBg = const Color(0xFFDCFCE7);
        badgeText = const Color(0xFF006329);
        scoreColor = const Color(0xFF006329);
        trackGradient = const LinearGradient(
          colors: [Color(0xFF16A34A), Color(0xFF006329)],
        );
      } else if (isWarning) {
        // Indikator Waspada -> Kuning / Amber
        badgeLabel = effectiveStatus;
        badgeBg = const Color(0xFFFEF3C7);
        badgeText = const Color(0xFFB45309);
        scoreColor = const Color(0xFFD97706);
        trackGradient = const LinearGradient(
          colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
        );
      } else {
        // Indikator Minus / Kritis / Defisit -> Merah
        badgeLabel = effectiveStatus;
        badgeBg = const Color(0xFFFFDAD6);
        badgeText = const Color(0xFF93000A);
        scoreColor = const Color(0xFFDC2626);
        trackGradient = const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
        );
      }

      scoreDisplay = savingsRate != null
          ? 'Skor: ${effectiveScore >= 0 ? effectiveScore : 0}'
          : 'Skor: $effectiveScore';
      targetPercent = (effectiveScore / 100.0).clamp(0.0, 1.0);
    }

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
            color: Color(0x0C2563EB),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Card: Judul dengan Ikon 3D & Badge Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Image.asset(
                      'assets/icons/3d/health.webp',
                      width: 22,
                      height: 22,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.favorite_rounded,
                        size: 20,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Indikator Kesehatan',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF131B2E),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badgeLabel,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: badgeText,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 2. Pointer Needle & Multi-Zone Segmented Gauge Meter (No Draggable Slider Knob)
          LayoutBuilder(
            builder: (context, constraints) {
              final totalWidth = constraints.maxWidth;
              const pointerWidth = 10.0;
              const pointerHeight = 6.0;

              return TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutCubic,
                tween: Tween<double>(begin: 0.0, end: targetPercent),
                builder: (context, currentPercent, child) {
                  final pointerLeft =
                      (totalWidth * currentPercent - (pointerWidth / 2))
                          .clamp(0.0, totalWidth - pointerWidth);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pointer Needle Caret Row (Menunjuk ke bar, bukan slider thumb)
                      SizedBox(
                        height: 8,
                        child: Stack(
                          children: [
                            if (!isEmpty)
                              Positioned(
                                left: pointerLeft,
                                child: CustomPaint(
                                  size: const Size(pointerWidth, pointerHeight),
                                  painter: _TrianglePointerPainter(color: scoreColor),
                                ),
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 2),

                      // Segmented 3-Zone Gauge Bar (Height: 14)
                      Container(
                        width: double.infinity,
                        height: 14,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: const Color(0xFFF1F5F9),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1.0,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0A0F172A),
                              blurRadius: 3,
                              offset: Offset(0, 1.5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: Stack(
                            children: [
                              // 3 Zones Background: Kritis (0-50%), Waspada (50-75%), Sehat (75-100%)
                              Row(
                                children: [
                                  Expanded(
                                    flex: 50,
                                    child: Container(
                                      color: isEmpty
                                          ? const Color(0xFFF1F5F9)
                                          : const Color(0xFFFEE2E2), // Soft Red
                                    ),
                                  ),
                                  Container(
                                    width: 1.5,
                                    color: Colors.white,
                                  ),
                                  Expanded(
                                    flex: 25,
                                    child: Container(
                                      color: isEmpty
                                          ? const Color(0xFFF1F5F9)
                                          : const Color(0xFFFEF3C7), // Soft Amber
                                    ),
                                  ),
                                  Container(
                                    width: 1.5,
                                    color: Colors.white,
                                  ),
                                  Expanded(
                                    flex: 25,
                                    child: Container(
                                      color: isEmpty
                                          ? const Color(0xFFF1F5F9)
                                          : const Color(0xFFDCFCE7), // Soft Green
                                    ),
                                  ),
                                ],
                              ),

                              // Active Fill Meter Bar (Progress gradient)
                              if (!isEmpty && currentPercent > 0)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    width: totalWidth * currentPercent,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      gradient: trackGradient,
                                      borderRadius: BorderRadius.circular(999),
                                      boxShadow: [
                                        BoxShadow(
                                          color: scoreColor.withValues(alpha: 0.35),
                                          blurRadius: 4,
                                          offset: const Offset(1, 0),
                                        ),
                                      ],
                                    ),
                                    child: Align(
                                      alignment: Alignment.topCenter,
                                      child: Container(
                                        height: 3,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.28),
                                          borderRadius: BorderRadius.circular(999),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),

          const SizedBox(height: 8),

          // 3. Metrik Bawah: 0%, Skor, 100%
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '0%',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF737686),
                  ),
                ),
                Text(
                  scoreDisplay,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: scoreColor,
                  ),
                ),
                Text(
                  '100%',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF737686),
                  ),
                ),
              ],
            ),
          ),

          // 4. Rekomendasi Finansial Cerdas Dinamis
          if (!isEmpty && recommendation != null && recommendation!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1.0,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 1),
                    child: Icon(
                      Icons.tips_and_updates_rounded,
                      size: 16,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      recommendation!,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF475569),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Custom Painter untuk jarum penunjuk nilai indikator (Pointer Caret Needle)
class _TrianglePointerPainter extends CustomPainter {
  final Color color;

  const _TrianglePointerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _TrianglePointerPainter oldDelegate) =>
      oldDelegate.color != color;
}
