import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:track_finance/features/auth/presentation/screens/login_screen.dart';
import 'package:track_finance/features/auth/presentation/widgets/tactile_3d_artwork.dart';

/// Halaman Splash Screen TrackFinance
/// Menampilkan animasi 3D tactile artwork dan nama aplikasi "TrackFinance"
/// secara minimalis, elegan, dan terpusat sesuai referensi visual.
class SplashScreen extends StatefulWidget {
  final Duration duration;

  const SplashScreen({
    super.key,
    this.duration = const Duration(milliseconds: 2800),
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  Timer? _timer;
  late AnimationController _brandingAnimController;
  late Animation<double> _brandingFadeAnimation;
  late Animation<Offset> _brandingSlideAnimation;

  @override
  void initState() {
    super.initState();

    // Animasi kemunculan nama aplikasi TrackFinance
    _brandingAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _brandingFadeAnimation = CurvedAnimation(
      parent: _brandingAnimController,
      curve: const Interval(0.25, 0.85, curve: Curves.easeOut),
    );

    _brandingSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _brandingAnimController,
        curve: const Interval(0.25, 0.85, curve: Curves.easeOutCubic),
      ),
    );

    _brandingAnimController.forward();

    // Timer transisi otomatis ke Login Screen
    _timer = Timer(widget.duration, _navigateToLogin);
  }

  void _navigateToLogin() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const LoginScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 650),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _brandingAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFF1E40AF),
        systemNavigationBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF1E40AF),
        body: GestureDetector(
          onTap: _navigateToLogin, // Ketuk untuk langsung lanjut
          behavior: HitTestBehavior.opaque,
          child: Stack(
            children: [
              // 1. Background Linear Gradient (165deg ~ dari #1E40AF ke #2563EB)
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment(-0.35, -1.0),
                      end: Alignment(0.35, 1.0),
                      colors: [
                        Color(0xFF1E40AF),
                        Color(0xFF2563EB),
                      ],
                    ),
                  ),
                ),
              ),

              // 2. Radial Gradient Overlay Lembut di Area Kiri Atas (25% 28%)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(-0.5, -0.44),
                      radius: 0.85,
                      colors: [
                        const Color(0xFF608CEB).withValues(alpha: 0.55),
                        const Color(0xFF608CEB).withValues(alpha: 0.0),
                      ],
                      stops: const [0.0, 0.7],
                    ),
                  ),
                ),
              ),

              // 3. Stage Konten Terpusat (Animasi Artwork + Nama Aplikasi)
              SafeArea(
                child: Center(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final screenHeight = constraints.maxHeight;
                      final artworkHeight =
                          (screenHeight * 0.44).clamp(260.0, 360.0);
                      final titleFontSize =
                          (constraints.maxWidth * 0.105).clamp(38.0, 48.0);
                      final gap = (screenHeight * 0.03).clamp(18.0, 32.0);

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Animasi 3D Tactile Artwork
                          Tactile3DArtwork(
                            height: artworkHeight,
                            transparentBackground: true,
                            showBackgroundEffects: false,
                          ),

                          SizedBox(height: gap),

                          // Nama Aplikasi: Track (#FFFFFF) Finance (#93C5FD)
                          SlideTransition(
                            position: _brandingSlideAnimation,
                            child: FadeTransition(
                              opacity: _brandingFadeAnimation,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Track',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: titleFontSize,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      letterSpacing: -1.0,
                                    ),
                                  ),
                                  Text(
                                    'Finance',
                                    style: GoogleFonts.plusJakartaSans(
                                      fontSize: titleFontSize,
                                      fontWeight: FontWeight.w800,
                                      color: const Color(0xFF93C5FD),
                                      letterSpacing: -1.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
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
