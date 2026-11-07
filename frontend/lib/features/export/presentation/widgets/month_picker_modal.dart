import 'package:flutter/material.dart';
import '../../../report/presentation/widgets/report_month_picker_modal.dart';

/// Modal Bottom Sheet untuk Pemilihan Bulan dan Tahun pada Halaman Ekspor.
/// Mengadopsi dual-wheel scroller picker yang sama persis dengan halaman Laporan ([ReportMonthPickerModal]).
class MonthPickerModal extends StatelessWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onMonthSelected;

  const MonthPickerModal({
    super.key,
    required this.initialDate,
    required this.onMonthSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required DateTime initialDate,
    required ValueChanged<DateTime> onMonthSelected,
  }) {
    return ReportMonthPickerModal.show(
      context,
      initialYear: initialDate.year,
      initialMonthIndex: initialDate.month - 1,
      onApply: (year, monthIndex) {
        onMonthSelected(DateTime(year, monthIndex + 1, 1));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ReportMonthPickerModal(
      initialYear: initialDate.year,
      initialMonthIndex: initialDate.month - 1,
      onApply: (year, monthIndex) {
        onMonthSelected(DateTime(year, monthIndex + 1, 1));
      },
    );
  }
}
