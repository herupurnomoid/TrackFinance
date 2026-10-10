import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'google_logo.dart';

/// Tombol Google Sign-In Modern Tactile Skeuomorphic
/// Mendukung state normal dengan specular highlight & elevated soft shadow,
/// feedback tactile press (scale & shadow inset),
/// dan state loading dengan spinner ring biru & teks "Menghubungkan...".
class TactileGoogleButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const TactileGoogleButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  State<TactileGoogleButton> createState() => _TactileGoogleButtonState();
}

class _TactileGoogleButtonState extends State<TactileGoogleButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final isInteractive = !widget.isLoading && widget.onPressed != null;

    return AnimatedScale(
      scale: _isPressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOutCubic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        height: 56,
        transform: Matrix4.translationValues(
          0,
          _isPressed || widget.isLoading ? 1.5 : 0,
          0,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFF8FAFC), // Slate 50
            ],
          ),
          border: Border.all(
            color: const Color(0xFFE2E8F0), // Neutral border
            width: 1.0,
          ),
          boxShadow: widget.isLoading || _isPressed
              ? [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ]
              : [
                  // Tactile elevated shadow stack
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.06),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(100),
            onHighlightChanged: (highlighted) {
              if (isInteractive) {
                setState(() {
                  _isPressed = highlighted;
                });
              }
            },
            onTap: isInteractive
                ? () {
                    HapticFeedback.lightImpact();
                    widget.onPressed?.call();
                  }
                : null,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: widget.isLoading
                  ? _buildLoadingState()
                  : _buildNormalState(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNormalState() {
    return KeyedSubtree(
      key: const ValueKey('normal_state'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const GoogleLogo(size: 22),
            const SizedBox(width: 12),
            Text(
              'Login dengan Google',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return KeyedSubtree(
      key: const ValueKey('loading_state'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Menghubungkan...',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
