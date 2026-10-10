import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/animations.dart';

/// Segmented Switch dengan track inset berbayang dalam (carved track)
/// dan pill aktif timbul skeuomorfik (3D button pill).
class TransactionTypeSwitch extends StatelessWidget {
  final bool isExpense;
  final ValueChanged<bool> onChanged;

  const TransactionTypeSwitch({
    super.key,
    required this.isExpense,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E7FF), // surface-container-high
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFC3C6D7).withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          // Inset recessed feel
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. Tab Pengeluaran
          Expanded(
            child: _buildTab(
              title: 'Pengeluaran',
              icon: Icons.arrow_outward_rounded,
              isActive: isExpense,
              activeGradient: const [
                Color(0xFFEF4444),
                Color(0xFFDC2626),
              ],
              activeShadowColor: const Color(0xFFDC2626).withValues(alpha: 0.35),
              onTap: () {
                if (!isExpense) onChanged(true);
              },
            ),
          ),

          const SizedBox(width: 4),

          // 2. Tab Pemasukan
          Expanded(
            child: _buildTab(
              title: 'Pemasukan',
              icon: Icons.arrow_downward_rounded,
              isActive: !isExpense,
              activeGradient: const [
                Color(0xFF16A34A),
                Color(0xFF22C55E),
              ],
              activeShadowColor: const Color(0xFF16A34A).withValues(alpha: 0.35),
              onTap: () {
                if (isExpense) onChanged(false);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab({
    required String title,
    required IconData icon,
    required bool isActive,
    required List<Color> activeGradient,
    required Color activeShadowColor,
    required VoidCallback onTap,
  }) {
    return PressableScale(
      onTap: onTap,
      scaleFactor: 0.97,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: isActive
              ? LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: activeGradient,
                )
              : null,
          color: isActive ? null : Colors.transparent,
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: activeShadowColor,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive
                  ? Colors.white
                  : (title == 'Pemasukan'
                      ? AppColors.tactileGreen
                      : const Color(0xFF434655)),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelLg.copyWith(
                  color: isActive ? Colors.white : const Color(0xFF434655),
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
