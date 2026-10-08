import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/services/auth_service_provider.dart';
import 'package:track_finance/features/dashboard/presentation/screens/dashboard_screen.dart';
import '../widgets/clay_app_icon.dart';
import '../widgets/google_sign_in_button.dart';
import '../widgets/login_hero_header.dart';
import '../widgets/security_badge.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  late AnimationController _entranceController;
  late Animation<double> _iconScaleAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _actionSlideAnimation;
  late Animation<double> _actionFadeAnimation;

  @override
  void initState() {
    super.initState();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );

    _iconScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.15, 0.65, curve: Curves.easeOutBack),
      ),
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.30, 0.80, curve: Curves.easeOutCubic),
      ),
    );

    _textFadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.30, 0.75, curve: Curves.easeOut),
    );

    _actionSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.45, 0.95, curve: Curves.easeOutCubic),
      ),
    );

    _actionFadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.45, 0.90, curve: Curves.easeOut),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
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
          backgroundColor: Colors.redAccent,
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
      ),
      child: Scaffold(
        backgroundColor: AppColors.surface,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final screenHeight = constraints.maxHeight;
            final heroHeight = (screenHeight * 0.49).clamp(380.0, 410.0);

            return SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: screenHeight,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Section: Hero Artwork & Overlapping App Icon & Welcome Text
                    Column(
                      children: [
                        // Hero Header with 3D Centerpiece & Floating Frosted Glass Cards
                        Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.bottomCenter,
                          children: [
                            LoginHeroHeader(height: heroHeight),

                            // Overlapping Claymorphic 3D App Icon Container (96x96) with bounce pop
                            Positioned(
                              bottom: -48,
                              child: ScaleTransition(
                                scale: _iconScaleAnimation,
                                child: const ClayAppIcon(),
                              ),
                            ),
                          ],
                        ),

                        // Space accounting for the 48px overlapping icon + margin
                        const SizedBox(height: 62),

                        // Welcoming Typography Block with smooth slide & fade in
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: SlideTransition(
                            position: _textSlideAnimation,
                            child: FadeTransition(
                              opacity: _textFadeAnimation,
                              child: Column(
                                children: [
                                  Text(
                                    'Selamat Datang',
                                    style: AppTextStyles.headlineWelcome,
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  ConstrainedBox(
                                    constraints:
                                        const BoxConstraints(maxWidth: 280),
                                    child: Text(
                                      'Kelola keuangan pribadi Anda dengan lebih mudah, cerdas, dan aman.',
                                      style: AppTextStyles.bodyDescription,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Actions & Footer Section with staggered slide & fade
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
                      child: SlideTransition(
                        position: _actionSlideAnimation,
                        child: FadeTransition(
                          opacity: _actionFadeAnimation,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Authentic Google Sign-In Pill Button with Claymorphic Volume
                              GoogleSignInButton(
                                isLoading: _isLoading,
                                onPressed: _handleGoogleSignIn,
                              ),

                              const SizedBox(height: 16),

                              // Reassuring Micro-Note
                              const SecurityBadge(),

                              const SizedBox(height: 16),

                              // Home Indicator Bar
                              Container(
                                width: 128,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: AppColors.onSurface.withValues(alpha: 0.20),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
