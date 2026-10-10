import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/constants/app_colors.dart';

class LoginHeroHeader extends StatefulWidget {
  final double height;

  const LoginHeroHeader({
    super.key,
    this.height = 410,
  });

  @override
  State<LoginHeroHeader> createState() => _LoginHeroHeaderState();
}

class _LoginHeroHeaderState extends State<LoginHeroHeader>
    with TickerProviderStateMixin {
  late AnimationController _floatController;
  late Animation<double> _card1FloatAnimation;
  late Animation<double> _card2FloatAnimation;
  late Animation<double> _centerFloatAnimation;

  late AnimationController _entranceController;
  late Animation<double> _entranceFadeAnimation;
  late Animation<Offset> _card1SlideAnimation;
  late Animation<Offset> _card2SlideAnimation;
  late Animation<double> _centerScaleAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Continuous Floating Levitation Animation (Ambient weightless physics)
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat(reverse: true);

    _card1FloatAnimation = Tween<double>(begin: 0.0, end: -8.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _card2FloatAnimation = Tween<double>(begin: -6.0, end: 6.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _centerFloatAnimation = Tween<double>(begin: -4.0, end: 4.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    // 2. Entrance Staggered Animation
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _entranceFadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
    );

    _card1SlideAnimation = Tween<Offset>(
      begin: const Offset(-0.25, -0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.15, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    _card2SlideAnimation = Tween<Offset>(
      begin: const Offset(0.25, -0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.25, 0.95, curve: Curves.easeOutCubic),
      ),
    );

    _centerScaleAnimation = Tween<double>(
      begin: 0.86,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.05, 0.90, curve: Curves.easeOutBack),
      ),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _floatController.dispose();
    _entranceController.dispose();
    super.dispose();
  }

  static const String _svgScene = '''
<svg viewBox="0 0 375 340" xmlns="http://www.w3.org/2000/svg">
<defs>
<linearGradient gradientUnits="userSpaceOnUse" id="walletBodyGrad" x1="160" x2="290" y1="160" y2="270">
<stop offset="0%" stop-color="#0082A2"/>
<stop offset="60%" stop-color="#006780"/>
<stop offset="100%" stop-color="#004759"/>
</linearGradient>
<linearGradient gradientUnits="userSpaceOnUse" id="walletFlapGrad" x1="155" x2="280" y1="145" y2="220">
<stop offset="0%" stop-color="#0096BB"/>
<stop offset="50%" stop-color="#007490"/>
<stop offset="100%" stop-color="#00576C"/>
</linearGradient>
<linearGradient gradientUnits="userSpaceOnUse" id="claspGrad" x1="270" x2="305" y1="185" y2="215">
<stop offset="0%" stop-color="#65D0F4"/>
<stop offset="100%" stop-color="#005771"/>
</linearGradient>
<linearGradient gradientUnits="userSpaceOnUse" id="coinGrad1" x1="190" x2="225" y1="75" y2="115">
<stop offset="0%" stop-color="#FFFFFF"/>
<stop offset="40%" stop-color="#E3F7FD"/>
<stop offset="100%" stop-color="#92E2FB"/>
</linearGradient>
<linearGradient gradientUnits="userSpaceOnUse" id="coinGrad2" x1="230" x2="265" y1="100" y2="140">
<stop offset="0%" stop-color="#FFFFFF"/>
<stop offset="40%" stop-color="#DCF5FD"/>
<stop offset="100%" stop-color="#7EDDF9"/>
</linearGradient>
<linearGradient gradientUnits="userSpaceOnUse" id="coinGrad3" x1="165" x2="195" y1="115" y2="150">
<stop offset="0%" stop-color="#FFFFFF"/>
<stop offset="40%" stop-color="#E3F7FD"/>
<stop offset="100%" stop-color="#8FE1FA"/>
</linearGradient>
<linearGradient id="barGrad1" x1="0" x2="0" y1="0" y2="1">
<stop offset="0%" stop-color="#FFFFFF" stop-opacity="0.95"/>
<stop offset="100%" stop-color="#C8EEF9" stop-opacity="0.75"/>
</linearGradient>
<linearGradient id="barGrad2" x1="0" x2="0" y1="0" y2="1">
<stop offset="0%" stop-color="#FFFFFF" stop-opacity="0.95"/>
<stop offset="100%" stop-color="#AEE6F7" stop-opacity="0.8"/>
</linearGradient>
<linearGradient id="barGrad3" x1="0" x2="0" y1="0" y2="1">
<stop offset="0%" stop-color="#FFFFFF" stop-opacity="0.98"/>
<stop offset="100%" stop-color="#94DCF4" stop-opacity="0.85"/>
</linearGradient>
</defs>
<ellipse cx="205" cy="285" fill="#003A4A" opacity="0.18" rx="115" ry="16"/>
<g>
<rect fill="url(#barGrad1)" height="44" rx="9" stroke="rgba(255,255,255,0.8)" stroke-width="1.5" width="18" x="62" y="226"/>
<circle cx="71" cy="234" fill="#008BB0" opacity="0.4" r="3.5"/>
<rect fill="url(#barGrad2)" height="68" rx="9" stroke="rgba(255,255,255,0.85)" stroke-width="1.5" width="18" x="87" y="202"/>
<circle cx="96" cy="210" fill="#008BB0" opacity="0.45" r="3.5"/>
<rect fill="url(#barGrad3)" height="96" rx="9" stroke="rgba(255,255,255,0.9)" stroke-width="1.5" width="18" x="112" y="174"/>
<circle cx="121" cy="182" fill="#007390" opacity="0.55" r="3.5"/>
<path d="M68 215 Q95 185 125 158" opacity="0.75" stroke="white" stroke-dasharray="3 3" stroke-linecap="round" stroke-width="2.5"/>
<circle cx="127" cy="156" fill="white" opacity="0.9" r="3"/>
</g>
<g>
<rect fill="url(#walletBodyGrad)" height="98" rx="26" stroke="rgba(255,255,255,0.22)" stroke-width="2" width="138" x="155" y="166"/>
<rect fill="none" height="92" opacity="0.6" rx="23" stroke="rgba(255,255,255,0.25)" stroke-width="1.5" width="132" x="158" y="169"/>
<path d="M155 188 C155 174 166 166 182 166 L265 166 C280 166 293 175 293 190 L293 218 C275 232 230 238 182 226 C165 222 155 212 155 198 Z" fill="url(#walletFlapGrad)" stroke="rgba(255,255,255,0.35)" stroke-width="1.5"/>
<path d="M160 178 L288 178" stroke="rgba(0,50,65,0.28)" stroke-linecap="round" stroke-width="2"/>
<rect fill="url(#claspGrad)" height="28" rx="14" stroke="rgba(255,255,255,0.7)" stroke-width="2" width="34" x="266" y="194"/>
<circle cx="283" cy="208" fill="#FFFFFF" r="5.5"/>
<circle cx="283" cy="208" fill="#006780" r="2.5"/>
</g>
<g>
<g transform="rotate(-12 212 96)">
<circle cx="212" cy="96" fill="url(#coinGrad1)" r="20" stroke="rgba(255,255,255,0.95)" stroke-width="2"/>
<circle cx="212" cy="96" fill="none" opacity="0.55" r="13" stroke="#006780" stroke-width="2.5"/>
<path d="M212 88 L212 104 M207 92 H217 M207 100 H217" opacity="0.65" stroke="#006780" stroke-linecap="round" stroke-width="2"/>
<circle cx="204" cy="88" fill="white" opacity="0.9" r="2.5"/>
</g>
<g transform="rotate(18 250 124)">
<circle cx="250" cy="124" fill="url(#coinGrad2)" r="17" stroke="rgba(255,255,255,0.95)" stroke-width="2"/>
<circle cx="250" cy="124" fill="none" opacity="0.55" r="11" stroke="#006780" stroke-width="2.2"/>
<circle cx="244" cy="117" fill="white" opacity="0.9" r="2"/>
</g>
<g transform="rotate(-22 182 135)">
<circle cx="182" cy="135" fill="url(#coinGrad3)" r="15" stroke="rgba(255,255,255,0.95)" stroke-width="1.8"/>
<circle cx="182" cy="135" fill="none" opacity="0.5" r="9.5" stroke="#006780" stroke-width="2"/>
<circle cx="177" cy="129" fill="white" opacity="0.9" r="1.8"/>
</g>
</g>
<path d="M145 108 Q147 116 155 118 Q147 120 145 128 Q143 120 135 118 Q143 116 145 108 Z" fill="white" opacity="0.8"/>
<circle cx="285" cy="90" fill="white" opacity="0.75" r="3"/>
<circle cx="298" cy="148" fill="white" opacity="0.6" r="2.5"/>
</svg>
''';

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final card1Top = topPadding > 0 ? topPadding + 14 : 48.0;
    final card2Top = topPadding > 0 ? topPadding + 74 : 112.0;

    return Container(
      width: double.infinity,
      height: widget.height,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(48),
          bottomRight: Radius.circular(48),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF9BE6FC), // #9BE6FC
            Color(0xFF2A9FC4), // #2A9FC4
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x47006780), // rgba(0, 103, 128, 0.28)
            blurRadius: 40,
            spreadRadius: -10,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(48),
          bottomRight: Radius.circular(48),
        ),
        child: FadeTransition(
          opacity: _entranceFadeAnimation,
          child: Stack(
            clipBehavior: Clip.antiAlias,
            children: [
              // Soft translucent circle 1 (top-left)
              Positioned(
                top: -64,
                left: -64,
                width: 288,
                height: 288,
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color(0x73FFFFFF), // rgba(255, 255, 255, 0.45)
                        Color(0x00FFFFFF),
                      ],
                      stops: [0.0, 0.7],
                    ),
                  ),
                ),
              ),

              // Soft translucent circle 2 (mid-right)
              Positioned(
                top: 80,
                right: -48,
                width: 256,
                height: 256,
                child: Container(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color(0x38006780), // rgba(0, 103, 128, 0.22)
                        Color(0x00006780),
                      ],
                      stops: [0.0, 0.7],
                    ),
                  ),
                ),
              ),

              // 3D Claymorphic Centerpiece SVG Scene with scale & floating motion
              Positioned.fill(
                top: 36,
                child: Align(
                  alignment: Alignment.center,
                  child: AnimatedBuilder(
                    animation: Listenable.merge([_centerScaleAnimation, _centerFloatAnimation]),
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _centerFloatAnimation.value),
                        child: Transform.scale(
                          scale: _centerScaleAnimation.value,
                          child: child,
                        ),
                      );
                    },
                    child: SizedBox(
                      width: 375,
                      height: 340,
                      child: SvgPicture.string(
                        _svgScene,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),

              // Subtle dark-teal vignette at the bottom edge
              Positioned.fill(
                child: IgnorePointer(
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.0, 0.65, 1.0],
                        colors: [
                          Colors.transparent,
                          Colors.transparent,
                          Color(0x4D006780), // primary/30
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Floating Frosted Glass Card 1: Monthly Expense (Upper Left)
              Positioned(
                top: card1Top,
                left: 20,
                child: SlideTransition(
                  position: _card1SlideAnimation,
                  child: AnimatedBuilder(
                    animation: _card1FloatAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _card1FloatAnimation.value),
                        child: child,
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xB3FFFFFF), // rgba(255, 255, 255, 0.70)
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0x66FFFFFF), // rgba(255, 255, 255, 0.40)
                              width: 1,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x1F006780), // rgba(0, 103, 128, 0.12)
                                blurRadius: 25,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                'Pengeluaran bulan ini',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 0.3,
                                  color: AppColors.onSurfaceVariant,
                                  fontFamily: 'Plus Jakarta Sans',
                                ),
                              ),
                              SizedBox(height: 3),
                              Text(
                                'Rp 2.450.000',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                  color: AppColors.onSurface,
                                  fontFamily: 'Plus Jakarta Sans',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Floating Frosted Glass Card 2: Savings Pill (Mid Right)
              Positioned(
                top: card2Top,
                right: 16,
                child: SlideTransition(
                  position: _card2SlideAnimation,
                  child: AnimatedBuilder(
                    animation: _card2FloatAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _card2FloatAnimation.value),
                        child: child,
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xB3FFFFFF), // rgba(255, 255, 255, 0.70)
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: const Color(0x66FFFFFF), // rgba(255, 255, 255, 0.40)
                              width: 1,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x1F006780), // rgba(0, 103, 128, 0.12)
                                blurRadius: 20,
                                offset: Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x2E006780),
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.trending_down_rounded,
                                    size: 13,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Hemat 12%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                  color: AppColors.primary,
                                  fontFamily: 'Plus Jakarta Sans',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
