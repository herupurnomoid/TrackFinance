import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Card Info File CSV yang Berhasil Diunggah
/// Menampilkan nama file, jumlah baris terdeteksi, dan tombol hapus file dengan micro-animasi.
class ImportUploadedFileCard extends StatefulWidget {
  final String fileName;
  final int totalRows;
  final VoidCallback onRemove;

  const ImportUploadedFileCard({
    super.key,
    required this.fileName,
    required this.totalRows,
    required this.onRemove,
  });

  @override
  State<ImportUploadedFileCard> createState() => _ImportUploadedFileCardState();
}

class _ImportUploadedFileCardState extends State<ImportUploadedFileCard> {
  bool _isDeletePressed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
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
            color: const Color(0xFF2563EB).withValues(alpha: 0.08),
            blurRadius: 16,
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
          // File Icon + Detail Filename & Baris
          Expanded(
            child: Row(
              children: [
                // Squircle File Icon Container
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBE1FF),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.description_rounded,
                      size: 24,
                      color: Color(0xFF004AC6),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // File Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.fileName,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF131B2E),
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${widget.totalRows} baris terdeteksi',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF434655),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Delete / Close Button dengan Animasi Tekan
          GestureDetector(
            onTapDown: (_) => setState(() => _isDeletePressed = true),
            onTapUp: (_) => setState(() => _isDeletePressed = false),
            onTapCancel: () => setState(() => _isDeletePressed = false),
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onRemove();
            },
            child: AnimatedScale(
              scale: _isDeletePressed ? 0.90 : 1.0,
              duration: const Duration(milliseconds: 120),
              curve: Curves.easeOutCubic,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFDAE2FD),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF131B2E).withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: Color(0xFF737686),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
