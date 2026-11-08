import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/animations.dart';

/// Form Nominal Transaksi Modern Tactile Finance dengan konsep No Container & No Background Color.
/// Menampilkan input nominal melayang bebas (borderless & floating) dengan tipografi hero yang tegas.
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
    // Preset Nominal Cepat (Quick Add) berdasarkan Pengeluaran vs Pemasukan
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

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris Header: Label & Status Badge Transaksi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nominal Transaksi',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
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
                          ? const Color(0xFFFEE2E2)
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
                                ? const Color(0xFFDC2626)
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

          const SizedBox(height: 10),

          // Tampilan Hero Nominal Bebas Batasan (No Container, No Background Color)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: hasError
                      ? AppColors.error
                      : (isExpense
                          ? const Color(0xFFFDA4AF)
                          : const Color(0xFF86EFAC)),
                  width: 2.0,
                ),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Rp',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: hasError
                        ? AppColors.error.withValues(alpha: 0.75)
                        : (isExpense
                            ? const Color(0xFFDC2626).withValues(alpha: 0.85)
                            : AppColors.tactileGreen.withValues(alpha: 0.85)),
                  ),
                ),
                const SizedBox(width: 8),

                // Amount Textfield
                Expanded(
                  child: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 38,
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
                        fontSize: 38,
                        fontWeight: FontWeight.w800,
                        color: hasError
                            ? AppColors.error.withValues(alpha: 0.4)
                            : const Color(0xFFCBD5E1),
                      ),
                    ),
                  ),
                ),

                // Tombol Hapus / Backspace Minimalis
                PressableScale(
                  onTap: onClear,
                  scaleFactor: 0.90,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.backspace_outlined,
                        size: 18,
                        color: hasError ? AppColors.error : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Pesan Bantuan Validasi jika error
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

          const SizedBox(height: 14),

          // Quick Add Pills (Tactile Chips) Melayang Halus
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          color: Colors.white,
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 1.5),
            ),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF334155),
            fontWeight: FontWeight.w600,
            fontSize: 12.5,
          ),
        ),
      ),
    );
  }
}
