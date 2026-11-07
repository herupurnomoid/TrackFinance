import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Modal Bottom Sheet untuk Pemilihan Tahun pada Halaman Ekspor.
/// Menggunakan wheel scroller picker (Tahun 2020–2035) dengan estetika modern,
/// konsisten dengan [ReportMonthPickerModal] pada halaman Laporan: tipografi jernih,
/// masker gradasi fade, dan tombol tactile CTA 'Terapkan'.
class YearPickerModal extends StatefulWidget {
  final int initialYear;
  final ValueChanged<int> onYearSelected;

  const YearPickerModal({
    super.key,
    required this.initialYear,
    required this.onYearSelected,
  });

  static Future<void> show(
    BuildContext context, {
    required int initialYear,
    required ValueChanged<int> onYearSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x73131B2E), // on-surface/45
      builder: (context) => YearPickerModal(
        initialYear: initialYear,
        onYearSelected: onYearSelected,
      ),
    );
  }

  @override
  State<YearPickerModal> createState() => _YearPickerModalState();
}

class _YearPickerModalState extends State<YearPickerModal> {
  late int _selectedYear;
  late FixedExtentScrollController _yearController;

  static const int _minYear = 2020;
  static const int _maxYear = 2035;
  late final List<int> _years = List.generate(
    _maxYear - _minYear + 1,
    (index) => _minYear + index,
  );

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialYear.clamp(_minYear, _maxYear);
    final initialYearIndex =
        (_selectedYear - _minYear).clamp(0, _years.length - 1);
    _yearController =
        FixedExtentScrollController(initialItem: initialYearIndex);
  }

  @override
  void dispose() {
    _yearController.dispose();
    super.dispose();
  }

  bool get _isCurrentYear {
    return _selectedYear == DateTime.now().year;
  }

  void _handleSelectYear(int year) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedYear = year;
    });
    final index = (_selectedYear - _minYear).clamp(0, _years.length - 1);
    if (_yearController.hasClients &&
        _yearController.selectedItem != index) {
      _yearController.animateToItem(
        index,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _handleApply() {
    HapticFeedback.mediumImpact();
    widget.onYearSelected(_selectedYear);
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

          // 2. Header Bar: Ikon + Judul + Badge Tahun Ini
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
                    'Pilih Tahun',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.3,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (_isCurrentYear) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: const Color(0xFFDBEAFE),
                        width: 1.0,
                      ),
                    ),
                    child: Text(
                      'Tahun Ini',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF2563EB),
                        letterSpacing: 0.1,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 12),

          // 3. Wheel Scroller Picker (Tahun)
          _buildScrollerPicker(),

          const SizedBox(height: 20),

          // 4. Main Action CTA: Terapkan
          _buildApplyButton(),
        ],
      ),
    );
  }

  /// Roda Scroller Tahun Polosan & Clean
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

              // Roda Scroller Tahun
              Expanded(
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

  /// Tombol Terapkan (Tactile Gradient Button)
  Widget _buildApplyButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _handleApply,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          height: 50,
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
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                size: 20,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                'Terapkan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
