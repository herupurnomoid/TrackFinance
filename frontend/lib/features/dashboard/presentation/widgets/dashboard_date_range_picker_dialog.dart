import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Modal Kalender Pemilihan Rentang Tanggal (Date Range Picker Dialog)
/// Sesuai referensi visual Material 3:
/// - Header "Select date range" dan preview rentang (e.g. "Jul 1, 2024 - Jul 17, 2024")
/// - Divider pemisah halus
/// - Inisial hari: S M T W T F S
/// - Navigasi bulan (chevrons < dan >)
/// - Highlight rentang: lingkaran ungu pada start/end dan strip ungu muda pada tanggal diantaranya
/// - Tombol aksi "Cancel" dan "OK" di kanan bawah
class DashboardDateRangePickerDialog extends StatefulWidget {
  final DateTimeRange? initialDateRange;
  final DateTime firstDate;
  final DateTime lastDate;

  const DashboardDateRangePickerDialog({
    super.key,
    this.initialDateRange,
    required this.firstDate,
    required this.lastDate,
  });

  /// Menampilkan dialog pemilih rentang tanggal
  static Future<DateTimeRange?> show(
    BuildContext context, {
    DateTimeRange? initialDateRange,
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    return showDialog<DateTimeRange>(
      context: context,
      barrierDismissible: true,
      barrierColor: const Color(0x730F172A),
      builder: (context) => DashboardDateRangePickerDialog(
        initialDateRange: initialDateRange,
        firstDate: firstDate ?? DateTime(2020, 1, 1),
        lastDate: lastDate ?? DateTime(2035, 12, 31),
      ),
    );
  }

  @override
  State<DashboardDateRangePickerDialog> createState() =>
      _DashboardDateRangePickerDialogState();
}

class _DashboardDateRangePickerDialogState
    extends State<DashboardDateRangePickerDialog> {
  DateTime? _startDate;
  DateTime? _endDate;
  late DateTime _displayedMonth;

  static const Color _primaryPurple = Color(0xFF6750A4);
  static const Color _rangeStripColor = Color(0xFFE8DEF8);
  static const Color _surfaceBg = Color(0xFFF3EDF7);
  static const Color _textPrimary = Color(0xFF1D1B20);
  static const Color _textSecondary = Color(0xFF49454F);
  static const Color _dividerColor = Color(0xFFCAC4D0);

  static const List<String> _monthsShort = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static const List<String> _monthsFull = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static const List<String> _weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

  @override
  void initState() {
    super.initState();
    if (widget.initialDateRange != null) {
      _startDate = DateTime(
        widget.initialDateRange!.start.year,
        widget.initialDateRange!.start.month,
        widget.initialDateRange!.start.day,
      );
      _endDate = DateTime(
        widget.initialDateRange!.end.year,
        widget.initialDateRange!.end.month,
        widget.initialDateRange!.end.day,
      );
      _displayedMonth = DateTime(_startDate!.year, _startDate!.month);
    } else {
      final now = DateTime.now();
      _displayedMonth = DateTime(now.year, now.month);
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  void _onDayTapped(DateTime day) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_startDate == null || (_startDate != null && _endDate != null)) {
        // Mulai rentang baru
        _startDate = day;
        _endDate = null;
      } else {
        // Start sudah ada, memilih end
        if (day.isBefore(_startDate!)) {
          _startDate = day;
          _endDate = null;
        } else {
          _endDate = day;
        }
      }
    });
  }

  void _goToPrevMonth() {
    final prevMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1);
    if (!prevMonth.isBefore(DateTime(widget.firstDate.year, widget.firstDate.month))) {
      HapticFeedback.lightImpact();
      setState(() => _displayedMonth = prevMonth);
    }
  }

  void _goToNextMonth() {
    final nextMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1);
    if (!nextMonth.isAfter(DateTime(widget.lastDate.year, widget.lastDate.month))) {
      HapticFeedback.lightImpact();
      setState(() => _displayedMonth = nextMonth);
    }
  }

  String get _rangeHeadline {
    if (_startDate != null && _endDate != null) {
      final startStr =
          '${_monthsShort[_startDate!.month - 1]} ${_startDate!.day}, ${_startDate!.year}';
      final endStr =
          '${_monthsShort[_endDate!.month - 1]} ${_endDate!.day}, ${_endDate!.year}';
      return '$startStr - $endStr';
    } else if (_startDate != null) {
      final startStr =
          '${_monthsShort[_startDate!.month - 1]} ${_startDate!.day}, ${_startDate!.year}';
      return '$startStr - Select end date';
    }
    return 'Select dates';
  }

  @override
  Widget build(BuildContext context) {
    final isPrevDisabled = _displayedMonth.year == widget.firstDate.year &&
        _displayedMonth.month == widget.firstDate.month;
    final isNextDisabled = _displayedMonth.year == widget.lastDate.year &&
        _displayedMonth.month == widget.lastDate.month;

    return Dialog(
      backgroundColor: _surfaceBg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Label Atas: "Select date range"
              Text(
                'Select date range',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _textSecondary,
                  letterSpacing: 0.1,
                ),
              ),
              const SizedBox(height: 10),

              // 2. Headline Rentang Tanggal Terpilih: "Jul 1, 2024 - Jul 17, 2024"
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  _rangeHeadline,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: _textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // 3. Garis Pembatas
              const Divider(color: _dividerColor, thickness: 1, height: 1),
              const SizedBox(height: 14),

              // 4. Baris Inisial Hari: S M T W T F S
              Row(
                children: _weekdays.map((day) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        day,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              // 5. Header Bulan & Navigasi Chevrons (< Month Year >)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_monthsFull[_displayedMonth.month - 1]} ${_displayedMonth.year}',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded, size: 22),
                        color: _textPrimary,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        onPressed: isPrevDisabled ? null : _goToPrevMonth,
                        tooltip: 'Previous month',
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right_rounded, size: 22),
                        color: _textPrimary,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                        onPressed: isNextDisabled ? null : _goToNextMonth,
                        tooltip: 'Next month',
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 6),

              // 6. Grid Kalender Interaktif
              _buildMonthGrid(),

              const SizedBox(height: 18),

              // 7. Tombol Aksi di Kanan Bawah: Cancel dan OK
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: _primaryPurple,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      textStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: _startDate == null
                        ? null
                        : () {
                            HapticFeedback.mediumImpact();
                            final selectedRange = DateTimeRange(
                              start: _startDate!,
                              end: _endDate ?? _startDate!,
                            );
                            Navigator.of(context).pop(selectedRange);
                          },
                    style: TextButton.styleFrom(
                      foregroundColor: _primaryPurple,
                      disabledForegroundColor: _primaryPurple.withValues(alpha: 0.38),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      textStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('OK'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthGrid() {
    final year = _displayedMonth.year;
    final month = _displayedMonth.month;
    final daysInMonth = DateUtils.getDaysInMonth(year, month);
    // Hari pertama dalam bulan: DateTime.weekday (Senin=1 .. Minggu=7).
    // Karena kolom kita mulai dari Sunday (S), maka offset = weekday % 7 (Minggu => 0)
    final firstWeekday = DateTime(year, month, 1).weekday;
    final leadingEmptyCount = firstWeekday % 7;
    final totalSlots = leadingEmptyCount + daysInMonth;
    final rowCount = (totalSlots / 7).ceil();

    final now = DateTime.now();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(rowCount, (rowIndex) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.5),
          child: Row(
            children: List.generate(7, (colIndex) {
              final slotIndex = (rowIndex * 7) + colIndex;
              final dayNumber = slotIndex - leadingEmptyCount + 1;

              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const Expanded(child: SizedBox(height: 38));
              }

              final date = DateTime(year, month, dayNumber);
              final isToday = _isSameDay(date, now);

              final isStart = _startDate != null && _isSameDay(date, _startDate!);
              final isEnd = _endDate != null && _isSameDay(date, _endDate!);
              final hasFullRange = _startDate != null &&
                  _endDate != null &&
                  !_startDate!.isAtSameMomentAs(_endDate!);

              final isInBetween = hasFullRange &&
                  date.isAfter(_startDate!) &&
                  date.isBefore(_endDate!);

              final isSunday = colIndex == 0;
              final isSaturday = colIndex == 6;
              final isFirstDayOfMonth = dayNumber == 1;
              final isLastDayOfMonth = dayNumber == daysInMonth;

              return Expanded(
                child: SizedBox(
                  height: 38,
                  child: InkWell(
                    onTap: () => _onDayTapped(date),
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // A. Strip latar belakang ungu muda untuk rentang
                        if (isInBetween)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: _rangeStripColor,
                                borderRadius: BorderRadius.horizontal(
                                  left: (isSunday || isFirstDayOfMonth)
                                      ? const Radius.circular(20)
                                      : Radius.zero,
                                  right: (isSaturday || isLastDayOfMonth)
                                      ? const Radius.circular(20)
                                      : Radius.zero,
                                ),
                              ),
                            ),
                          ),

                        // B. Koneksi strip sebelah kanan dari start date
                        if (isStart && hasFullRange)
                          Positioned(
                            left: 19,
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: _rangeStripColor,
                                borderRadius: BorderRadius.horizontal(
                                  right: (isSaturday || isLastDayOfMonth)
                                      ? const Radius.circular(20)
                                      : Radius.zero,
                                ),
                              ),
                            ),
                          ),

                        // C. Koneksi strip sebelah kiri ke end date
                        if (isEnd && hasFullRange)
                          Positioned(
                            left: 0,
                            right: 19,
                            top: 0,
                            bottom: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: _rangeStripColor,
                                borderRadius: BorderRadius.horizontal(
                                  left: (isSunday || isFirstDayOfMonth)
                                      ? const Radius.circular(20)
                                      : Radius.zero,
                                ),
                              ),
                            ),
                          ),

                        // D. Lingkaran tanggal utama
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (isStart || isEnd)
                                ? _primaryPurple
                                : Colors.transparent,
                            border: (isToday && !isStart && !isEnd)
                                ? Border.all(color: _primaryPurple, width: 1.2)
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$dayNumber',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13.5,
                              fontWeight: (isStart || isEnd)
                                  ? FontWeight.w700
                                  : (isInBetween
                                      ? FontWeight.w600
                                      : FontWeight.w400),
                              color: (isStart || isEnd)
                                  ? Colors.white
                                  : _textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        );
      }),
    );
  }
}
