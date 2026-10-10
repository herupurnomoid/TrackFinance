import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/animations.dart';
import 'transaction_date_picker_modal.dart';
import 'transaction_time_picker_modal.dart';

class AdditionalDetailsSection extends StatelessWidget {
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final TextEditingController noteController;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<TimeOfDay> onTimeChanged;

  const AdditionalDetailsSection({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
    required this.noteController,
    required this.onDateChanged,
    required this.onTimeChanged,
  });


  static const List<String> _monthNamesLong = [
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

  String _formatDate(DateTime date) {
    final dayStr = date.day.toString();
    final monthStr = _monthNamesLong[date.month - 1];
    return '$dayStr $monthStr ${date.year}';
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour.$minute';
  }

  void _openDatePicker(BuildContext context) {
    TransactionDatePickerModal.show(
      context,
      initialDate: selectedDate,
      onConfirm: onDateChanged,
    );
  }

  void _openTimePicker(BuildContext context) {
    TransactionTimePickerModal.show(
      context,
      initialTime: selectedTime,
      onConfirm: onTimeChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Two-Column Row: Tanggal & Waktu (Side-by-side)
        Row(
          children: [
            // 1. Tanggal Card (Only opens Date Picker)
            Expanded(
              child: PressableScale(
                onTap: () => _openDatePicker(context),
                scaleFactor: 0.96,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
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
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDBE1FF), // primary-fixed
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.8),
                              blurRadius: 1,
                              offset: const Offset(0, -1),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.calendar_today_rounded,
                            size: 19,
                            color: AppColors.tactilePrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tanggal',
                              style: AppTextStyles.labelSm.copyWith(
                                color: const Color(0xFF434655),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatDate(selectedDate),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.labelMd.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.tactileTextPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.expand_more_rounded,
                        size: 18,
                        color: Color(0xFF737686),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            // 2. Waktu Card (Only opens Time Picker)
            Expanded(
              child: PressableScale(
                onTap: () => _openTimePicker(context),
                scaleFactor: 0.96,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
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
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDDE1FF), // secondary-fixed
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.8),
                              blurRadius: 1,
                              offset: const Offset(0, -1),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.schedule_rounded,
                            size: 19,
                            color: Color(0xFF3755C3),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Waktu',
                              style: AppTextStyles.labelSm.copyWith(
                                color: const Color(0xFF434655),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatTime(selectedTime),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyles.labelMd.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.tactileTextPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.expand_more_rounded,
                        size: 18,
                        color: Color(0xFF737686),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Catatan (Opsional) Inset Well
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 2.0),
              child: Text(
                'Catatan (opsional)',
                style: AppTextStyles.labelMd.copyWith(
                  color: const Color(0xFF434655),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE2E7FF), // surface-container-high
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFC3C6D7).withValues(alpha: 0.4),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.08),
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
              child: ValueListenableBuilder<TextEditingValue>(
                valueListenable: noteController,
                builder: (context, val, _) {
                  final length = val.text.length;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: noteController,
                        maxLength: 50,
                        maxLines: 2,
                        buildCounter: (
                          context, {
                          required currentLength,
                          required isFocused,
                          maxLength,
                        }) =>
                            null, // Custom bottom counter
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.tactileTextPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          hintText: 'Tulis rincian catatan...',
                          hintStyle: AppTextStyles.bodyMd.copyWith(
                            color: const Color(0xFF737686),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          '$length/50',
                          style: AppTextStyles.labelSm.copyWith(
                            color: const Color(0xFF737686),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
