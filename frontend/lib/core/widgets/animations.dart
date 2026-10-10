import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Fade + slide-up + subtle scale entrance, delayed by [index] * [stagger].
///
/// Delay is implemented with an [Interval] inside a single controller
/// (instead of `Future.delayed`) so no pending Timers are left behind.
class StaggeredEntrance extends StatefulWidget {
  final Widget child;
  final int index;
  final Duration stagger;
  final Duration duration;
  final double offsetY;

  const StaggeredEntrance({
    super.key,
    required this.child,
    this.index = 0,
    this.stagger = const Duration(milliseconds: 80),
    this.duration = const Duration(milliseconds: 650),
    this.offsetY = 28,
  });

  @override
  State<StaggeredEntrance> createState() => _StaggeredEntranceState();
}

class _StaggeredEntranceState extends State<StaggeredEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _slide;

  @override
  void initState() {
    super.initState();
    final delayMs = widget.stagger.inMilliseconds * widget.index;
    final totalMs = delayMs + widget.duration.inMilliseconds;
    final start = totalMs == 0 ? 0.0 : delayMs / totalMs;

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: totalMs),
    );
    _fade = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, 1.0, curve: Curves.easeOut),
    );
    _slide = CurvedAnimation(
      parent: _controller,
      curve: Interval(start, 1.0, curve: Curves.easeOutCubic),
    );
    _controller.forward();
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
      child: widget.child,
      builder: (context, child) {
        final t = _slide.value;
        return Opacity(
          opacity: _fade.value,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * widget.offsetY),
            child: Transform.scale(scale: 0.96 + 0.04 * t, child: child),
          ),
        );
      },
    );
  }
}

/// Animated count-up for Rupiah-like strings, e.g. `'Rp 9.800.000'`.
/// Renders `'$prefix<formatted number>'` and ends exactly on the target value.
class CountUpText extends StatelessWidget {
  final String value;
  final String prefix;
  final TextStyle? style;
  final Duration duration;
  final Duration delay;

  const CountUpText({
    super.key,
    required this.value,
    this.prefix = '',
    this.style,
    this.duration = const Duration(milliseconds: 1400),
    this.delay = Duration.zero,
  });

  static int _parse(String raw) =>
      int.tryParse(raw.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  static String _format(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final target = _parse(value);
    final total = delay + duration;
    final start = total.inMilliseconds == 0
        ? 0.0
        : delay.inMilliseconds / total.inMilliseconds;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: total,
      builder: (context, t, _) {
        final eased = Interval(
          start,
          1.0,
          curve: Curves.easeOutExpo,
        ).transform(t);
        return Text(
          '$prefix${_format((target * eased).round())}',
          style: style,
        );
      },
    );
  }
}

/// Tactile bounce scale + physical translation on tap down/up,
/// giving a 3D soft skeuomorphic depressed button feel.
class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double scaleFactor;
  final Duration duration;
  final double translateY;
  final bool enableHaptics;

  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.scaleFactor = 0.95,
    this.duration = const Duration(milliseconds: 110),
    this.translateY = 2.0,
    this.enableHaptics = true,
  });

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails _) {
    if (widget.enableHaptics && widget.onTap != null) {
      HapticFeedback.lightImpact();
    }
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails _) {
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      onTap: widget.onTap,
      child: AnimatedSlide(
        offset: _isPressed ? Offset(0, widget.translateY / 100.0) : Offset.zero,
        duration: widget.duration,
        curve: Curves.easeOutCubic,
        child: AnimatedScale(
          scale: _isPressed ? widget.scaleFactor : 1.0,
          duration: widget.duration,
          curve: Curves.easeOutCubic,
          child: widget.child,
        ),
      ),
    );
  }
}
