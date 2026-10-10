import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/animations.dart';

class AddTransactionModal extends StatelessWidget {
  final VoidCallback? onManualInput;
  final VoidCallback? onScanReceipt;

  const AddTransactionModal({
    super.key,
    this.onManualInput,
    this.onScanReceipt,
  });

  static Future<void> show(
    BuildContext context, {
    VoidCallback? onManualInput,
    VoidCallback? onScanReceipt,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: AppColors.onSurface.withValues(alpha: 0.40),
      builder: (context) => AddTransactionModal(
        onManualInput: onManualInput,
        onScanReceipt: onScanReceipt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
        border: Border(
          top: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.30),
            width: 1,
          ),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26006780), // rgba(0,103,128,0.15)
            blurRadius: 32,
            offset: Offset(0, -12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(999),
            ),
          ),

          const SizedBox(height: 20),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tambah Transaksi',
                    style: AppTextStyles.headlineSm.copyWith(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Pilih metode pencatatan yang diinginkan',
                    style: AppTextStyles.bodySm.copyWith(
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              PressableScale(
                onTap: () => Navigator.of(context).pop(),
                scaleFactor: 0.90,
                translateY: 1.5,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Grid 2 Action Cards: Input Manual & Scan Otomatis
          Row(
            children: [
              // 1. Input Manual
              Expanded(
                child: PressableScale(
                  onTap: () {
                    Navigator.of(context).pop();
                    onManualInput?.call();
                  },
                  scaleFactor: 0.94,
                  translateY: 2.5,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.outlineVariant.withValues(alpha: 0.30),
                        width: 1,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x2E65D0F4), // rgba(101,208,244,0.18)
                          blurRadius: 20,
                          spreadRadius: -4,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: AppColors.primaryContainer,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x5965D0F4),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.edit_note_rounded,
                              size: 26,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Input Manual',
                          style: AppTextStyles.headlineSm.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ketik rincian pengeluaran / pemasukan',
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.secondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // 2. Scan Otomatis
              Expanded(
                child: PressableScale(
                  onTap: () {
                    Navigator.of(context).pop();
                    onScanReceipt?.call();
                  },
                  scaleFactor: 0.94,
                  translateY: 2.5,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.outlineVariant.withValues(alpha: 0.30),
                        width: 1,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x2E65D0F4), // rgba(101,208,244,0.18)
                          blurRadius: 20,
                          spreadRadius: -4,
                          offset: Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x59006780),
                                blurRadius: 10,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.document_scanner_rounded,
                              size: 24,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Scan Otomatis',
                          style: AppTextStyles.headlineSm.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pindai struk & nota via kamera AI',
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.secondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
