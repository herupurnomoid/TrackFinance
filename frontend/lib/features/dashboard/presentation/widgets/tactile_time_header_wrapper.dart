import 'package:flutter/material.dart';
import 'header_time_theme.dart';
import 'header_time_background.dart';

/// Komponen pembungkus Header dengan animasi background dinamis sesuai waktu
/// (Pagi, Siang, Sore, Malam), tekstur diagonal tactile hatch, dan bayangan adaptif.
/// Menjaga seluruh layout tombol, judul, dan padding asli tetap 100% utuh.
class TactileTimeHeaderWrapper extends StatelessWidget {
  final Widget child;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool animateBackground;

  const TactileTimeHeaderWrapper({
    super.key,
    required this.child,
    this.height,
    this.borderRadius,
    this.padding,
    this.animateBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    final time = DashboardTimeOfDay.fromDateTime();
    final effectiveBorderRadius = borderRadius ??
        const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        );

    return Container(
      width: double.infinity,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: effectiveBorderRadius,
        boxShadow: [
          BoxShadow(
            color: time.skyGradientColors.first.withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: effectiveBorderRadius,
        child: Stack(
          children: [
            // 1. Animasi / Latar Langit Waktu Dinamis (Pagi, Siang, Sore, Malam)
            Positioned.fill(
              child: HeaderTimeBackground(
                timeOfDay: time,
                animate: animateBackground,
              ),
            ),

            // 2. Konten Asli Header (SafeArea, Row, Back Button, Judul, dsb.)
            child,
          ],
        ),
      ),
    );
  }
}
