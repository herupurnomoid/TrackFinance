import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/dashboard_transaction_model.dart';
import 'dashboard_search_and_filter.dart';

/// Modal Bottom Sheet Tactile untuk memilih Periode Waktu:
/// - Hari & Minggu: Dapat memilih Bulan DAN Tahun secara interaktif
/// - Bulan: Memilih Tahun
/// - Tahun: Memilih Dekade
class DashboardTimePickerModal extends StatefulWidget {
  final DashboardPeriod period;
  final int currentYear;
  final int currentMonthIndex;
  final int currentDecadeStart;
  final int minYear;
  final int maxYear;
  final void Function(int monthIndex, int year)? onSelectMonthAndYear;
  final ValueChanged<int> onSelectMonth;
  final ValueChanged<int> onSelectYear;
  final ValueChanged<int> onSelectDecade;

  const DashboardTimePickerModal({
    super.key,
    required this.period,
    required this.currentYear,
    required this.currentMonthIndex,
    required this.currentDecadeStart,
    required this.minYear,
    required this.maxYear,
    this.onSelectMonthAndYear,
    required this.onSelectMonth,
    required this.onSelectYear,
    required this.onSelectDecade,
  });

  static Future<void> show(
    BuildContext context, {
    required DashboardPeriod period,
    required int currentYear,
    required int currentMonthIndex,
    required int currentDecadeStart,
    required int minYear,
    required int maxYear,
    void Function(int monthIndex, int year)? onSelectMonthAndYear,
    required ValueChanged<int> onSelectMonth,
    required ValueChanged<int> onSelectYear,
    required ValueChanged<int> onSelectDecade,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0xFF0F172A).withValues(alpha: 0.45),
      builder: (context) => DashboardTimePickerModal(
        period: period,
        currentYear: currentYear,
        currentMonthIndex: currentMonthIndex,
        currentDecadeStart: currentDecadeStart,
        minYear: minYear,
        maxYear: maxYear,
        onSelectMonthAndYear: onSelectMonthAndYear,
        onSelectMonth: onSelectMonth,
        onSelectYear: onSelectYear,
        onSelectDecade: onSelectDecade,
      ),
    );
  }

  @override
  State<DashboardTimePickerModal> createState() =>
      _DashboardTimePickerModalState();
}

class _DashboardTimePickerModalState extends State<DashboardTimePickerModal> {
  late int _selectedYear;
  late int _selectedMonthIndex;
  late int _selectedDecadeStart;
  late ScrollController _yearScrollController;

  late List<int> _availableYears;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.currentYear;
    _selectedMonthIndex = widget.currentMonthIndex;
    _selectedDecadeStart = widget.currentDecadeStart;

    final startYear = math.min(widget.minYear, 2020);
    final endYear = math.max(widget.maxYear, 2030);
    _availableYears = List<int>.generate(
      (endYear - startYear) + 1,
      (i) => startYear + i,
    );

    _yearScrollController = ScrollController();

