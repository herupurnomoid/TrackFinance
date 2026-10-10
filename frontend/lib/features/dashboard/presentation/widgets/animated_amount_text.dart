import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Widget teks nominal Rupiah dengan animasi bergulir (count-up / rolling animation)
/// yang bertransisi halus saat nilai berubah.
class AnimatedAmountText extends StatefulWidget {
  final int targetAmount;
  final TextStyle? style;
  final Duration duration;

  const AnimatedAmountText({
    super.key,
    required this.targetAmount,
    this.style,
    this.duration = const Duration(milliseconds: 700),
  });

  @override
  State<AnimatedAmountText> createState() => _AnimatedAmountTextState();
}

class _AnimatedAmountTextState extends State<AnimatedAmountText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  int _previousAmount = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = Tween<double>(
      begin: 0,
      end: widget.targetAmount.toDouble(),
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
    _previousAmount = widget.targetAmount;
  }

  @override
  void didUpdateWidget(covariant AnimatedAmountText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetAmount != widget.targetAmount) {
      _animation = Tween<double>(
        begin: _previousAmount.toDouble(),
        end: widget.targetAmount.toDouble(),
      ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller.forward(from: 0.0);
      _previousAmount = widget.targetAmount;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatRupiah(int number) {
    final absVal = number.abs().toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
    final prefix = number < 0 ? '-' : '';
    return '${prefix}Rp $absVal';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final currentInt = _animation.value.round();
        return Text(
          _formatRupiah(currentInt),
          style: widget.style ??
              GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.2,
              ),
        );
      },
    );
  }
}
