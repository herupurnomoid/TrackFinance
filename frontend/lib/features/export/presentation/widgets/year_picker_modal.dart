import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Modal Bottom Sheet untuk Pemilihan Tahun
/// Menerapkan GoPay Wealth / Modern Tactile Finance design system:
/// - Squircle cards & pills
/// - Inset shadow and smooth blue gradients
/// - Haptic feedback on selection
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
  late int _baseYear;

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialYear;
    _baseYear = (_selectedYear ~/ 9) * 9;
  }

  @override
  Widget build(BuildContext context) {
    final List<int> years = List.generate(9, (index) => _baseYear + index);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x1F131B2E),
            blurRadius: 24,
            offset: Offset(0, -8),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle Bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(999),
            ),
          ),

          const SizedBox(height: 18),

          // Header Row (< Periode Tahun >)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, size: 28),
                color: const Color(0xFF004AC6),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() => _baseYear -= 9);
                },
              ),
              Expanded(
                child: Text(
                  'Pilih Tahun (${years.first} - ${years.last})',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF131B2E),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, size: 28),
                color: const Color(0xFF004AC6),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() => _baseYear += 9);
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 9 Years Grid (3 columns x 3 rows)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: years.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.2,
            ),
            itemBuilder: (context, index) {
              final year = years[index];
              final isCurrentSelected = year == _selectedYear;

              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _selectedYear = year);
                  widget.onYearSelected(year);
                  Navigator.of(context).pop();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    gradient: isCurrentSelected
                        ? const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFF2563EB),
                              Color(0xFF004AC6),
                            ],
                          )
                        : null,
                    color: isCurrentSelected ? null : const Color(0xFFF2F3FF),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isCurrentSelected
                          ? Colors.transparent
                          : const Color(0xFFE2E8F0),
                    ),
                    boxShadow: isCurrentSelected
                        ? const [
                            BoxShadow(
                              color: Color(0x382563EB),
                              blurRadius: 8,
                              offset: Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$year',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: isCurrentSelected
                            ? FontWeight.w700
                            : FontWeight.w600,
                        color: isCurrentSelected
                            ? Colors.white
                            : const Color(0xFF131B2E),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
