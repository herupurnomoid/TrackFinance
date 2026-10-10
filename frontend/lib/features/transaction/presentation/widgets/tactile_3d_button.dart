import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Tombol Skeuomorfik dengan efek fisik 3D Extruded Button.
/// Memberikan sensasi tombol fisik yang benar-benar amblas (translate-y)
/// dan bayangannya menyusut ketika ditekan.
class Tactile3DButton extends StatefulWidget {
  final VoidCallback? onTap;
  final String text;
  final IconData? icon;
  final bool isEnabled;
  final bool isLoading;
  final Color? baseColor;
  final List<Color>? gradientColors;
  final Color? textColor;
  final Color? shadowColor;
  final double height;
  final double borderRadius;
  final double depth;

  const Tactile3DButton({
    super.key,
    required this.onTap,
    required this.text,
    this.icon,
    this.isEnabled = true,
    this.isLoading = false,
    this.baseColor,
    this.gradientColors,
    this.textColor,
    this.shadowColor,
    this.height = 54,
    this.borderRadius = 18,
    this.depth = 4,
  });

  @override
  State<Tactile3DButton> createState() => _Tactile3DButtonState();
}

class _Tactile3DButtonState extends State<Tactile3DButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool active = widget.isEnabled && widget.onTap != null && !widget.isLoading;

    final defaultGradient = [
      AppColors.tactilePrimary,     // #2563EB
      AppColors.tactilePrimaryDark, // #1E40AF
    ];

    final colors = active
        ? (widget.gradientColors ?? defaultGradient)
        : [
            const Color(0xFFCBD5E1),
            const Color(0xFF94A3B8),
          ];

    final effectiveTextColor = widget.textColor ?? Colors.white;
    final effectiveShadow = widget.shadowColor ??
        (active ? const Color(0xFF1E40AF).withValues(alpha: 0.38) : Colors.black.withValues(alpha: 0.08));

    final double currentOffset = (_isPressed && active) ? widget.depth : 0.0;
    final double currentShadowHeight = (_isPressed && active) ? 1.0 : widget.depth;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: active
          ? (_) {
              HapticFeedback.lightImpact();
              setState(() => _isPressed = true);
            }
          : null,
      onTapUp: active ? (_) => setState(() => _isPressed = false) : null,
      onTapCancel: active ? () => setState(() => _isPressed = false) : null,
      onTap: widget.onTap, // Allow tap to trigger validation error if disabled
      child: AnimatedScale(
        scale: (_isPressed && active) ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 90),
        curve: Curves.easeOutQuad,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeOutQuad,
          height: widget.height,
          transform: Matrix4.translationValues(0, currentOffset, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: colors,
          ),
          boxShadow: [
            // Extruded 3D depth shadow
            BoxShadow(
              color: effectiveShadow,
              blurRadius: (_isPressed && active) ? 4 : 12,
              offset: Offset(0, currentShadowHeight + 2),
            ),
            // Soft ambient atmospheric glow
            if (active && !_isPressed)
              BoxShadow(
                color: colors.first.withValues(alpha: 0.25),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
          ],
        ),
        child: Stack(
          children: [
            // Top specular rim highlight
            Positioned(
              top: 0,
              left: 2,
              right: 2,
              height: 1.5,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(widget.borderRadius),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withValues(alpha: active ? 0.45 : 0.2),
                      Colors.white.withValues(alpha: active ? 0.75 : 0.35),
                      Colors.white.withValues(alpha: active ? 0.45 : 0.2),
                    ],
                  ),
                ),
              ),
            ),

            // Content Center
            Center(
              child: widget.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (widget.icon != null) ...[
                          Icon(
                            widget.icon,
                            size: 20,
                            color: effectiveTextColor,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Text(
                          widget.text,
                          style: AppTextStyles.headlineSm.copyWith(
                            color: effectiveTextColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    ),
  );
}
}
