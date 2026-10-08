import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class MenuGridSection extends StatefulWidget {
  final Function(String menuTitle)? onMenuTap;

  const MenuGridSection({super.key, this.onMenuTap});

  @override
  State<MenuGridSection> createState() => _MenuGridSectionState();
}

class _MenuGridSectionState extends State<MenuGridSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _pingController;
  late Animation<double> _pingAnimation;

  @override
  void initState() {
    super.initState();
    _pingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _pingAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pingController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header: Menu
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            'Menu',
            style: AppTextStyles.labelLg.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Grid 4 Columns: Kategori, Ekspor, Tanya AI, Tambah
        Row(
          children: [
            // 1. Kategori
            Expanded(
              child: _buildClayMenuItem(
                title: 'Kategori',
                icon: Icons.category_rounded,
                iconColor: AppColors.primary,
                iconBgColor: AppColors.surfaceContainerLow,
                onTap: () => widget.onMenuTap?.call('Kategori'),
              ),
            ),

            const SizedBox(width: 8),

            // 2. Ekspor
            Expanded(
              child: _buildClayMenuItem(
                title: 'Ekspor & Import',
                icon: Icons.sync_rounded,
                iconColor: AppColors.primary,
                iconBgColor: AppColors.surfaceContainerLow,
                onTap: () => widget.onMenuTap?.call('Ekspor'),
              ),
            ),

            const SizedBox(width: 8),

            // 3. Tanya AI (with glowing/pulsing indicator)
            Expanded(
              child: _buildClayMenuItem(
                title: 'Tanya AI',
                icon: Icons.smart_toy_rounded,
                iconColor: Colors.white,
                iconBgColor: AppColors.primaryContainer,
                isAI: true,
                onTap: () => widget.onMenuTap?.call('Tanya AI'),
              ),
            ),

            const SizedBox(width: 8),

            // 4. Tambah
            Expanded(
              child: _buildClayMenuItem(
                title: 'Tambah',
                icon: Icons.add_rounded,
                iconColor: Colors.white,
                iconBgColor: AppColors.primary,
                onTap: () => widget.onMenuTap?.call('Tambah'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildClayMenuItem({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required VoidCallback onTap,
    bool isAI = false,
  }) {
    return _TactileMenuItemButton(
      title: title,
      icon: icon,
      iconColor: iconColor,
      iconBgColor: iconBgColor,
      isAI: isAI,
      pingAnimation: _pingAnimation,
      onTap: onTap,
    );
  }
}

class _TactileMenuItemButton extends StatefulWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final bool isAI;
  final Animation<double> pingAnimation;
  final VoidCallback onTap;

  const _TactileMenuItemButton({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.isAI,
    required this.pingAnimation,
    required this.onTap,
  });

  @override
  State<_TactileMenuItemButton> createState() => _TactileMenuItemButtonState();
}

class _TactileMenuItemButtonState extends State<_TactileMenuItemButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Color(0x3865D0F4), // rgba(101,208,244,0.22)
                blurRadius: 18,
                spreadRadius: -4,
                offset: Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.white,
                blurRadius: 5,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 40x40 Icon Disc
              SizedBox(
                width: 40,
                height: 40,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: widget.iconBgColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: widget.iconBgColor.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          widget.icon,
                          size: 20,
                          color: widget.iconColor,
                        ),
                      ),
                    ),

                    // Ping Indicator Dot for AI
                    if (widget.isAI)
                      Positioned(
                        top: 1,
                        right: 1,
                        child: AnimatedBuilder(
                          animation: widget.pingAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: widget.pingAnimation.value,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Title
              Text(
                widget.title,
                style: AppTextStyles.labelSm.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
