import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/animations.dart';

/// Tactile Delete Confirmation Dialog untuk Hapus Transaksi
/// Sesuai estetika Modern Tactile Finance dengan frosted backdrop blur,
/// badge peringatan merah, teks konfirmasi spesifik, dan 3D delete button.
class TransactionDeleteDialog extends StatelessWidget {
  final String categoryName;
  final String formattedAmount;
  final VoidCallback onConfirmDelete;

  const TransactionDeleteDialog({
    super.key,
    required this.categoryName,
    required this.formattedAmount,
    required this.onConfirmDelete,
  });

  static Future<bool?> show(
    BuildContext context, {
    required String categoryName,
    required String formattedAmount,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (context) => TransactionDeleteDialog(
        categoryName: categoryName,
        formattedAmount: formattedAmount,
        onConfirmDelete: () {
          Navigator.of(context).pop(true);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 342),
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
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
                color: Color(0x380F172A),
                blurRadius: 40,
                offset: Offset(0, 20),
              ),
              BoxShadow(
                color: Color(0x142563EB),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Icon Badge Peringatan Merah Timbul (56x56)
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFFEE2E2), // Red 100
                  border: Border.all(
                    color: const Color(0xFFFECACA),
                    width: 1.5,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x33DC2626),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.delete_outline_rounded,
                    size: 28,
                    color: Color(0xFFDC2626), // Expense Red
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // 2. Judul Dialog
              Text(
                'Hapus Transaksi?',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),

              const SizedBox(height: 10),

              // 3. Deskripsi Peringatan
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    height: 1.45,
                    color: const Color(0xFF64748B),
                  ),
                  children: [
                    const TextSpan(text: 'Transaksi '),
                    TextSpan(
                      text: categoryName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const TextSpan(text: ' sebesar '),
                    TextSpan(
                      text: formattedAmount,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                    const TextSpan(
                      text: ' akan dihapus secara permanen dari catatan keuangan Anda.',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // 4. Tombol Aksi: Batal vs Hapus Transaksi
              Row(
                children: [
                  // Tombol Batal
                  Expanded(
                    child: PressableScale(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop(false);
                      },
                      scaleFactor: 0.95,
                      translateY: 2.0,
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 1.0,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0A0F172A),
                              blurRadius: 4,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Batal',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Tombol Hapus Transaksi (Red 3D Button)
                  Expanded(
                    child: PressableScale(
                      onTap: () {
                        HapticFeedback.heavyImpact();
                        onConfirmDelete();
                      },
                      scaleFactor: 0.95,
                      translateY: 2.0,
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFFEF4444),
                              Color(0xFFDC2626),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x4DDC2626),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Hapus',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
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
