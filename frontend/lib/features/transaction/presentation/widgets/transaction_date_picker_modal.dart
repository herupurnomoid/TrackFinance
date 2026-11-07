import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/animations.dart';

/// Modal Bottom Sheet untuk Pemilihan Tanggal, Bulan, dan Tahun pada Tambah/Edit Transaksi.
/// Mengadopsi three-wheel scroller picker (Tanggal, Bulan & Tahun) yang konsisten
/// dengan halaman Laporan dan Ekspor/Impor: tipografi jernih, masker gradasi fade,
/// lensa sorot seleksi tengah halus, tombol Batal dan tombol tactile CTA 'Terapkan'.
class TransactionDatePickerModal extends StatefulWidget {
  final DateTime initialDate;
  final ValueChanged<DateTime> onConfirm;
  final String title;

  const TransactionDatePickerModal({
    super.key,
    required this.initialDate,
    required this.onConfirm,
    this.title = 'Pilih Tanggal',
  });

  static Future<void> show(
    BuildContext context, {
    required DateTime initialDate,
    required ValueChanged<DateTime> onConfirm,
    String title = 'Pilih Tanggal',
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x73131B2E), // on-surface/45
      builder: (context) => TransactionDatePickerModal(
        initialDate: initialDate,
        onConfirm: onConfirm,
        title: title,
      ),
    );
  }

  @override
  State<TransactionDatePickerModal> createState() =>
      _TransactionDatePickerModalState();
}

