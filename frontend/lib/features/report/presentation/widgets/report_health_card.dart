import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Kartu Indikator Kesehatan Keuangan Modern Tactile
/// Mendukung 3 Kondisi:
/// 1. Kosong (Empty State): Badge 'Belum ada data', knob di 0%, skor 'Skor: -'
/// 2. Mode Keluar (Defisit): Badge 'Minus Kritis', knob di 0% merah, skor 'Skor: -100.0%'
/// 3. Mode Masuk (Sehat): Badge 'Sehat', knob di 95% hijau, skor 'Skor: 95.0%'
class ReportHealthCard extends StatelessWidget {
  final double? healthScore;
  final bool isEmpty;
  final bool isExpenseMode;

  const ReportHealthCard({
    super.key,
    this.healthScore,
    this.isEmpty = true,
    this.isExpenseMode = true,
  });

  @override
  Widget build(BuildContext context) {
    // Penentuan Label Badge & Warna
    final String badgeLabel = isEmpty
        ? 'Belum ada data'
        : (isExpenseMode ? 'Minus Kritis' : 'Sehat');

    final Color badgeBg = isEmpty
        ? const Color(0xFFEAEDFF)
        : (isExpenseMode ? const Color(0xFFFFDAD6) : const Color(0xFFDCFCE7));

    final Color badgeText = isEmpty
        ? const Color(0xFF737686)
        : (isExpenseMode ? const Color(0xFF93000A) : const Color(0xFF006329));

    // Skor teks
    final String scoreDisplay = isEmpty
        ? 'Skor: -'
        : (isExpenseMode ? 'Skor: -100.0%' : 'Skor: 95.0%');

    final Color scoreColor = isEmpty
        ? const Color(0xFF737686)
        : (isExpenseMode ? const Color(0xFFDC2626) : const Color(0xFF006329));

    // Posisi Persentase Knob (0.0 hingga 1.0)
    final double targetPercent = isEmpty
        ? 0.0
        : (isExpenseMode ? 0.0 : 0.95);

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
          // 1. Header Card: Judul & Badge Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
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

          const SizedBox(height: 16),

          // 2. Inset Gauge Track dengan Animasi Knob & Track Fill
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SizedBox(
              height: 28, // ruang agar knob (28x28) muat sempurna
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final totalWidth = constraints.maxWidth;
                  const knobSize = 28.0;

                  return TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    tween: Tween<double>(begin: 0.0, end: targetPercent),
                    builder: (context, currentPercent, child) {
                      final knobLeft = (totalWidth - knobSize) * currentPercent;

                      return Stack(
                        alignment: Alignment.centerLeft,
                        children: [
                          // Recessed Inset Track Groove
                          Container(
                            width: double.infinity,
                            height: 12,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAEDFF),
                              borderRadius: BorderRadius.circular(999),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x140F172A),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(999),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  width: totalWidth * currentPercent,
                                  height: 12,
                                  decoration: BoxDecoration(
                                    gradient: isExpenseMode
                                        ? const LinearGradient(
                                            colors: [
                                              Color(0xFFEF4444),
                                              Color(0xFFDC2626),
                                            ],
                                          )
                                        : const LinearGradient(
                                            colors: [
                                              Color(0xFF16A34A),
                                              Color(0xFF006329),
                                            ],
                                          ),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Floating Tactile Knob Marker (28x28)
                          Positioned(
                            left: knobLeft,
                            child: Container(
                              width: knobSize,
                              height: knobSize,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x2E0F172A),
                                    blurRadius: 8,
                                    offset: Offset(0, 3),
                                  ),
                                  BoxShadow(
                                    color: Color(0x140F172A),
                                    blurRadius: 2,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: isEmpty
                                        ? const Color(0xFFC3C6D7)
                                        : (isExpenseMode
                                            ? const Color(0xFFDC2626)
                                            : const Color(0xFF006329)),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 4),

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
        ],
      ),
    );
  }
}
