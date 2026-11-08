import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Komponen pendeteksi gesture swipe horizontal yang ringan (lightweight) dan responsif.
/// Mendukung gesture geser ke kiri (swipe left / next) dan geser ke kanan (swipe right / previous)
/// tanpa mengganggu scroll vertikal (SingleChildScrollView) maupun interaksi tombol anak (child taps).
class TactileSwipeDetector extends StatefulWidget {
  final Widget child;
  final VoidCallback? onSwipeLeft;
  final VoidCallback? onSwipeRight;
  final double swipeThreshold;
  final double velocityThreshold;
  final HitTestBehavior behavior;

  const TactileSwipeDetector({
    super.key,
    required this.child,
    this.onSwipeLeft,
    this.onSwipeRight,
    this.swipeThreshold = 35.0,
    this.velocityThreshold = 180.0,
    this.behavior = HitTestBehavior.translucent,
  });

  @override
  State<TactileSwipeDetector> createState() => _TactileSwipeDetectorState();
}

class _TactileSwipeDetectorState extends State<TactileSwipeDetector> {
  double _dragDistance = 0.0;

  void _onHorizontalDragStart(DragStartDetails details) {
    _dragDistance = 0.0;
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    _dragDistance += details.primaryDelta ?? 0.0;
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0.0;

    // Swipe Left (geser dari kanan ke kiri): velocity < -threshold atau drag < -threshold
    if (velocity < -widget.velocityThreshold || _dragDistance < -widget.swipeThreshold) {
      if (widget.onSwipeLeft != null) {
        HapticFeedback.lightImpact();
        widget.onSwipeLeft!();
      }
    }
    // Swipe Right (geser dari kiri ke kanan): velocity > threshold atau drag > threshold
    else if (velocity > widget.velocityThreshold || _dragDistance > widget.swipeThreshold) {
      if (widget.onSwipeRight != null) {
        HapticFeedback.lightImpact();
        widget.onSwipeRight!();
      }
    }

    _dragDistance = 0.0;
  }

  void _onHorizontalDragCancel() {
    _dragDistance = 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: widget.behavior,
      onHorizontalDragStart: _onHorizontalDragStart,
      onHorizontalDragUpdate: _onHorizontalDragUpdate,
      onHorizontalDragEnd: _onHorizontalDragEnd,
      onHorizontalDragCancel: _onHorizontalDragCancel,
      child: widget.child,
    );
  }
}
