import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/services/auth_service_provider.dart';
import 'package:track_finance/features/dashboard/presentation/screens/dashboard_screen.dart';
import '../widgets/curved_dome_panel.dart';
import '../widgets/tactile_3d_artwork.dart';
import '../widgets/tactile_google_button.dart';

/// Halaman Login Modern Tactile Finance
/// Menggabungkan skeuomorphic clay tactile illustration, kurva lengkungan kubah,
/// tipografi Plus Jakarta Sans, dan micro-interaction tombol autentik.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _panelEntranceController;
  late Animation<Offset> _panelSlideAnimation;
  late Animation<double> _panelFadeAnimation;

  @override
  void initState() {
    super.initState();

    _panelEntranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    );

    _panelSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.22),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _panelEntranceController,
        curve: const Interval(0.20, 0.90, curve: Curves.easeOutCubic),
      ),
    );

    _panelFadeAnimation = CurvedAnimation(
      parent: _panelEntranceController,
      curve: const Interval(0.20, 0.85, curve: Curves.easeOut),
    );

    _panelEntranceController.forward();
  }

  @override
  void dispose() {
    _panelEntranceController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await AuthServiceProvider.instance.signInWithGoogle();

      if (!mounted) return;

      if (user != null) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                DashboardScreen(user: user),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal melakukan sign in: $e'),
          backgroundColor: const Color(0xFFBA1A1A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFF1E40AF),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = constraints.maxHeight;
            final bottomPadding = MediaQuery.of(context).padding.bottom;
            final panelContentHeight = 175.0 + (bottomPadding > 0 ? bottomPadding : 16.0);

            return Stack(
              children: [
                // 1. Area Ilustrasi 3D Tactile yang Mengisi Penuh Ruang Atas
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: panelContentHeight * 0.75),
                    child: Center(
                      child: Tactile3DArtwork(
                        height: (screenHeight - panelContentHeight * 0.5)
                            .clamp(0.0, double.infinity),
                      ),
                    ),
                  ),
                ),

                // 2. Panel Bawah Lengkung Kubah Putih Menimpa Sempurna di Bawah
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SlideTransition(
                    position: _panelSlideAnimation,
                    child: FadeTransition(
                      opacity: _panelFadeAnimation,
                      child: CurvedDomePanel(
                        domeHeight: 28.0,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(
                            24.0,
                            12.0,
                            24.0,
                            bottomPadding > 0 ? bottomPadding + 16.0 : 32.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Judul Sambutan
                              Text.rich(
                                TextSpan(
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF0F172A), // Slate 900
                                    height: 1.25,
                                    letterSpacing: -0.4,
                                  ),
                                  children: [
                                    const TextSpan(text: 'Selamat datang di '),
                                    TextSpan(
                                      text: 'Track Finance',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: const Color(0xFF2563EB), // Primary Blue
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),

                              // Subjudul / Deskripsi Singkat
                              Text(
                                'Catat uangmu dengan tenang dan rapi.',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF64748B), // Slate 500
                                  height: 1.45,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Tombol Mandiri Google Tactile
                              TactileGoogleButton(
                                isLoading: _isLoading,
                                onPressed: _handleGoogleSignIn,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
