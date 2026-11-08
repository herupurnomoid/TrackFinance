import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/animations.dart';

/// Seksi Filter Periode Waktu (Rentang, Bulan, Tahun) untuk Halaman Ekspor
/// Menampilkan kontrol selektor mode sub-segmented, kartu input tanggal 2-kolom
/// atau kartu pemilih bulan/tahun tunggal sesuai referensi mockup.
class ExportRangeFilterSection extends StatelessWidget {
  final String activePeriod; // 'Rentang', 'Bulan', 'Tahun'
  final ValueChanged<String> onPeriodChanged;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime selectedMonth;
  final VoidCallback onPickStartDate;
  final VoidCallback onPickEndDate;
  final VoidCallback onPickMonth;
  final VoidCallback? onPickYear;
  final int transactionCount;
  final double estimatedTotal;

  const ExportRangeFilterSection({
    super.key,
    required this.activePeriod,
    required this.onPeriodChanged,
    required this.startDate,
    required this.endDate,
    required this.selectedMonth,
    required this.onPickStartDate,
    required this.onPickEndDate,
    required this.onPickMonth,
    this.onPickYear,
    this.transactionCount = 0,
    this.estimatedTotal = 0,
  });

  String _formatDateShort(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final day = date.day.toString().padLeft(2, '0');
    final month = months[date.month - 1];
    return '$day $month ${date.year}';
  }

  String _formatMonthYear(DateTime date) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final bool isRangeMode = activePeriod == 'Rentang';
    final bool isMonthMode = activePeriod == 'Bulan';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Header Periode
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'Periode',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF131B2E),
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // 2. Sub-Segmented Selector ("Rentang", "Bulan", "Tahun") dengan Smooth Sliding Active Pill
        Container(
          width: double.infinity,
          height: 48,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFDAE2FD),
            borderRadius: BorderRadius.circular(999),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14131B2E),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Sliding Active Pill Background yang Mulus (Curves.easeOutCubic)
              AnimatedAlign(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOutCubic,
                alignment: _getAlignmentForPeriod(activePeriod),
                child: FractionallySizedBox(
                  widthFactor: 1.0 / 3.0,
                  child: Container(
                    height: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF2563EB), // Primary Blue
                          Color(0xFF004AC6), // Deep Blue
                        ],
                      ),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                        width: 1,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x472563EB),
                          blurRadius: 10,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Clickable Tab Buttons (Rentang, Bulan, Tahun)
              Row(
                children: [
                  _buildPeriodTab('Rentang'),
                  _buildPeriodTab('Bulan'),
                  _buildPeriodTab('Tahun'),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // 3. Konten Filter Berdasarkan Opsi Terpilih
        if (isRangeMode) ...[
          // MODE RENTANG (2-Kolom Tanggal Dari & Sampai dengan Button Pill Style Halaman Laporan)
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 6),
                      child: Text(
                        'Dari',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                    _buildReportStyleDatePill(
                      dateText: _formatDateShort(startDate),
                      onTap: onPickStartDate,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 6),
                      child: Text(
                        'Sampai',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                    _buildReportStyleDatePill(
                      dateText: _formatDateShort(endDate),
                      onTap: onPickEndDate,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ] else if (isMonthMode) ...[
          // MODE BULAN (Button Pill Style Halaman Laporan)
          Align(
            alignment: Alignment.centerLeft,
            child: _buildReportStyleDatePill(
              dateText: _formatMonthYear(selectedMonth),
              onTap: onPickMonth,
              isFullWidth: false,
            ),
          ),
        ] else ...[
          // MODE TAHUN (Button Pill Style Halaman Laporan)
          Align(
            alignment: Alignment.centerLeft,
            child: _buildReportStyleDatePill(
              dateText: 'Tahun ${selectedMonth.year}',
              onTap: onPickYear ?? onPickMonth,
              isFullWidth: false,
            ),
          ),
        ],
      ],
    );
  }

  Alignment _getAlignmentForPeriod(String period) {
    switch (period) {
      case 'Rentang':
        return Alignment.centerLeft;
      case 'Tahun':
        return Alignment.centerRight;
      case 'Bulan':
      default:
        return Alignment.center;
    }
  }

  Widget _buildPeriodTab(String title) {
    final bool isSelected = activePeriod == title;
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          if (!isSelected) {
            HapticFeedback.lightImpact();
            onPeriodChanged(title);
          }
        },
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected ? Colors.white : const Color(0xFF434655),
              letterSpacing: -0.1,
            ),
            child: Text(title),
          ),
        ),
      ),
    );
  }

  /// Tombol Date Picker bergaya Pill Tactile seperti pada Halaman Laporan
  Widget _buildReportStyleDatePill({
    required String dateText,
    required VoidCallback onTap,
    bool isFullWidth = true,
  }) {
    return PressableScale(
      onTap: onTap,
      scaleFactor: 0.95,
      translateY: 2.0,
      child: Container(
        width: isFullWidth ? double.infinity : null,
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFF8FAFC),
            ],
          ),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1.0,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x142563EB),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
            BoxShadow(
              color: Color(0x0D0F172A),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                dateText,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF131B2E),
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.calendar_month_rounded,
              size: 18,
              color: Color(0xFF2563EB),
            ),
          ],
        ),
      ),
    );
  }
}
