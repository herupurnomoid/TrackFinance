import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class DashboardGreeting extends StatefulWidget {
  final String userName;
  final VoidCallback? onProfileTap;

  const DashboardGreeting({
    super.key,
    required this.userName,
    this.onProfileTap,
  });

  @override
  State<DashboardGreeting> createState() => _DashboardGreetingState();
}

class _DashboardGreetingState extends State<DashboardGreeting> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Greeting Text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat Datang Kembali',
                style: AppTextStyles.labelMd.copyWith(
                  color: AppColors.secondary,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Selamat Pagi, ${widget.userName} 👋',
                style: AppTextStyles.headlineLg.copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  letterSpacing: -0.4,
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),

        const SizedBox(width: 12),

        // Tactile Clay Profile Button with Avatar and Cyan Status Bead
        GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) {
            setState(() => _isPressed = false);
            widget.onProfileTap?.call();
          },
          onTapCancel: () => setState(() => _isPressed = false),
          child: AnimatedScale(
            scale: _isPressed ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            child: SizedBox(
              width: 48,
              height: 48,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x5965D0F4), // rgba(101, 208, 244, 0.35)
                          blurRadius: 20,
                          spreadRadius: -4,
                          offset: Offset(0, 10),
                        ),
                        BoxShadow(
                          color: Colors.white,
                          blurRadius: 5,
                          offset: Offset(0, -3),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.face_rounded,
                        size: 26,
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                  // Bottom-Right Cyan Bead Indicator (14x14)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.surfaceContainerLowest,
                          width: 1.5,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x40006780),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
