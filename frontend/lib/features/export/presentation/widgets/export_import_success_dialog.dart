import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dialog Sukses Skeuomorphic untuk Ekspor & Impor Transaksi
/// Menerapkan GoPay Wealth / Modern Tactile Finance aesthetic:
/// - Darkened blur backdrop (sigma 6)
/// - Checkmark badge pendar hijau 64x64
/// - Heading dampak ringkas (cth: "120 transaksi diimpor" / "24 transaksi diekspor")
/// - Tombol tactile utama "Selesai"
class ExportImportSuccessDialog extends StatefulWidget {
  final String message;
  final VoidCallback onDone;

  const ExportImportSuccessDialog({
    super.key,
    required this.message,
    required this.onDone,
  });

  static Future<void> show(
    BuildContext context, {
    required String message,
    VoidCallback? onDone,
  }) {
    return showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss Dialog',
      barrierColor: const Color(0xFF0F172A).withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 250),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 6 * animation.value,
            sigmaY: 6 * animation.value,
          ),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.85, end: 1.0).animate(curved),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          ),
        );
      },
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: ExportImportSuccessDialog(
            message: message,
            onDone: onDone ?? () {
              Navigator.of(context).pop();
            },
          ),
        );
      },
    );
  }

  @override
  State<ExportImportSuccessDialog> createState() =>
      _ExportImportSuccessDialogState();
}

class _ExportImportSuccessDialogState extends State<ExportImportSuccessDialog> {
  bool _isButtonPressed = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        width: 320,
        margin: const EdgeInsets.symmetric(horizontal: 24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFF8FAFC),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.95),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.25),
              blurRadius: 40,
              offset: const Offset(0, 20),
              spreadRadius: -15,
            ),
            BoxShadow(
              color: const Color(0xFF2563EB).withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(0, 10),
              spreadRadius: -8,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 1. Tactile Checkmark Badge Container (64x64)
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF16A34A), // Green-600
                    Color(0xFF15803D), // Green-700
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.45),
                  width: 1.5,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x7316A34A),
                    blurRadius: 16,
                    offset: Offset(0, 8),
                    spreadRadius: -4,
                  ),
                  BoxShadow(
                    color: Color(0x4D15803D),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                    spreadRadius: -2,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.check_rounded,
                  size: 34,
                  color: Colors.white,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // 2. Concise Impact Heading
            Text(
              widget.message,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.3,
                height: 1.25,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // 3. Primary Action CTA Button ("Selesai")
            GestureDetector(
              onTapDown: (_) => setState(() => _isButtonPressed = true),
              onTapUp: (_) => setState(() => _isButtonPressed = false),
              onTapCancel: () => setState(() => _isButtonPressed = false),
              onTap: () {
                HapticFeedback.lightImpact();
                widget.onDone();
              },
              child: AnimatedScale(
                scale: _isButtonPressed ? 0.98 : 1.0,
                duration: const Duration(milliseconds: 100),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF2563EB), // Primary Blue
                        Color(0xFF1D4ED8), // Darker Blue
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                      width: 1,
                    ),
                    boxShadow: _isButtonPressed
                        ? const [
                            BoxShadow(
                              color: Color(0x4D0F172A),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ]
                        : const [
                            BoxShadow(
                              color: Color(0x522563EB),
                              blurRadius: 16,
                              offset: Offset(0, 6),
                            ),
                            BoxShadow(
                              color: Color(0x331D4ED8),
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                  ),
                  child: Center(
                    child: Text(
                      'Selesai',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
