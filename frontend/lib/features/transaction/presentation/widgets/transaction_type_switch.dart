import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// Segmented Switcher Control Jenis Transaksi (Pengeluaran & Pemasukan)
/// Menerapkan desain tactile skeuomorphic dengan animated sliding pill dan ikon aksi,
/// identik dengan switch pada halaman Impor & Ekspor serta Manajemen Kategori.
class TransactionTypeSwitch extends StatelessWidget {
  final bool isExpense;
  final ValueChanged<bool> onChanged;

  const TransactionTypeSwitch({
    super.key,
    required this.isExpense,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFDAE2FD),
        borderRadius: BorderRadius.circular(999),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14131B2E),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Sliding Active Pill Background
          AnimatedAlign(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            alignment: isExpense ? Alignment.centerLeft : Alignment.centerRight,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              child: Container(
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF2563EB), // Primary Container
                      Color(0xFF004AC6), // Primary Blue
                    ],
                  ),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.35),
                    width: 1,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x472563EB),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Clickable Tab Buttons with Icons
          Row(
            children: [
              // Tab Pengeluaran
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (!isExpense) {
                      HapticFeedback.lightImpact();
                      onChanged(true);
                    }
                  },
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_downward_rounded,
                          size: 18,
                          color: isExpense ? Colors.white : const Color(0xFF434655),
                        ),
                        const SizedBox(width: 6),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isExpense ? Colors.white : const Color(0xFF434655),
                          ),
                          child: const Text('Pengeluaran'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Tab Pemasukan
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (isExpense) {
                      HapticFeedback.lightImpact();
                      onChanged(false);
                    }
                  },
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_upward_rounded,
                          size: 18,
                          color: !isExpense ? Colors.white : const Color(0xFF434655),
                        ),
                        const SizedBox(width: 6),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: !isExpense ? Colors.white : const Color(0xFF434655),
                          ),
                          child: const Text('Pemasukan'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
