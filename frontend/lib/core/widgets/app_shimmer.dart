import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Reusable Shimmer container providing a continuous light-sweep gradient animation.
class AppShimmer extends StatefulWidget {
  final Widget child;
  final Color baseColor;
  final Color highlightColor;
  final Duration duration;

  const AppShimmer({
    super.key,
    required this.child,
    this.baseColor = const Color(0xFFE8E8E8), // surfaceContainerHigh
    this.highlightColor = const Color(0xFFF9F9F9), // surfaceBright / white highlight
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            final double progress = _controller.value;
            // Sweep gradient across bounds from left to right
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
              colors: [
                widget.baseColor,
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
                widget.baseColor,
              ],
              transform: _SlidingGradientTransform(slidePercent: progress),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlidingGradientTransform extends GradientTransform {
  final double slidePercent;

  const _SlidingGradientTransform({required this.slidePercent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    // Shifts the gradient horizontally by 2.5x width to create smooth continuous sweep
    final double dx = bounds.width * (slidePercent * 2.5 - 1.0);
    return Matrix4.translationValues(dx, 0.0, 0.0);
  }
}

/// A single skeleton bone with configurable radius, height, and width.
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final BoxShape shape;
  final Color? color;

  const ShimmerBox({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.color,
  });

  /// Pill-shaped skeleton bone
  factory ShimmerBox.pill({
    double? width,
    required double height,
    Color? color,
  }) {
    return ShimmerBox(
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(999),
      color: color,
    );
  }

  /// Circular skeleton bone
  factory ShimmerBox.circle({
    required double size,
    Color? color,
  }) {
    return ShimmerBox(
      width: size,
      height: size,
      shape: BoxShape.circle,
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color ?? AppColors.surfaceContainerHighest.withValues(alpha: 0.7),
        shape: shape,
        borderRadius: shape == BoxShape.circle
            ? null
            : (borderRadius ?? BorderRadius.circular(12)),
      ),
    );
  }
}
