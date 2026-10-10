import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Ringkasan Validasi Data CSV (Valid, Duplikat, Bermasalah)
/// Menampilkan 3 kartu statistik grid dan aksi "Lihat baris bermasalah".
class ImportValidationStatsRow extends StatelessWidget {
  final int validCount;
  final int duplicateCount;
  final int errorCount;
  final VoidCallback onViewProblematicRows;

  const ImportValidationStatsRow({
    super.key,
    required this.validCount,
    required this.duplicateCount,
    required this.errorCount,
    required this.onViewProblematicRows,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 3-Column Stat Grid
        Row(
          children: [
            // 1. Valid (Hijau)
            Expanded(
              child: _buildStatCard(
                count: validCount.toString(),
                label: 'VALID',
                countColor: const Color(0xFF006329),
              ),
            ),
            const SizedBox(width: 10),

            // 2. Duplikat (Biru)
            Expanded(
              child: _buildStatCard(
                count: duplicateCount.toString(),
                label: 'DUPLIKAT',
                countColor: const Color(0xFF004AC6),
              ),
            ),
            const SizedBox(width: 10),

            // 3. Bermasalah (Merah)
            Expanded(
              child: _buildStatCard(
                count: errorCount.toString(),
                label: 'BERMASALAH',
                countColor: const Color(0xFFBA1A1A),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Action Link: "Lihat baris bermasalah >"
        Align(
          alignment: Alignment.centerRight,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onViewProblematicRows,
              borderRadius: BorderRadius.circular(999),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Lihat baris bermasalah',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF004AC6),
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: Color(0xFF004AC6),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String count,
    required String label,
    required Color countColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Color(0xFFF2F3FF),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: const Color(0xFF131B2E).withValues(alpha: 0.04),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: countColor,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF434655),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
