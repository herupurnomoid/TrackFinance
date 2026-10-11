import 'package:flutter/material.dart';
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
    required this.transactionCount,
    required this.estimatedTotal,
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

        // 2. Sub-Segmented Selector ("Rentang", "Bulan", "Tahun")
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFE2E7FF),
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14131B2E),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              _buildPeriodTab('Rentang'),
              const SizedBox(width: 4),
              _buildPeriodTab('Bulan'),
              const SizedBox(width: 4),
              _buildPeriodTab('Tahun'),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // 3. Konten Filter Berdasarkan Opsi Terpilih
        if (isRangeMode) ...[
          // MODE RENTANG (2-Kolom Tanggal Dari & Sampai)
          Row(
            children: [
              Expanded(
                child: _buildDateCard(
                  label: 'Dari',
                  icon: Icons.calendar_today_rounded,
                  dateText: _formatDateShort(startDate),
                  onTap: onPickStartDate,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildDateCard(
                  label: 'Sampai',
                  icon: Icons.event_rounded,
                  dateText: _formatDateShort(endDate),
                  onTap: onPickEndDate,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Transaction Count Pill Badge
          _buildTransactionCountPill(transactionCount),
        ] else if (isMonthMode) ...[
          // MODE BULAN (Single Selector Card: Contoh "Oktober 2026")
          _buildSelectorCard(
            title: _formatMonthYear(selectedMonth),
            icon: Icons.calendar_month_rounded,
            onTap: onPickMonth,
          ),

          const SizedBox(height: 10),

          // Transaction Count Pill Badge
          _buildTransactionCountPill(transactionCount),
        ] else ...[
          // MODE TAHUN (Single Selector Card: Contoh "Tahun 2026")
          _buildSelectorCard(
            title: 'Tahun ${selectedMonth.year}',
            icon: Icons.date_range_rounded,
            onTap: onPickYear ?? onPickMonth,
          ),

          const SizedBox(height: 10),

          // Transaction Count Pill Badge
          _buildTransactionCountPill(transactionCount),
        ],
      ],
    );
  }

  /// Transaction Count Pill Badge (receipt_long + "X transaksi")
  Widget _buildTransactionCountPill(int count) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFFDAE2FD),
          borderRadius: BorderRadius.circular(999),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A131B2E),
              blurRadius: 2,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.receipt_long_rounded,
              size: 14,
              color: Color(0xFF004AC6),
            ),
            const SizedBox(width: 6),
            Text(
              '$count transaksi',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF004AC6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodTab(String title) {
    final bool isSelected = activePeriod == title;
    return Expanded(
      child: PressableScale(
        onTap: () {
          if (!isSelected) {
            onPeriodChanged(title);
          }
        },
        scaleFactor: 0.94,
        translateY: 1.5,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF2563EB),
                      Color(0xFF004AC6),
                    ],
                  )
                : null,
            color: isSelected ? null : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? const Color(0x3D2563EB)
                    : const Color(0x0A131B2E),
                blurRadius: isSelected ? 8 : 2,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF434655),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Field Selector Card Tactile untuk Pemilihan Bulan/Tahun Sesuai Mockup
  Widget _buildSelectorCard({
    required String title,
    String? subtitle,
    IconData icon = Icons.calendar_month_rounded,
    required VoidCallback onTap,
  }) {
    return PressableScale(
      onTap: onTap,
      scaleFactor: 0.97,
      translateY: 2.0,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withValues(alpha: 0.08),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: const Color(0xFF131B2E).withValues(alpha: 0.04),
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Ikon Squircle Kalender + Label Bulan/Tahun
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDAE2FD),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 2,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          icon,
                          size: 20,
                          color: const Color(0xFF004AC6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF131B2E),
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (subtitle != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: const Color(0xFF434655),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Chevron Down
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 22,
                color: Color(0xFF434655),
              ),
            ],
          ),
        ),
      );
  }

  Widget _buildDateCard({
    required String label,
    required IconData icon,
    required String dateText,
    required VoidCallback onTap,
  }) {
    return PressableScale(
      onTap: onTap,
      scaleFactor: 0.96,
      translateY: 2.0,
      child: Container(
        padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Color(0xFFF2F3FF),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
              BoxShadow(
                color: const Color(0xFF131B2E).withValues(alpha: 0.03),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF737686),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAEDFF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        size: 14,
                        color: const Color(0xFF004AC6),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      dateText,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF131B2E),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
  }
}
