import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Seksi Pemilihan Format Berkas Ekspor (PDF vs CSV)
/// Menerapkan 2 ubin squircle besar dengan badge centang pin, efek seleksi tactile,
/// dan tampilan yang fleksibel sesuai mode tampilan (Rentang vs Bulan).
class ExportFormatSelector extends StatelessWidget {
  final String selectedFormat; // 'CSV' atau 'PDF'
  final ValueChanged<String> onFormatChanged;
  final bool showSubtitle;
  final bool showNoteCard;

  const ExportFormatSelector({
    super.key,
    required this.selectedFormat,
    required this.onFormatChanged,
    this.showSubtitle = false,
    this.showNoteCard = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCsv = selectedFormat == 'CSV';
    final bool isPdf = selectedFormat == 'PDF';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Header Format
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                'Format',
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
            if (showSubtitle)
              Text(
                'Pilih 1 jenis file',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF737686),
                ),
              ),
          ],
        ),

        const SizedBox(height: 10),

        // 2. Format Tiles Grid (2 Squircles dengan Tinggi 104px)
        Row(
          children: [
            // Ubin 1: PDF
            Expanded(
              child: _buildFormatCard(
                formatName: 'PDF',
                subtitle: showSubtitle ? 'Laporan visual' : null,
                icon: Icons.picture_as_pdf_rounded,
                iconBgColor: const Color(0xFFFFDAD6),
                iconColor: const Color(0xFFBA1A1A),
                isSelected: isPdf,
                onTap: () => onFormatChanged('PDF'),
              ),
            ),
            const SizedBox(width: 12),

            // Ubin 2: CSV
            Expanded(
              child: _buildFormatCard(
                formatName: 'CSV',
                subtitle: showSubtitle ? 'Excel & Spreadsheet' : null,
                icon: Icons.table_chart_rounded,
                iconBgColor: const Color(0xFFDCFCE7),
                iconColor: const Color(0xFF006329),
                isSelected: isCsv,
                onTap: () => onFormatChanged('CSV'),
              ),
            ),
          ],
        ),

        // 3. Visual Note Preview Block (Opsional)
        if (showNoteCard) ...[
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFDAE2FD).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFC3C6D7).withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 18,
                  color: Color(0xFF546065),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isCsv
                        ? 'File CSV menyertakan kolom tanggal, kategori, nominal, catatan, dan jenis transaksi yang siap dianalisis di Excel atau Google Sheets.'
                        : 'File PDF menyertakan ringkasan visual, grafik alokasi pengeluaran, dan rincian transaksi siap cetak.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF434655),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFormatCard({
    required String formatName,
    String? subtitle,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        constraints: const BoxConstraints(minHeight: 104),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isSelected
                ? [
                    const Color(0xFFEAEDFF),
                    const Color(0xFFDAE2FD).withValues(alpha: 0.7),
                  ]
                : [
                    Colors.white,
                    const Color(0xFFF2F3FF),
                  ],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF004AC6)
                : const Color(0xFFE2E8F0),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.14),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: const Color(0xFF131B2E).withValues(alpha: 0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Checked Indicator Pin (Top Right saat terpilih)
            if (isSelected)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Color(0xFF004AC6),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

            // Card Body Center
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Circular Icon Well
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: iconColor.withValues(alpha: 0.15),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        size: 20,
                        color: iconColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Format Name
                  Text(
                    formatName,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? const Color(0xFF131B2E)
                          : const Color(0xFF434655),
                    ),
                  ),

                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF737686),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
