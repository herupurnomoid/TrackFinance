import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Seksi Pemilihan Format Berkas Ekspor (PDF vs CSV)
/// Menggunakan konsep Full Ikon 3D lepas tanpa background color dan tanpa container,
/// dengan tactile selection feedback, badge status halus, dan performa ultra-ringan.
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

        const SizedBox(height: 12),

        // 2. Format 3D Icons Row (Full Ikon 3D Tanpa Container & Tanpa Background Color)
        Row(
          children: [
            // Pilihan 1: PDF 3D Icon Button
            Expanded(
              child: _Format3DIconButton(
                formatName: 'PDF',
                subtitle: showSubtitle ? 'Laporan visual' : null,
                assetPath: 'assets/icons/3d/pdf.webp',
                isSelected: isPdf,
                onTap: () => onFormatChanged('PDF'),
              ),
            ),
            const SizedBox(width: 16),

            // Pilihan 2: CSV 3D Icon Button
            Expanded(
              child: _Format3DIconButton(
                formatName: 'CSV',
                subtitle: showSubtitle ? 'Excel & Spreadsheet' : null,
                assetPath: 'assets/icons/3d/csv.webp',
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
}

/// Tombol Format Full Ikon 3D Mandiri (Tanpa Container Card & Tanpa Background Color)
class _Format3DIconButton extends StatefulWidget {
  final String formatName;
  final String? subtitle;
  final String assetPath;
  final bool isSelected;
  final VoidCallback onTap;

  const _Format3DIconButton({
    required this.formatName,
    this.subtitle,
    required this.assetPath,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_Format3DIconButton> createState() => _Format3DIconButtonState();
}

class _Format3DIconButtonState extends State<_Format3DIconButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isSelected = widget.isSelected;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        setState(() => _isPressed = true);
      },
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.90 : (isSelected ? 1.04 : 0.92),
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: AnimatedOpacity(
          opacity: isSelected ? 1.0 : (_isPressed ? 0.75 : 0.55),
          duration: const Duration(milliseconds: 140),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Full Visual Ikon 3D Tanpa Container & Tanpa Background Color
                Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Image.asset(
                      widget.assetPath,
                      width: 68,
                      height: 68,
                      fit: BoxFit.contain,
                      cacheWidth: 204,
                      cacheHeight: 204,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          widget.formatName == 'PDF'
                              ? Icons.picture_as_pdf_rounded
                              : Icons.table_chart_rounded,
                          size: 48,
                          color: widget.formatName == 'PDF'
                              ? const Color(0xFFDC2626)
                              : const Color(0xFF16A34A),
                        );
                      },
                    ),

                    // Badge Centang Status saat Terpilih (Halus & Elegan)
                    if (isSelected)
                      Positioned(
                        top: -2,
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
                              size: 13,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                // Nama Format Teks
                Text(
                  widget.formatName,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    letterSpacing: -0.2,
                    color: isSelected
                        ? const Color(0xFF131B2E)
                        : const Color(0xFF737686),
                  ),
                ),

                if (widget.subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.subtitle!,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: isSelected
                          ? const Color(0xFF434655)
                          : const Color(0xFF94A3B8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
