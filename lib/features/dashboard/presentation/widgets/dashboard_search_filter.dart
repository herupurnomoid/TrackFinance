import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class DashboardSearchFilter extends StatefulWidget {
  final ValueChanged<String>? onSearchChanged;
  final ValueChanged<String>? onPeriodSelected;
  final VoidCallback? onCalendarTap;

  const DashboardSearchFilter({
    super.key,
    this.onSearchChanged,
    this.onPeriodSelected,
    this.onCalendarTap,
  });

  @override
  State<DashboardSearchFilter> createState() => _DashboardSearchFilterState();
}

class _DashboardSearchFilterState extends State<DashboardSearchFilter> {
  String _selectedTab = 'Bulan';
  final List<String> _tabs = ['Hari', 'Minggu', 'Bulan', 'Tahun'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Search Bar & Calendar Period Button
        Row(
          children: [
            // Search Input
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withValues(alpha: 0.40),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x140D2C3A), // rgba(13,44,58,0.08)
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      size: 22,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        onChanged: widget.onSearchChanged,
                        style: AppTextStyles.bodyMd,
                        decoration: InputDecoration(
                          hintText: 'Cari transaksi...',
                          hintStyle: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.secondary,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Period Calendar Button
            InkWell(
              onTap: widget.onCalendarTap,
              borderRadius: BorderRadius.circular(999),
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x3365D0F4), // rgba(101,208,244,0.2)
                      blurRadius: 16,
                      spreadRadius: -4,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Mei 2024',
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.expand_more_rounded,
                      size: 18,
                      color: AppColors.secondary,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // 2. Segmented Control Time Period Pills (Hari, Minggu, Bulan, Tahun)
        Container(
          width: double.infinity,
          height: 44,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(999),
            boxShadow: const [
              BoxShadow(
                color: Color(0x100D2C3A),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: _tabs.map((tab) {
              final isSelected = tab == _selectedTab;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTab = tab;
                    });
                    widget.onPeriodSelected?.call(tab);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryContainer
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(999),
                      boxShadow: isSelected
                          ? const [
                              BoxShadow(
                                color: Color(0x7365D0F4), // rgba(101,208,244,0.45)
                                blurRadius: 14,
                                spreadRadius: -2,
                                offset: Offset(0, 6),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Text(
                        tab,
                        style: AppTextStyles.labelMd.copyWith(
                          color: isSelected
                              ? Colors.white
                              : AppColors.secondary,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
