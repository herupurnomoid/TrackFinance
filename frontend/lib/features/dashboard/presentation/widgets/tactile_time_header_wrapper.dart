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

  const TactileTimeHeaderWrapper({
    super.key,
    required this.child,
    this.height,
    this.borderRadius,
    this.padding,
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
            // 1. Animasi Langit Waktu Dinamis (Pagi, Siang, Sore, Malam)
            Positioned.fill(
              child: HeaderTimeBackground(
                timeOfDay: time,
              ),
            ),

            // 2. Tekstur Garis Diagonal Taktil Halus
            Positioned.fill(
              child: const CustomPaint(
                painter: HeaderHatchPainter(),
              ),
            ),

            // 3. Konten Asli Header (SafeArea, Row, Back Button, Judul, dsb.)
            child,
          ],
        ),
      ),
    );
  }
}

/// CustomPainter untuk tekstur garis diagonal tactile halus di atas animasi langit
class HeaderHatchPainter extends CustomPainter {
  const HeaderHatchPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.035)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const spacing = 12.0;
    final total = size.width + size.height;

    for (double i = -size.height; i < total; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
