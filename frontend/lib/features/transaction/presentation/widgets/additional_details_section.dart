import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/animations.dart';
import 'transaction_date_picker_modal.dart';
import 'transaction_time_picker_modal.dart';

/// Komponen Input Baris Tanggal & Waktu (No Container & No Background Color)
class TransactionDateTimeSection extends StatelessWidget {
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<TimeOfDay> onTimeChanged;

  const TransactionDateTimeSection({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
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
    return Row(
      children: [
        // 1. Tanggal (No Container, No Background Color, Borderless Floating dengan Bottom Border)
        Expanded(
          child: PressableScale(
            onTap: () => _openDatePicker(context),
            scaleFactor: 0.96,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFFC3C6D7).withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today_rounded,
                    size: 20,
                    color: Color(0xFF2563EB),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tanggal',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                            letterSpacing: 0.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(selectedDate),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.tactileTextPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.expand_more_rounded,
                    size: 18,
                    color: Color(0xFF64748B),
                  ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(width: 16),

        // 2. Waktu (No Container, No Background Color, Borderless Floating dengan Bottom Border)
        Expanded(
          child: PressableScale(
            onTap: () => _openTimePicker(context),
            scaleFactor: 0.96,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border(
                  bottom: BorderSide(
                    color: const Color(0xFFC3C6D7).withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.schedule_rounded,
                    size: 20,
                    color: Color(0xFF2563EB),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Waktu',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF64748B),
                            letterSpacing: 0.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatTime(selectedTime),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.tactileTextPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.expand_more_rounded,
                    size: 18,
                    color: Color(0xFF64748B),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Komponen Input Catatan / Deskripsi Transaksi (Inset Well)
class TransactionNoteInput extends StatelessWidget {
  final TextEditingController noteController;

  const TransactionNoteInput({
    super.key,
    required this.noteController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}

/// Backward compatible widget for any callers relying on [AdditionalDetailsSection]
class AdditionalDetailsSection extends StatelessWidget {
  final DateTime selectedDate;
  final TimeOfDay selectedTime;
  final TextEditingController? noteController;
  final ValueChanged<DateTime> onDateChanged;
  final ValueChanged<TimeOfDay> onTimeChanged;

  const AdditionalDetailsSection({
    super.key,
    required this.selectedDate,
    required this.selectedTime,
    this.noteController,
    required this.onDateChanged,
    required this.onTimeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TransactionDateTimeSection(
          selectedDate: selectedDate,
          selectedTime: selectedTime,
          onDateChanged: onDateChanged,
          onTimeChanged: onTimeChanged,
        ),
        if (noteController != null) ...[
          const SizedBox(height: 16),
          TransactionNoteInput(noteController: noteController!),
        ],
      ],
    );
  }
}
