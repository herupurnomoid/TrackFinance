import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/animations.dart';

/// Modal Bottom Sheet Khusus Pemilihan Tanggal.
/// Mengadopsi Soft Skeuomorphism 7-kolom kalender tactile.
class TransactionDatePickerModal extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onConfirm;

  const TransactionDatePickerModal({
    super.key,
    required this.initialDate,
    required this.onConfirm,
  });

  static Future<void> show(
    BuildContext context, {
    required DateTime initialDate,
    required ValueChanged<DateTime> onConfirm,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0xFF0F172A).withValues(alpha: 0.45),
      builder: (context) => TransactionDatePickerModal(
        initialDate: initialDate,
        onConfirm: onConfirm,
      ),
    );
  }

  @override
  State<TransactionDatePickerModal> createState() =>
      _TransactionDatePickerModalState();
}

class _TransactionDatePickerModalState
    extends State<TransactionDatePickerModal> {
  late DateTime _selectedDate;
  late DateTime _displayedMonth;

  static const List<String> _monthNames = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static const List<String> _dayHeaders = [
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min',
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _displayedMonth =
        DateTime(widget.initialDate.year, widget.initialDate.month, 1);
  }

  void _previousMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month - 1,
        1,
      );
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(
        _displayedMonth.year,
        _displayedMonth.month + 1,
        1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(
      _displayedMonth.year,
      _displayedMonth.month,
    );
    final firstDayWeekday = _displayedMonth.weekday; // 1 = Mon, 7 = Sun
    final leadingEmptyCount = firstDayWeekday - 1;

    final monthTitle =
        '${_monthNames[_displayedMonth.month - 1]} ${_displayedMonth.year}';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x300F172A),
            blurRadius: 32,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0F172A).withValues(alpha: 0.15),
                        blurRadius: 1,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Title
              Text(
                'Pilih Tanggal',
                style: AppTextStyles.headlineSm.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.tactileTextPrimary,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 16),

              // Month Navigation Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildNavButton(
                    icon: Icons.chevron_left_rounded,
                    onTap: _previousMonth,
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_rounded,
                        size: 18,
                        color: AppColors.tactilePrimary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        monthTitle,
                        style: AppTextStyles.headlineSm.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.tactileTextPrimary,
                        ),
                      ),
                    ],
                  ),
                  _buildNavButton(
                    icon: Icons.chevron_right_rounded,
                    onTap: _nextMonth,
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Calendar Grid Box
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Day of Week Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: _dayHeaders.map((day) {
                        final isSun = day == 'Min';
                        return SizedBox(
                          width: 36,
                          child: Text(
                            day,
                            textAlign: TextAlign.center,
                            style: AppTextStyles.labelSm.copyWith(
                              color: isSun
                                  ? const Color(0xFFDC2626)
                                  : const Color(0xFF64748B),
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 8),

                    // Month Dates Matrix
                    GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 7,
                        mainAxisSpacing: 6,
                        crossAxisSpacing: 4,
                        childAspectRatio: 1.0,
                      ),
                      itemCount: leadingEmptyCount + daysInMonth,
                      itemBuilder: (context, index) {
                        if (index < leadingEmptyCount) {
                          return const SizedBox();
                        }
                        final dayNumber = index - leadingEmptyCount + 1;
                        final cellDate = DateTime(
                          _displayedMonth.year,
                          _displayedMonth.month,
                          dayNumber,
                        );

                        final isSelected = cellDate.year == _selectedDate.year &&
                            cellDate.month == _selectedDate.month &&
                            cellDate.day == _selectedDate.day;

                        return _buildDateCell(
                          dayNumber: dayNumber,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              _selectedDate = cellDate;
                            });
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Action Buttons: Batal & Pilih Tanggal
              Row(
                children: [
                  // Tombol Batal
                  Expanded(
                    child: PressableScale(
                      onTap: () => Navigator.of(context).pop(),
                      scaleFactor: 0.95,
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white,
                              Color(0xFFF8FAFC),
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
                              color: const Color(0xFF0F172A).withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Batal',
                            style: AppTextStyles.labelLg.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.tactileTextPrimary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Tombol Pilih
                  Expanded(
                    child: PressableScale(
                      onTap: () {
                        widget.onConfirm(_selectedDate);
                        Navigator.of(context).pop();
                      },
                      scaleFactor: 0.95,
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFF2563EB),
                              Color(0xFF1E40AF),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                            BoxShadow(
                              color: const Color(0xFF1E40AF).withValues(alpha: 0.25),
                              blurRadius: 3,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            'Pilih',
                            style: AppTextStyles.labelLg.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return PressableScale(
      onTap: onTap,
      scaleFactor: 0.92,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Color(0xFFF8FAFC),
            ],
          ),
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 20,
          color: AppColors.tactileTextPrimary,
        ),
      ),
    );
  }

  Widget _buildDateCell({
    required int dayNumber,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return PressableScale(
      onTap: onTap,
      scaleFactor: 0.90,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF2563EB),
                    Color(0xFF1D4ED8),
                  ],
                )
              : const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    Color(0xFFF8FAFC),
                  ],
                ),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1D4ED8)
                : const Color(0xFFE2E8F0),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.40),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Center(
          child: Text(
            dayNumber.toString(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.tactileTextPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
