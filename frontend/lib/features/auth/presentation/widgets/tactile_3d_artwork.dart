import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Komponen visual 3D Tactile Skeuomorphic Artwork dengan animasi melayang (floating idle)
/// dan staggered entrance entrance physics untuk halaman login.
class Tactile3DArtwork extends StatefulWidget {
  final double height;
  final bool transparentBackground;
  final bool showBackgroundEffects;

  const Tactile3DArtwork({
    super.key,
    required this.height,
    this.transparentBackground = false,
    this.showBackgroundEffects = true,
  });

  @override
  State<Tactile3DArtwork> createState() => _Tactile3DArtworkState();
}

class _Tactile3DArtworkState extends State<Tactile3DArtwork>
    with TickerProviderStateMixin {
  late AnimationController _idleController;
  late AnimationController _entranceController;

  // Staggered entrance animations
  late Animation<double> _bgFadeAnimation;
  late Animation<double> _chartGrowAnimation;
  late Animation<double> _walletScaleAnimation;
  late Animation<double> _coin1PopAnimation;
  late Animation<double> _coin2PopAnimation;
  late Animation<double> _coin3PopAnimation;
  late Animation<double> _badgePopAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Idle Floating Animation (Weightless Levitation Physics)
    _idleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    // 2. Entrance Staggered Animation
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _bgFadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    );

    _walletScaleAnimation = Tween<double>(begin: 0.75, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.15, 0.75, curve: Curves.easeOutBack),
      ),
    );

    _chartGrowAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.25, 0.85, curve: Curves.easeOutCubic),
    );

    _badgePopAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.40, 0.90, curve: Curves.easeOutBack),
      ),
    );

    _coin1PopAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.30, 0.80, curve: Curves.easeOutBack),
      ),
    );

    _coin2PopAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.45, 0.92, curve: Curves.easeOutBack),
      ),
    );

    _coin3PopAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.55, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _idleController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: widget.height,
      decoration: widget.transparentBackground
          ? null
          : const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1E40AF), // Deep Royal Blue
                  Color(0xFF2563EB), // Vibrant Primary Blue
                ],
              ),
            ),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          // 1. Subtle Diagonal Pattern Overlay
          if (widget.showBackgroundEffects)
            Positioned.fill(
              child: FadeTransition(
                opacity: _bgFadeAnimation,
                child: const CustomPaint(
                  painter: _DiagonalHatchPainter(),
                ),
              ),
            ),

          // 2. Ambient Soft Glow Spheres (Top Left & Center Right)
          if (widget.showBackgroundEffects) ...[
            Positioned(
              top: -50,
              left: -50,
              child: FadeTransition(
                opacity: _bgFadeAnimation,
                child: Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.12),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 140,
              right: -60,
              child: FadeTransition(
                opacity: _bgFadeAnimation,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withValues(alpha: 0.10),
                        Colors.white.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],

          // 3. Centerpiece 3D Tactile Composition
          AnimatedBuilder(
            animation: Listenable.merge([_idleController, _entranceController]),
            builder: (context, child) {
              final t = _idleController.value * 2 * math.pi;

              // Levitation physics offsets
              final walletDy = math.sin(t) * 4.0;
              final coin1Dy = math.cos(t) * 7.0;
              final coin2Dy = math.sin(t + 1.6) * 6.0;
              final coin3Dy = math.cos(t + 2.8) * 7.5;
              final chartDy = math.sin(t) * 2.5;

              return SizedBox(
                width: 310,
                height: 300,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    // Ground Ambient Depth Shadow
                    Positioned(
                      bottom: 30,
                      child: Transform.translate(
                        offset: Offset(0, walletDy * 0.4),
                        child: Container(
                          width: 230,
                          height: 28,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF00174B).withValues(alpha: 0.35),
                                blurRadius: 28,
                                spreadRadius: 6,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Left Chart Bars & Green Pill Badge
                    Positioned(
                      left: 10,
                      bottom: 54,
                      child: Transform.translate(
                        offset: Offset(0, chartDy),
                        child: _buildGrowingChart(
                          growFactor: _chartGrowAnimation.value,
                          badgeScale: _badgePopAnimation.value,
                        ),
                      ),
                    ),

                    // Center 3D Claymorphism Wallet
                    Positioned(
                      right: 18,
                      bottom: 50,
                      child: Transform.translate(
                        offset: Offset(0, walletDy),
                        child: Transform.scale(
                          scale: _walletScaleAnimation.value,
                          child: _buildTactileWallet(),
                        ),
                      ),
                    ),

                    // Floating Coin 1 (Top Right - "Rp")
                    Positioned(
                      top: 40 + coin1Dy,
                      right: 32,
                      child: Transform.scale(
                        scale: _coin1PopAnimation.value,
                        child: _buildCoinRp(),
                      ),
                    ),

                    // Floating Coin 2 (Top Left - Concentric Dots)
                    Positioned(
                      top: 72 + coin2Dy,
                      left: 48,
                      child: Transform.scale(
                        scale: _coin2PopAnimation.value,
                        child: _buildCoinDot(),
                      ),
                    ),

                    // Floating Coin 3 (Bottom Right - Payment Glyph)
                    Positioned(
                      bottom: 26 + coin3Dy,
                      right: 68,
                      child: Transform.scale(
                        scale: _coin3PopAnimation.value,
                        child: _buildCoinPayment(),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Batang grafik bertumbuh dengan pill hijau "+18%"
  Widget _buildGrowingChart({
    required double growFactor,
    required double badgeScale,
  }) {
    return SizedBox(
      width: 80,
      height: 140,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomLeft,
        children: [
          // 3 Bar Bertingkat
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Bar 1 (Rendah)
              _buildSingleBar(
                height: 42 * growFactor,
                width: 17,
                gradientColors: const [Colors.white, Color(0xFFDAE2FD)],
              ),
              const SizedBox(width: 6),
              // Bar 2 (Sedang)
              _buildSingleBar(
                height: 72 * growFactor,
                width: 17,
                gradientColors: const [Colors.white, Color(0xFFDAE2FD)],
              ),
              const SizedBox(width: 6),
              // Bar 3 (Tinggi + Blue Dot)
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  _buildSingleBar(
                    height: 106 * growFactor,
                    width: 17,
                    gradientColors: const [Colors.white, Color(0xFFB4C5FF)],
                  ),
                  Positioned(
                    top: 4,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2563EB),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Timbul Pill Badge Hijau "+18%"
          Positioned(
            top: 2,
            left: 20,
            child: Transform.scale(
              scale: badgeScale,
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF16A34A),
                  borderRadius: BorderRadius.circular(100),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF16A34A).withValues(alpha: 0.40),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.trending_up_rounded,
                      size: 13,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      '+18%',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleBar({
    required double height,
    required double width,
    required List<Color> gradientColors,
  }) {
    if (height <= 0) return SizedBox(width: width);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(7),
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: gradientColors,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00174B).withValues(alpha: 0.20),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.9),
            width: 1.5,
          ),
        ),
      ),
    );
  }

  /// Dompet 3D Claymorphism Tactile Putih Kebiruan
  Widget _buildTactileWallet() {
    return SizedBox(
      width: 180,
      height: 140,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.centerRight,
        children: [
          // 1. Kartu / Uang Menyembul di Belakang Dompet (Layer 3D)
          Positioned(
            top: 2,
            left: 20,
            child: Transform.rotate(
              angle: -0.09, // -5 derajat
              child: Container(
                width: 78,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00174B).withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            left: 36,
            child: Transform.rotate(
              angle: 0.05, // +3 derajat
              child: Container(
                width: 86,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00174B).withValues(alpha: 0.18),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 2. Badan Utama Dompet Depan (Squircle Tactile)
          Positioned(
            left: 0,
            bottom: 0,
            child: Container(
              width: 172,
              height: 124,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFFFFFFF),
                    Color(0xFFDBEAFE),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.90),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00174B).withValues(alpha: 0.28),
                    blurRadius: 32,
                    offset: const Offset(0, 16),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Tekstur Lipatan Atas Dompet
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 34,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(26),
                        ),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white,
                            const Color(0xFFE2E8F0).withValues(alpha: 0.35),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Garis Jahitan Halus Bawah Dompet
                  Positioned(
                    bottom: 14,
                    left: 18,
                    right: 36,
                    child: CustomPaint(
                      painter: _DashedStitchPainter(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Lidah Pengunci Dompet (Strap Flap) ke Kanan
          Positioned(
            right: 0,
            bottom: 34,
            child: Container(
              width: 58,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
                gradient: const LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Color(0xFFDBEAFE),
                    Colors.white,
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.9),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00174B).withValues(alpha: 0.16),
                    blurRadius: 10,
                    offset: const Offset(-4, 4),
                  ),
                ],
              ),
              child: Center(
                // Kancing Biru Embossed 3D dengan Specular Titik Putih
                child: Container(
                  width: 25,
                  height: 25,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF3B82F6),
                        Color(0xFF1D4ED8),
                      ],
                    ),
                    border: Border.all(
                      color: const Color(0xFF60A5FA),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.50),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Lingkaran Dalam
                      Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1D4ED8),
                          shape: BoxShape.circle,
                        ),
                      ),
                      // Specular Highlight Titik Putih (Efek Kilau 3D)
                      Positioned(
                        top: 4,
                        left: 4,
                        child: Container(
                          width: 3.5,
                          height: 3.5,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.85),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Koin 1: Kanan Atas dengan Teks "Rp"
  Widget _buildCoinRp() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Color(0xFFDBEAFE),
          ],
        ),
        border: Border.all(
          color: Colors.white,
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00174B).withValues(alpha: 0.22),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Lingkaran Ring Biru
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.65),
              border: Border.all(
                color: const Color(0xFF2563EB).withValues(alpha: 0.50),
                width: 2.4,
              ),
            ),
            child: Center(
              child: Text(
                'Rp',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF2563EB),
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          // Specular Glint
          Positioned(
            top: 6,
            left: 8,
            child: Container(
              width: 3.5,
              height: 3.5,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Koin 2: Kiri Atas dengan Lingkaran Konsentris
  Widget _buildCoinDot() {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Color(0xFFDBEAFE),
          ],
        ),
        border: Border.all(
          color: Colors.white,
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00174B).withValues(alpha: 0.20),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.65),
              border: Border.all(
                color: const Color(0xFF2563EB).withValues(alpha: 0.45),
                width: 2.2,
              ),
            ),
            child: Center(
              child: Container(
                width: 5.5,
                height: 5.5,
                decoration: const BoxDecoration(
                  color: Color(0xFF2563EB),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Positioned(
            top: 5,
            left: 6,
            child: Container(
              width: 3,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Koin 3: Kanan Bawah dengan Simbol Payments
  Widget _buildCoinPayment() {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Color(0xFFDBEAFE),
          ],
        ),
        border: Border.all(
          color: Colors.white,
          width: 2.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00174B).withValues(alpha: 0.22),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.65),
              border: Border.all(
                color: const Color(0xFF2563EB).withValues(alpha: 0.50),
                width: 2.0,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.credit_card_rounded,
                size: 14,
                color: Color(0xFF2563EB),
              ),
            ),
          ),
          Positioned(
            top: 5,
            left: 7,
            child: Container(
              width: 3,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter untuk tekstur garis diagonal halus (45 derajat)
class _DiagonalHatchPainter extends CustomPainter {
  const _DiagonalHatchPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    const spacing = 14.0;
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

/// Custom painter untuk garis jahitan bawah dompet (dashed line)
class _DashedStitchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    const dashWidth = 4.0;
    const dashSpace = 4.0;
    double startX = 0;

    while (startX < size.width) {
      canvas.drawLine(
        Offset(startX, 0),
        Offset(math.min(startX + dashWidth, size.width), 0),
        paint,
      );
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