class _TransactionDatePickerModalState
    extends State<TransactionDatePickerModal> {
  late int _selectedYear;
  late int _selectedMonthIndex; // 0-based: 0 = Jan .. 11 = Des
  late int _selectedDay; // 1-based: 1 .. 31

  late FixedExtentScrollController _dayController;
  late FixedExtentScrollController _monthController;
  late FixedExtentScrollController _yearController;

  static const int _minYear = 2020;
  static const int _maxYear = 2035;
  late final List<int> _years = List.generate(
    _maxYear - _minYear + 1,
    (index) => _minYear + index,
  );

  static const List<String> _monthsShort = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  @override
  void initState() {
    super.initState();
    final init = widget.initialDate;
    _selectedYear = init.year.clamp(_minYear, _maxYear);
    _selectedMonthIndex = (init.month - 1).clamp(0, 11);
    final maxDays = _daysInSelectedMonth;
    _selectedDay = init.day.clamp(1, maxDays);

    final initialYearIndex =
        (_selectedYear - _minYear).clamp(0, _years.length - 1);
    _dayController =
        FixedExtentScrollController(initialItem: _selectedDay - 1);
    _monthController =
        FixedExtentScrollController(initialItem: _selectedMonthIndex);
    _yearController =
        FixedExtentScrollController(initialItem: initialYearIndex);
  }

  @override
  void dispose() {
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  int get _daysInSelectedMonth =>
      DateUtils.getDaysInMonth(_selectedYear, _selectedMonthIndex + 1);

  void _adjustSelectedDay() {
    final maxDays = _daysInSelectedMonth;
    if (_selectedDay > maxDays) {
      _selectedDay = maxDays;
    }
    if (_dayController.hasClients && _dayController.selectedItem >= maxDays) {
      _dayController.jumpToItem(maxDays - 1);
    }
  }

  void _handleSelectDay(int day) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedDay = day;
    });
    final index = day - 1;
    if (_dayController.hasClients && _dayController.selectedItem != index) {
      _dayController.animateToItem(
        index,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _handleSelectMonth(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedMonthIndex = index;
      _adjustSelectedDay();
    });
    if (_monthController.hasClients && _monthController.selectedItem != index) {
      _monthController.animateToItem(
        index,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _handleSelectYear(int year) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedYear = year;
      _adjustSelectedDay();
    });
    final index = (_selectedYear - _minYear).clamp(0, _years.length - 1);
    if (_yearController.hasClients && _yearController.selectedItem != index) {
      _yearController.animateToItem(
        index,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _handleApply() {
    HapticFeedback.mediumImpact();
    final picked =
        DateTime(_selectedYear, _selectedMonthIndex + 1, _selectedDay);
    widget.onConfirm(picked);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x260F172A),
            blurRadius: 32,
            offset: Offset(0, -6),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        12,
        20,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Drag Indicator Handle
          Center(
            child: Container(
              width: 40,
              height: 4.5,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // 2. Header Bar: Ikon + Judul + Badge Hari Ini / Tahun Ini
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF6FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.calendar_month_rounded,
                      size: 19,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(
                  child: Text(
                    widget.title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 3. Wheel Scroller Picker (Tanggal, Bulan, Tahun)
          _buildScrollerPicker(),

          const SizedBox(height: 20),

          // 4. Action Buttons: Batal & Terapkan
          _buildActionButtons(),
        ],
      ),
    );
  }

  /// Tiga Roda Scroller Polosan & Clean (Tanggal, Bulan, Tahun)
  Widget _buildScrollerPicker() {
    return SizedBox(
      height: 190,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Kolom Header Label & Roda Scroller
          Column(
            children: [
              // Header Label Kolom
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 6),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Text(
                          'TANGGAL',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF94A3B8),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: Text(
                          'BULAN',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF94A3B8),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: Text(
                          'TAHUN',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF94A3B8),
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Roda Scroller (Tanggal, Bulan, Tahun)
              Expanded(
                child: Row(
                  children: [
                    // Kolom Roda Tanggal
                    Expanded(
                      flex: 2,
                      child: CupertinoPicker(
                        scrollController: _dayController,
                        itemExtent: 46,
                        diameterRatio: 2.2,
                        squeeze: 1.0,
                        useMagnifier: false,
                        selectionOverlay: const SizedBox.shrink(),
                        onSelectedItemChanged: (index) {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _selectedDay = index + 1;
                          });
                        },
                        children: List.generate(_daysInSelectedMonth, (index) {
                          final day = index + 1;
                          final isSelected = day == _selectedDay;
                          final dayStr = day.toString().padLeft(2, '0');
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _handleSelectDay(day),
                            child: Center(
                              child: Text(
                                dayStr,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: isSelected ? 22 : 15,
                                  fontWeight: isSelected
                                      ? FontWeight.w800
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? const Color(0xFF0F172A)
                                      : const Color(0xFF94A3B8),
                                  letterSpacing: isSelected ? -0.3 : -0.1,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    // Kolom Roda Bulan
                    Expanded(
                      flex: 3,
                      child: CupertinoPicker(
                        scrollController: _monthController,
                        itemExtent: 46,
                        diameterRatio: 2.2,
                        squeeze: 1.0,
                        useMagnifier: false,
                        selectionOverlay: const SizedBox.shrink(),
                        onSelectedItemChanged: (index) {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _selectedMonthIndex = index;
                            _adjustSelectedDay();
                          });
                        },
                        children: List.generate(12, (index) {
                          final isSelected = index == _selectedMonthIndex;
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _handleSelectMonth(index),
                            child: Center(
                              child: Text(
                                _monthsShort[index],
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: isSelected ? 22 : 15,
                                  fontWeight: isSelected
                                      ? FontWeight.w800
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? const Color(0xFF0F172A)
                                      : const Color(0xFF94A3B8),
                                  letterSpacing: isSelected ? -0.3 : -0.1,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),

                    // Kolom Roda Tahun
                    Expanded(
                      flex: 3,
                      child: CupertinoPicker(
                        scrollController: _yearController,
                        itemExtent: 46,
                        diameterRatio: 2.2,
                        squeeze: 1.0,
                        useMagnifier: false,
                        selectionOverlay: const SizedBox.shrink(),
                        onSelectedItemChanged: (index) {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _selectedYear = _years[index];
                            _adjustSelectedDay();
                          });
                        },
                        children: List.generate(_years.length, (index) {
                          final year = _years[index];
                          final isSelected = year == _selectedYear;
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => _handleSelectYear(year),
                            child: Center(
                              child: Text(
                                '$year',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: isSelected ? 22 : 15,
                                  fontWeight: isSelected
                                      ? FontWeight.w800
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? const Color(0xFF0F172A)
                                      : const Color(0xFF94A3B8),
                                  letterSpacing: isSelected ? -0.3 : -0.1,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Masker Gradasi Atas (Top Fade)
          Positioned(
            top: 24,
            left: 0,
            right: 0,
            height: 38,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Masker Gradasi Bawah (Bottom Fade)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 38,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.white,
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Tombol Aksi: Batal & Terapkan
  Widget _buildActionButtons() {
    return Row(
      children: [
        // Tombol Batal
        Expanded(
          flex: 2,
          child: PressableScale(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).pop();
            },
            scaleFactor: 0.95,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  'Batal',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Tombol Terapkan (Tactile Gradient Blue)
        Expanded(
          flex: 3,
          child: PressableScale(
            onTap: _handleApply,
            scaleFactor: 0.95,
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF2563EB),
                    Color(0xFF1D4ED8),
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x402563EB),
                    blurRadius: 14,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_outline_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Terapkan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.2,
                    ),
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