    // Auto-scroll ke tahun aktif setelah frame pertama
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToSelectedYear();
    });
  }

  @override
  void dispose() {
    _yearScrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedYear() {
    final index = _availableYears.indexOf(_selectedYear);
    if (index != -1 && _yearScrollController.hasClients) {
      final offset = (index * 76.0) - 100.0;
      _yearScrollController.animateTo(
        math.max(0.0, offset),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }

  void _applySelection() {
    HapticFeedback.lightImpact();
    if (widget.period == DashboardPeriod.hari ||
        widget.period == DashboardPeriod.minggu) {
      if (widget.onSelectMonthAndYear != null) {
        widget.onSelectMonthAndYear!(_selectedMonthIndex, _selectedYear);
      } else {
        widget.onSelectYear(_selectedYear);
        widget.onSelectMonth(_selectedMonthIndex);
      }
    } else if (widget.period == DashboardPeriod.bulan) {
      widget.onSelectYear(_selectedYear);
    } else if (widget.period == DashboardPeriod.tahun) {
      widget.onSelectDecade(_selectedDecadeStart);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x260F172A),
            blurRadius: 24,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag Handle
          Container(
            width: 38,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 14),

          // Header: Judul & Active Preview Badge
          _buildHeaderRow(),
          const SizedBox(height: 16),

          // Content berdasarkan Active Period
          if (widget.period == DashboardPeriod.hari ||
              widget.period == DashboardPeriod.minggu) ...[
            _buildYearAndMonthPicker(),
          ] else if (widget.period == DashboardPeriod.bulan) ...[
            _buildYearOnlyGrid(),
          ] else ...[
            _buildDecadeList(),
          ],

          const SizedBox(height: 18),

          // Action Buttons: Batal & Terapkan
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    String title = 'Pilih Periode Waktu';
    String previewText = '';

    if (widget.period == DashboardPeriod.hari ||
        widget.period == DashboardPeriod.minggu) {
      title = 'Pilih Bulan & Tahun';
      previewText =
          '${DashboardDataStore.monthsName[_selectedMonthIndex]} $_selectedYear';
    } else if (widget.period == DashboardPeriod.bulan) {
      title = 'Pilih Tahun';
      previewText = '$_selectedYear';
    } else if (widget.period == DashboardPeriod.tahun) {
      title = 'Pilih Dekade';
      previewText = '$_selectedDecadeStart - ${_selectedDecadeStart + 9}';
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        if (previewText.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.calendar_month_rounded,
                  size: 13,
                  color: Color(0xFF2563EB),
                ),
                const SizedBox(width: 4),
                Text(
                  previewText,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1D4ED8),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildYearAndMonthPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Bagian Pemilihan Tahun (Pilih Tahun dengan Navigasi Panah + Chips Horizontal)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PILIH TAHUN',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: const Color(0xFF64748B),
              ),
            ),
            Text(
              'Aktif: $_selectedYear',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2563EB),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Horizontal Year Selector with Nav Arrows
        Container(
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              // Panah Prev Tahun
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, size: 22),
                color: const Color(0xFF334155),
                splashRadius: 20,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _selectedYear--;
                    if (!_availableYears.contains(_selectedYear)) {
                      _availableYears.insert(0, _selectedYear);
                    }
                  });
                  _scrollToSelectedYear();
                },
              ),

              // Horizontal Scrollable Years
              Expanded(
                child: SizedBox(
                  height: 38,
                  child: ListView.separated(
                    controller: _yearScrollController,
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    itemCount: _availableYears.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final year = _availableYears[idx];
                      final isSelected = year == _selectedYear;
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          setState(() => _selectedYear = year);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF2563EB)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF1D4ED8)
                                  : const Color(0xFFE2E8F0),
                              width: 1.0,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFF2563EB)
                                          .withValues(alpha: 0.35),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.02),
                                      blurRadius: 2,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                          ),
                          child: Center(
                            child: Text(
                              '$year',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : const Color(0xFF334155),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Panah Next Tahun
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, size: 22),
                color: const Color(0xFF334155),
                splashRadius: 20,
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _selectedYear++;
                    if (!_availableYears.contains(_selectedYear)) {
                      _availableYears.add(_selectedYear);
                    }
                  });
                  _scrollToSelectedYear();
                },
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 2. Bagian Pemilihan Bulan (12 Bulan Grid)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'PILIH BULAN ($_selectedYear)',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
                color: const Color(0xFF64748B),
              ),
            ),
            Text(
              'Ketuk bulan untuk memilih',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 12 Bulan Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.3,
          ),
          itemCount: 12,
          itemBuilder: (context, idx) {
            final isSelected = idx == _selectedMonthIndex;
            return _buildTactileButton(
              label: DashboardDataStore.monthsName[idx],
              isSelected: isSelected,
              onTap: () {
                setState(() => _selectedMonthIndex = idx);
                // Langsung terapkan bulan & tahun yang dipilih
                _applySelection();
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildYearOnlyGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.3,
      ),
      itemCount: _availableYears.length,
      itemBuilder: (context, idx) {
        final y = _availableYears[idx];
        final isSelected = y == _selectedYear;
        return _buildTactileButton(
          label: '$y',
          isSelected: isSelected,
          onTap: () {
            setState(() => _selectedYear = y);
            _applySelection();
          },
        );
      },
    );
  }

  Widget _buildDecadeList() {
    final minDecade = (_availableYears.first ~/ 10) * 10;
    final maxDecade = (_availableYears.last ~/ 10) * 10;
    final List<int> decades = [];
    for (int d = minDecade; d <= maxDecade; d += 10) {
      decades.add(d);
    }

    return Column(
      children: decades.map((d) {
        final isSelected = d == _selectedDecadeStart;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: SizedBox(
            width: double.infinity,
            height: 46,
            child: _buildTactileButton(
              label: '$d - ${d + 9}',
              isSelected: isSelected,
              onTap: () {
                setState(() => _selectedDecadeStart = d);
                _applySelection();
              },
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTactileButton({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: isSelected
                ? const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF3B82F6),
                      Color(0xFF2563EB),
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
                  ? const Color(0xFF60A5FA)
                  : const Color(0xFFE2E8F0),
              width: 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF1E293B),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Tombol Batal
        Expanded(
          flex: 1,
          child: SizedBox(
            height: 46,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF1F5F9),
                foregroundColor: const Color(0xFF64748B),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
              ),
              child: Text(
                'Batal',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF64748B),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),

        // Tombol Terapkan
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 46,
            child: ElevatedButton(
              onPressed: _applySelection,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                elevation: 2,
                shadowColor: const Color(0xFF2563EB).withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_rounded, size: 18, color: Colors.white),
                  const SizedBox(width: 6),
                  Text(
                    'Terapkan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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
