import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/animations.dart';

/// Card Nominal Timbul Modern Tactile Finance dengan Inset Carved-In Display
/// dan Tactile Quick-Add Chips.
class AmountHeroCard extends StatelessWidget {
  final TextEditingController controller;
  final bool isExpense;
  final bool hasError;
  final ValueChanged<int> onQuickAdd;
  final VoidCallback onClear;

  const AmountHeroCard({
    super.key,
    required this.controller,
    required this.isExpense,
    this.hasError = false,
    required this.onQuickAdd,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    // Quick Add presets based on Expense vs Income
    final List<Map<String, dynamic>> quickPills = isExpense
        ? [
            {'label': '+10.000', 'amount': 10000},
            {'label': '+20.000', 'amount': 20000},
            {'label': '+50.000', 'amount': 50000},
            {'label': '+100.000', 'amount': 100000},
          ]
        : [
            {'label': '+50.000', 'amount': 50000},
            {'label': '+100.000', 'amount': 100000},
            {'label': '+500.000', 'amount': 500000},
            {'label': '+1.000.000', 'amount': 1000000},
          ];

    final Color amountColor = hasError
        ? AppColors.error
        : (isExpense ? const Color(0xFFDC2626) : AppColors.tactileGreen);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
        boxShadow: [
          // Specular top highlight
          const BoxShadow(
            color: Colors.white,
            blurRadius: 0,
            offset: Offset(0, -1),
          ),
          // Ambient soft blue tactile drop shadow
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.08),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.05),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Title & Status Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nominal Transaksi',
                style: AppTextStyles.labelMd.copyWith(
                  color: const Color(0xFF434655), // on-surface-variant
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),

              // Status Badge (Keluar / Kas Masuk / Wajib Diisi)
              if (hasError)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.errorContainer.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Wajib Diisi',
                    style: AppTextStyles.labelSm.copyWith(
                      color: AppColors.error,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    key: ValueKey(isExpense),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: isExpense
                          ? AppColors.errorContainer
                          : const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isExpense
                                ? AppColors.error
                                : AppColors.tactileGreen,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isExpense ? 'Keluar' : 'Kas Masuk',
                          style: AppTextStyles.labelSm.copyWith(
                            color: isExpense
                                ? AppColors.onErrorContainer
                                : AppColors.tactileGreen,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          // Inset Carved-In Amount Display Field
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: hasError
                  ? AppColors.errorContainer.withValues(alpha: 0.22)
                  : const Color(0xFFE2E7FF), // surface-container-high
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasError
                    ? AppColors.error.withValues(alpha: 0.45)
                    : const Color(0xFFC3C6D7).withValues(alpha: 0.35),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: (hasError ? AppColors.error : const Color(0xFF0F172A))
                      .withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Rp',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: hasError
                        ? AppColors.error.withValues(alpha: 0.75)
                        : const Color(0xFF434655),
                  ),
                ),
                const SizedBox(width: 8),

                // Amount Textfield
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: amountColor,
                      letterSpacing: -0.5,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      hintText: '0',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: hasError
                            ? AppColors.error.withValues(alpha: 0.5)
                            : const Color(0xFFC3C6D7),
                      ),
                    ),
                  ),
                ),

                // Backspace / Clear Tactile Button
                PressableScale(
                  onTap: onClear,
                  scaleFactor: 0.92,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDAE2FD), // surface-container-highest
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.8),
                          blurRadius: 2,
                          offset: const Offset(0, -1),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.backspace_outlined,
                        size: 16,
                        color: hasError ? AppColors.error : const Color(0xFF434655),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Error Helper Message if validation failed
          if (hasError) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 15,
                  color: AppColors.error,
                ),
                const SizedBox(width: 4),
                Text(
                  'Nominal harus lebih dari Rp0',
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 12),

          // Quick Add Pills (Tactile Chips)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: quickPills.map((pill) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: _buildQuickPill(
                    label: pill['label'] as String,
                    amount: pill['amount'] as int,
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPill({required String label, required int amount}) {
    return PressableScale(
      onTap: () => onQuickAdd(amount),
      scaleFactor: 0.94,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFF2F3FF),
            ],
          ),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: [
            const BoxShadow(
              color: Colors.white,
              blurRadius: 0,
              offset: Offset(0, -1),
            ),
            BoxShadow(
              color: const Color(0xFF2563EB).withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMd.copyWith(
            color: AppColors.tactileTextPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
