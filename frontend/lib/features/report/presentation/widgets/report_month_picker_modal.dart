import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Modal Bottom Sheet untuk Pemilihan Filter Bulan dan Tahun pada Laporan
/// Sesuai referensi visual tactile skeuomorphic dengan stepper navigasi tahun,
/// grid tombol bulan 3x4, preview rentang tanggal dinamis, dan tombol CTA 'Terapkan'.
class ReportMonthPickerModal extends StatefulWidget {
  final int initialYear;
  final int initialMonthIndex; // 0-based: 0 = Jan, 8 = Sep, 9 = Okt, dsb.
  final void Function(int year, int monthIndex) onApply;

  const ReportMonthPickerModal({
    super.key,
    required this.initialYear,
    required this.initialMonthIndex,
    required this.onApply,
  });

  static Future<void> show(
    BuildContext context, {
    required int initialYear,
    required int initialMonthIndex,
    required void Function(int year, int monthIndex) onApply,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0x73131B2E), // on-surface/45
      builder: (context) => ReportMonthPickerModal(
        initialYear: initialYear,
        initialMonthIndex: initialMonthIndex,
        onApply: onApply,
      ),
    );
  }

  @override
  State<ReportMonthPickerModal> createState() => _ReportMonthPickerModalState();
}

class _ReportMonthPickerModalState extends State<ReportMonthPickerModal> {
  late int _selectedYear;
  late int _selectedMonthIndex;

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
    _selectedYear = widget.initialYear;
    _selectedMonthIndex = widget.initialMonthIndex;
  }

  /// Menghitung hari terakhir bulan yang dipilih secara akurat (termasuk tahun kabisat)
  int _getLastDayOfMonth(int year, int monthIndex) {
    // monthIndex 0-based: 0 = Jan (month 1).
    // DateTime(year, monthIndex + 2, 0).day memberikan hari terakhir dari bulan (monthIndex + 1)
    return DateTime(year, monthIndex + 2, 0).day;
  }

  String get _selectedRangeText {
    final monthName = _monthsShort[_selectedMonthIndex];
    final lastDay = _getLastDayOfMonth(_selectedYear, _selectedMonthIndex);
    return '1 $monthName - $lastDay $monthName $_selectedYear';
  }

  bool get _isCurrentYear {
    return _selectedYear == DateTime.now().year;
  }

  void _handlePrevYear() {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedYear--;
    });
  }

  void _handleNextYear() {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedYear++;
    });
  }

  void _handleSelectMonth(int index) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedMonthIndex = index;
    });
  }

  void _handleApply() {
    HapticFeedback.mediumImpact();
    widget.onApply(_selectedYear, _selectedMonthIndex);
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
            color: Color(0x2E0F172A),
            blurRadius: 30,
            offset: Offset(0, -8),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Drag Indicator Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 2. Year Selector Navigation Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Tombol Tahun Sebelumnya
                _buildTactileCircularButton(
                  icon: Icons.chevron_left_rounded,
                  onTap: _handlePrevYear,
                  tooltip: 'Tahun Sebelumnya',
                ),

                // Center Year Display & Badge
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$_selectedYear',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF131B2E),
                        letterSpacing: -0.4,
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
                          color: const Color(0xFFE2E7FF),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Tahun Ini',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF004AC6),
                            letterSpacing: 0.2,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                // Tombol Tahun Berikutnya
                _buildTactileCircularButton(
                  icon: Icons.chevron_right_rounded,
                  onTap: _handleNextYear,
                  tooltip: 'Tahun Berikutnya',
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // 3. Month Selector 3x4 Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 12,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              mainAxisExtent: 48,
            ),
            itemBuilder: (context, index) {
              final isSelected = index == _selectedMonthIndex;
              final monthLabel = _monthsShort[index];

              return _buildMonthCell(
                label: monthLabel,
                isSelected: isSelected,
                onTap: () => _handleSelectMonth(index),
              );
            },
          ),

          const SizedBox(height: 18),

          // 4. Quick Action Summary Subtext: Rentang Terpilih
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Rentang Terpilih',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF737686),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _selectedRangeText,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF004AC6),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 5. Main Action CTA: Terapkan
          _buildApplyButton(),
        ],
      ),
    );
  }

  /// Tombol Navigasi Tahun Bundar Tactile
  Widget _buildTactileCircularButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F0F172A),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
              BoxShadow(
                color: Color(0x0F0F172A),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              icon,
              size: 22,
              color: const Color(0xFF131B2E),
            ),
          ),
        ),
      ),
    );
  }

  /// Kotak Sel Bulan (Tactile Cell)
  Widget _buildMonthCell({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: isSelected
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF2563EB),
                      Color(0xFF004AC6),
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
                  ? Colors.transparent
                  : const Color(0xFFE2E8F0),
              width: 1.0,
            ),
            boxShadow: isSelected
                ? const [
                    BoxShadow(
                      color: Color(0x59004AC6),
                      blurRadius: 16,
                      offset: Offset(0, 6),
                    ),
                    BoxShadow(
                      color: Color(0x33004AC6),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ]
                : const [
                    BoxShadow(
                      color: Color(0x140F172A),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                    BoxShadow(
                      color: Color(0x0A0F172A),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: isSelected ? 15 : 14,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF131B2E),
              ),
            ),
          ),
        ),
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
          height: 52,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF2563EB),
                Color(0xFF004AC6),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: const [
              BoxShadow(
                color: Color(0x592563EB),
                blurRadius: 18,
                offset: Offset(0, 6),
              ),
              BoxShadow(
                color: Color(0x331E40AF),
                blurRadius: 4,
                offset: Offset(0, 2),
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
