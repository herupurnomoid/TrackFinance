import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/animations.dart';

enum ExportFileFormat { csv, pdf }

class ExportFormatSelector extends StatelessWidget {
  final ExportFileFormat selectedFormat;
  final ValueChanged<ExportFileFormat> onFormatSelected;

  const ExportFormatSelector({
    super.key,
    required this.selectedFormat,
    required this.onFormatSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: Text(
            'Pilih Format File',
            style: AppTextStyles.labelLg.copyWith(
              color: AppColors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        const SizedBox(height: 10),

        // 2-Column Grid
        Row(
          children: [
            // 1. CSV Card
            Expanded(
              child: _buildFormatCard(
                format: ExportFileFormat.csv,
                icon: Icons.table_chart_rounded,
                title: 'File .CSV',
                subtitle: 'Spreadsheet Data',
                badgeText: 'Disarankan Excel',
                isSelected: selectedFormat == ExportFileFormat.csv,
                onTap: () => onFormatSelected(ExportFileFormat.csv),
              ),
            ),

            const SizedBox(width: 12),

            // 2. PDF Card
            Expanded(
              child: _buildFormatCard(
                format: ExportFileFormat.pdf,
                icon: Icons.picture_as_pdf_rounded,
                title: 'Dokumen .PDF',
                subtitle: 'Cetak & Arsip',
                badgeText: 'Format Siap Cetak',
                isSelected: selectedFormat == ExportFileFormat.pdf,
                onTap: () => onFormatSelected(ExportFileFormat.pdf),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFormatCard({
    required ExportFileFormat format,
    required IconData icon,
    required String title,
    required String subtitle,
    required String badgeText,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return PressableScale(
      onTap: onTap,
      scaleFactor: 0.95,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.surfaceContainerLowest
              : AppColors.surfaceContainerLow.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryContainer.withValues(alpha: 0.7)
                : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF65D0F4).withValues(alpha: 0.35),
                    blurRadius: 22,
                    spreadRadius: -4,
                    offset: const Offset(0, 10),
                  ),
                  BoxShadow(
                    color: Colors.white.withValues(alpha: 0.95),
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: const Color(0xFF0D2C3A).withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Stack(
          children: [
            // Checkmark Badge top right when selected
            if (isSelected)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF65D0F4).withValues(alpha: 0.45),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Pod 48x48
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primaryContainer
                        : AppColors.surfaceContainerHighest,
                    shape: BoxShape.circle,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: const Color(0xFF65D0F4).withValues(alpha: 0.5),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      size: 24,
                      color: isSelected ? Colors.white : AppColors.secondary,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Title
                Text(
                  title,
                  style: AppTextStyles.headlineSm.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: AppColors.onSurface,
                  ),
                ),

                const SizedBox(height: 2),

                // Subtitle
                Text(
                  subtitle,
                  style: AppTextStyles.labelSm.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 10),

                // Chip / Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.secondaryContainer
                        : AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    badgeText,
                    style: AppTextStyles.labelSm.copyWith(
                      fontSize: 9.5,
                      color: isSelected
                          ? AppColors.onSecondaryContainer
                          : AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
