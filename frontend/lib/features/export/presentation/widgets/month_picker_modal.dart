import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Modal Bottom Sheet untuk Pemilihan Bulan dan Tahun
class MonthPickerModal extends StatefulWidget {
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
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MonthPickerModal(
        initialDate: initialDate,
        onMonthSelected: onMonthSelected,
      ),
    );
  }

  @override
  State<MonthPickerModal> createState() => _MonthPickerModalState();
}

class _MonthPickerModalState extends State<MonthPickerModal> {
  late int _selectedYear;
  late int _selectedMonth;

  static const List<String> _months = [
    'Januari', 'Februari', 'Maret', 'April',
    'Mei', 'Juni', 'Juli', 'Agustus',
    'September', 'Oktober', 'November', 'Desember'
  ];

  @override
  void initState() {
    super.initState();
    _selectedYear = widget.initialDate.year;
    _selectedMonth = widget.initialDate.month;
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

          // Year Selector Stepper Row (< 2026 >)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left_rounded, size: 28),
                color: const Color(0xFF004AC6),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() => _selectedYear--);
                },
              ),
              Text(
                '$_selectedYear',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF131B2E),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right_rounded, size: 28),
                color: const Color(0xFF004AC6),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  setState(() => _selectedYear++);
                },
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 12 Months Grid (3 columns x 4 rows)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 12,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.2,
            ),
            itemBuilder: (context, index) {
              final monthNumber = index + 1;
              final isCurrentSelected = monthNumber == _selectedMonth;

              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _selectedMonth = monthNumber);
                  widget.onMonthSelected(DateTime(_selectedYear, _selectedMonth, 1));
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
                      _months[index],
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
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
