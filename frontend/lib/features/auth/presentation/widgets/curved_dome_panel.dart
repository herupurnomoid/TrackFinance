import 'package:flutter/material.dart';

/// Panel lengkung kubah bawah (curved dome sheet) yang menimpa ilustrasi atas
/// dengan drop shadow halus dan kurva kubah anggun sesuai referensi desain.
class CurvedDomePanel extends StatelessWidget {
  final Widget child;
  final double domeHeight;

  const CurvedDomePanel({
    super.key,
    required this.child,
    this.domeHeight = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CurvedDomeShadowPainter(domeHeight: domeHeight),
      child: ClipPath(
        clipper: _CurvedDomeClipper(domeHeight: domeHeight),
        child: Container(
          width: double.infinity,
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.only(top: domeHeight),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _CurvedDomeClipper extends CustomClipper<Path> {
  final double domeHeight;

  const _CurvedDomeClipper({required this.domeHeight});

  @override
  Path getClip(Size size) {
    final path = Path();
    // Mulai dari kiri atas lengkungan kubah
    path.moveTo(0, domeHeight);
    // Lengkungan kubah ke atas di tengah
    path.quadraticBezierTo(
      size.width / 2,
      0,
      size.width,
      domeHeight,
    );
    // Turun ke pojok kanan bawah
    path.lineTo(size.width, size.height);
    // Ke pojok kiri bawah
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant _CurvedDomeClipper oldClipper) {
    return oldClipper.domeHeight != domeHeight;
  }
}

class _CurvedDomeShadowPainter extends CustomPainter {
  final double domeHeight;

  const _CurvedDomeShadowPainter({required this.domeHeight});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    path.moveTo(0, domeHeight);
    path.quadraticBezierTo(
      size.width / 2,
      0,
      size.width,
      domeHeight,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    // Gambar ambient drop shadow melengkung ke atas
    canvas.drawShadow(
      path,
      const Color(0xFF0F172A).withValues(alpha: 0.12),
      12.0,
      true,
    );
  }

  @override
  bool shouldRepaint(covariant _CurvedDomeShadowPainter oldDelegate) {
    return oldDelegate.domeHeight != domeHeight;
  }
}
