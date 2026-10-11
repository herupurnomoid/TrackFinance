import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Komponen visual Logo Aplikasi TrackFinance
/// Mendukung render SVG vector atau PNG high-resolution dengan filter drop-shadow lengkap.
class AppLogo extends StatelessWidget {
  final double size;
  final bool useSvg;
  final BoxFit fit;

  const AppLogo({
    super.key,
    this.size = 48.0,
    this.useSvg = false,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    if (useSvg) {
      return SvgPicture.asset(
        'assets/icons/app_logo.svg',
        width: size,
        height: size,
        fit: fit,
      );
    }

    return Image.asset(
      'assets/icons/app_logo.png',
      width: size,
      height: size,
      fit: fit,
      filterQuality: FilterQuality.high,
    );
  }
}
