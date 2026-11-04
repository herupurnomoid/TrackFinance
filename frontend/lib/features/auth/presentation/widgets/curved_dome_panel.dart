import 'package:flutter/material.dart';

/// Panel putih bawah yang menimpa ilustrasi atas dengan sudut lengkungan
/// Radius 28px dan ambient shadow lembut, selaras dengan lengkungan header halaman Profile.
class CurvedDomePanel extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double? domeHeight;

  const CurvedDomePanel({
    super.key,
    required this.child,
    this.borderRadius = 28.0,
    this.domeHeight,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F0F172A),
            blurRadius: 20,
            offset: Offset(0, -6),
          ),
          BoxShadow(
            color: Color(0x0F0F172A),
            blurRadius: 4,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
        ),
        child: child,
      ),
    );
  }
}
