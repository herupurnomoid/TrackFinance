import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ClayAppIcon extends StatefulWidget {
  const ClayAppIcon({super.key});

  @override
  State<ClayAppIcon> createState() => _ClayAppIconState();
}

class _ClayAppIconState extends State<ClayAppIcon>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _pulseController;
  late Animation<double> _beadScaleAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _beadScaleAnimation = Tween<double>(begin: 0.9, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutBack,
        child: Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: const Color(0xFFF9F9F9),
              width: 4,
            ),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF8CE7FF), // Top-left soft highlight
                AppColors.primaryContainer, // #65D0F4
                Color(0xFF4AC4ED), // Bottom-right depth
              ],
            ),
            boxShadow: const [
              // Vibrant cyan glow drop shadow
              BoxShadow(
                color: Color(0x8065D0F4), // rgba(101, 208, 244, 0.5)
                blurRadius: 28,
                spreadRadius: -4,
                offset: Offset(0, 14),
              ),
              // Grounding teal shadow
              BoxShadow(
                color: Color(0x2E006780), // rgba(0, 103, 128, 0.18)
                blurRadius: 14,
                spreadRadius: -2,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: SizedBox(
              width: 52,
              height: 52,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  // Inside White Rounded Square (52x52)
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x0F000000), // rgba(0,0,0,0.06)
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.account_balance_wallet_rounded,
                        color: AppColors.primary,
                        size: 28,
                      ),
                    ),
                  ),

                  // Little Cyan Highlight Bead with breathing scale
                  Positioned(
                    top: -4,
                    right: -4,
                    child: AnimatedBuilder(
                      animation: _beadScaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _beadScaleAnimation.value,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: const BoxDecoration(
                              color: AppColors.tertiaryContainer,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x40005771), // rgba(0, 87, 113, 0.25)
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Container(
                                width: 4,
                                height: 4,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
