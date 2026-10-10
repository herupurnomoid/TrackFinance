import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/dashboard_transaction_model.dart';
import 'dashboard_search_and_filter.dart';

class DashboardTransactionsView extends StatelessWidget {
  final DashboardPeriod period;
  final List<DashboardTransaction> transactions;
  final int currentYear;
  final int currentMonthIndex;
  final int currentDecadeStart;
  final Function(DashboardTransaction)? onTransactionTap;

  const DashboardTransactionsView({
    super.key,
    required this.period,
    required this.transactions,
    required this.currentYear,
    required this.currentMonthIndex,
    required this.currentDecadeStart,
    this.onTransactionTap,
  });

  @override
  Widget build(BuildContext context) {
    switch (period) {
      case DashboardPeriod.hari:
        return _buildDailyView();
      case DashboardPeriod.minggu:
        return _buildWeeklyView();
      case DashboardPeriod.bulan:
        return _buildMonthlyView();
      case DashboardPeriod.tahun:
        return _buildYearlyView();
    }
  }

  // 1. Daily View (Per Tanggal)
  Widget _buildDailyView() {
    final filtered = transactions.where((t) =>
        t.year == currentYear && t.month == currentMonthIndex).toList();

    if (filtered.isEmpty) {
      return _buildEmptyState();
    }

    // Kelompokkan per dateStr dengan urutan terbalik
    final Map<String, List<DashboardTransaction>> grouped = {};
    for (final item in filtered) {
      grouped.putIfAbsent(item.dateStr, () => []).add(item);
    }

    return Column(
      children: grouped.entries.map((entry) {
        final dateStr = entry.key;
        final items = entry.value;

        int dayIncome = 0;
        int dayExpense = 0;
        for (final tx in items) {
          if (tx.isIncome) {
            dayIncome += tx.amount;
          } else {
            dayExpense += tx.amount.abs();
          }
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Tanggal & Rekap Hari Ini
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        dateStr,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                          letterSpacing: 0.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (dayExpense > 0)
                          Text(
                            DashboardDataStore.formatCurrency(-dayExpense, showSign: true),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFFDC2626),
                            ),
                          ),
                        if (dayExpense > 0 && dayIncome > 0)
                          const SizedBox(width: 8),
                        if (dayIncome > 0)
                          Text(
                            DashboardDataStore.formatCurrency(dayIncome, showSign: true),
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF16A34A),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Daftar Kartu Transaksi
              Column(
                children: items.map((tx) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildTransactionCard(tx),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // 2. Weekly View (Rekap per Minggu di Bulan Ini)
  Widget _buildWeeklyView() {
    final filtered = transactions.where((t) =>
        t.year == currentYear && t.month == currentMonthIndex).toList();

    // Buat 4 atau 5 minggu untuk bulan aktif
    final daysInMonth = DateUtils.getDaysInMonth(currentYear, currentMonthIndex + 1);
    final mShort = DashboardDataStore.monthsShort[currentMonthIndex];

    final List<_SummaryItem> weeklyItems = [];
    int startDay = 1;
    int weekNum = 1;

    while (startDay <= daysInMonth) {
      final date = DateTime(currentYear, currentMonthIndex + 1, startDay);
      final daysToSunday = (7 - date.weekday);
      int endDay = startDay + daysToSunday;
      if (endDay > daysInMonth) endDay = daysInMonth;

      final startStr = startDay.toString().padLeft(2, '0');
      final endStr = endDay.toString().padLeft(2, '0');

      int wIncome = 0;
      int wExpense = 0;
      for (final tx in filtered) {
        if (tx.day >= startDay && tx.day <= endDay) {
          if (tx.isIncome) {
            wIncome += tx.amount;
          } else {
            wExpense += tx.amount.abs();
          }
        }
      }

      weeklyItems.add(_SummaryItem(
        title: 'Minggu $weekNum',
        subtitle: '$startStr $mShort - $endStr $mShort',
        income: wIncome,
        expense: wExpense,
        isActive: false,
      ));

      startDay = endDay + 1;
      weekNum++;
    }

    return _buildSummaryCardList(weeklyItems);
  }

  // 3. Monthly View (12 Bulan dalam currentYear)
  Widget _buildMonthlyView() {
    final filtered = transactions.where((t) => t.year == currentYear).toList();

    final List<_SummaryItem> monthlyItems = [];
    for (int m = 0; m < 12; m++) {
      int mIncome = 0;
      int mExpense = 0;

      for (final tx in filtered) {
        if (tx.month == m) {
          if (tx.isIncome) {
            mIncome += tx.amount;
          } else {
            mExpense += tx.amount.abs();
          }
        }
      }

      monthlyItems.add(_SummaryItem(
        title: DashboardDataStore.monthsName[m],
        subtitle: '$currentYear',
        income: mIncome,
        expense: mExpense,
        isActive: m == currentMonthIndex,
      ));
    }

    return _buildSummaryCardList(monthlyItems);
  }

  // 4. Yearly View (Dekade Aktif)
  Widget _buildYearlyView() {
    final minYear = DashboardDataStore.getMinTransactionYear(transactions);
    final maxYear = DashboardDataStore.getMaxTransactionYear(transactions);

    final startYear = currentDecadeStart < minYear ? currentDecadeStart : minYear;
    final endYear = (currentDecadeStart + 9) > maxYear ? (currentDecadeStart + 9) : maxYear;

    final List<_SummaryItem> yearlyItems = [];
    for (int y = startYear; y <= endYear; y++) {
      int yIncome = 0;
      int yExpense = 0;

      for (final tx in transactions) {
        if (tx.year == y) {
          if (tx.isIncome) {
            yIncome += tx.amount;
          } else {
            yExpense += tx.amount.abs();
          }
        }
      }

      yearlyItems.add(_SummaryItem(
        title: '$y',
        subtitle: 'Januari - Desember',
        income: yIncome,
        expense: yExpense,
        isActive: y == currentYear,
      ));
    }

    return _buildSummaryCardList(yearlyItems);
  }

  Widget _buildTransactionCard(DashboardTransaction tx) {
    return _PressableCard(
      onTap: () => onTransactionTap?.call(tx),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                // Badge Icon Lingkaran Transparan
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: tx.isIncome
                        ? const Color(0xFFDCFCE7)
                        : const Color(0xFFFEE2E2),
                    border: Border.all(
                      color: tx.isIncome
                          ? const Color(0xFFBBF7D0)
                          : const Color(0xFFFECACA),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      tx.isIncome
                          ? Icons.arrow_downward_rounded
                          : Icons.arrow_upward_rounded,
                      size: 20,
                      color: tx.isIncome
                          ? const Color(0xFF16A34A)
                          : const Color(0xFFDC2626),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tx.category,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        tx.meta,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Nominal Transaksi
          Text(
            DashboardDataStore.formatCurrency(tx.amount, showSign: true),
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14.5,
              fontWeight: FontWeight.w700,
              color: tx.isIncome
                  ? const Color(0xFF16A34A)
                  : const Color(0xFFDC2626),
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCardList(List<_SummaryItem> items) {
    if (items.isEmpty) return _buildEmptyState();

    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _PressableCard(
            isActive: item.isActive,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.subtitle,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      DashboardDataStore.formatCurrency(item.income, showSign: true),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF16A34A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DashboardDataStore.formatCurrency(-item.expense, showSign: true),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFDC2626),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8, bottom: 24),
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFDBEAFE)),
              ),
              child: const Center(
                child: Icon(
                  Icons.receipt_long_rounded,
                  size: 28,
                  color: Color(0xFF2563EB),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Belum Ada Transaksi',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tidak ada catatan transaksi pada periode ini.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem {
  final String title;
  final String subtitle;
  final int income;
  final int expense;
  final bool isActive;

  const _SummaryItem({
    required this.title,
    required this.subtitle,
    required this.income,
    required this.expense,
    required this.isActive,
  });
}

class _PressableCard extends StatefulWidget {
  final Widget child;
  final bool isActive;
  final VoidCallback? onTap;

  const _PressableCard({
    required this.child,
    this.isActive = false,
    this.onTap,
  });

  @override
  State<_PressableCard> createState() => _PressableCardState();
}

class _PressableCardState extends State<_PressableCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: Offset(0, _isPressed ? 0.025 : 0.0),
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOutCubic,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOutCubic,
        child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: widget.isActive
              ? const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFF8FAFC),
                    Color(0xFFEEF2F6),
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
            color: widget.isActive
                ? const Color(0xFF2563EB)
                : const Color(0xFFE2E8F0),
            width: widget.isActive ? 1.5 : 1.0,
          ),
          boxShadow: _isPressed
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ]
              : [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            onHighlightChanged: (highlighted) {
              setState(() => _isPressed = highlighted);
            },
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onTap?.call();
            },
            child: widget.child,
          ),
        ),
      ),
    ),
  );
}
}
