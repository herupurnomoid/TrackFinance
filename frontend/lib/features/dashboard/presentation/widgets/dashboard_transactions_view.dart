import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/dashboard_transaction_model.dart';
import 'dashboard_search_and_filter.dart';

class DashboardTransactionsView extends StatefulWidget {
  /// Batas awal kartu transaksi yang dipasang ke pohon widget pada satu waktu
  /// agar perangkat Android RAM rendah (1-2 GB) tetap mulus meski ada ratusan transaksi.
  static const int kInitialVisibleTransactions = 60;
  static const int kLoadMoreStep = 60;

  final DashboardPeriod period;
  final List<DashboardTransaction> transactions;
  final int currentYear;
  final int currentMonthIndex;
  final int currentDecadeStart;
  final DateTimeRange? dateRange;
  final Function(DashboardTransaction)? onTransactionTap;

  const DashboardTransactionsView({
    super.key,
    required this.period,
    required this.transactions,
    required this.currentYear,
    required this.currentMonthIndex,
    required this.currentDecadeStart,
    this.dateRange,
    this.onTransactionTap,
  });

  @override
  State<DashboardTransactionsView> createState() =>
      _DashboardTransactionsViewState();
}

class _DashboardTransactionsViewState extends State<DashboardTransactionsView> {
  int _visibleLimit = DashboardTransactionsView.kInitialVisibleTransactions;

  @override
  void didUpdateWidget(covariant DashboardTransactionsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.period != widget.period ||
        oldWidget.currentYear != widget.currentYear ||
        oldWidget.currentMonthIndex != widget.currentMonthIndex ||
        oldWidget.currentDecadeStart != widget.currentDecadeStart ||
        oldWidget.dateRange != widget.dateRange) {
      _visibleLimit = DashboardTransactionsView.kInitialVisibleTransactions;
    }
  }

  List<DashboardTransaction> _deduplicateTransactions() {
    final seen = <String>{};
    return widget.transactions.where((t) => seen.add(t.id)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final uniqueTransactions = _deduplicateTransactions();

    if (widget.dateRange != null) {
      return _buildDailyView(uniqueTransactions);
    }

    switch (widget.period) {
      case DashboardPeriod.hari:
        return _buildDailyView(uniqueTransactions);
      case DashboardPeriod.minggu:
        return _buildWeeklyView(uniqueTransactions);
      case DashboardPeriod.bulan:
        return _buildMonthlyView(uniqueTransactions);
      case DashboardPeriod.tahun:
        return _buildYearlyView(uniqueTransactions);
    }
  }

  // 1. Daily View (Per Tanggal atau Rentang Tanggal)
  Widget _buildDailyView(List<DashboardTransaction> uniqueTransactions) {
    final dateRange = widget.dateRange;
    final DateTime? rangeStart = dateRange != null
        ? DateTime(
            dateRange.start.year,
            dateRange.start.month,
            dateRange.start.day,
          )
        : null;
    final DateTime? rangeEnd = dateRange != null
        ? DateTime(
            dateRange.end.year,
            dateRange.end.month,
            dateRange.end.day,
          )
        : null;

    final filtered = uniqueTransactions.where((t) {
      if (rangeStart != null && rangeEnd != null) {
        final txDate = DateTime(t.year, t.month + 1, t.day);
        return !txDate.isBefore(rangeStart) && !txDate.isAfter(rangeEnd);
      }
      return t.year == widget.currentYear &&
          t.month == widget.currentMonthIndex;
    }).toList();

    if (dateRange != null) {
      filtered.sort((a, b) {
        final dateA = DateTime(a.year, a.month + 1, a.day);
        final dateB = DateTime(b.year, b.month + 1, b.day);
        return dateB.compareTo(dateA);
      });
    }

    if (filtered.isEmpty) {
      return _buildEmptyState();
    }

    // Kelompokkan per dateStr dengan urutan terbalik
    final Map<String, List<DashboardTransaction>> grouped = {};
    for (final item in filtered) {
      grouped.putIfAbsent(item.dateStr, () => []).add(item);
    }

    int renderedCards = 0;
    final List<Widget> daySections = [];

    for (final entry in grouped.entries) {
      if (renderedCards >= _visibleLimit) break;

      final dateStr = entry.key;
      final items = entry.value;

      // Rekap harian dihitung dari seluruh item pada tanggal tersebut agar tetap akurat
      int dayIncome = 0;
      int dayExpense = 0;
      for (final tx in items) {
        if (tx.isIncome) {
          dayIncome += tx.amount;
        } else {
          dayExpense += tx.amount.abs();
        }
      }

      final remainingBudget = _visibleLimit - renderedCards;
      final visibleItems = items.length <= remainingBudget
          ? items
          : items.sublist(0, remainingBudget);
      renderedCards += visibleItems.length;

      daySections.add(
        Padding(
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
                children: visibleItems.map((tx) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _buildTransactionCard(tx),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      );
    }

    final remainingTotal = filtered.length - renderedCards;
    if (remainingTotal > 0) {
      daySections.add(_buildLoadMoreButton(remainingTotal));
    }

    return Column(children: daySections);
  }

  Widget _buildLoadMoreButton(int remainingCount) {
    return Padding(
      padding: const EdgeInsets.only(top: 4, bottom: 16),
      child: Center(
        child: TextButton.icon(
          onPressed: () {
            HapticFeedback.lightImpact();
            setState(() {
              _visibleLimit += DashboardTransactionsView.kLoadMoreStep;
            });
          },
          style: TextButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF2563EB),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFDBEAFE)),
            ),
          ),
          icon: const Icon(Icons.expand_more_rounded, size: 18),
          label: Text(
            'Tampilkan lebih banyak ($remainingCount lainnya)',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  // 2. Weekly View (Rekap per Minggu di Bulan Ini, dimulai dari hari Senin)
  Widget _buildWeeklyView(List<DashboardTransaction> uniqueTransactions) {
    final month = widget.currentMonthIndex + 1;
    final firstDayOfMonth = DateTime(widget.currentYear, month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(widget.currentYear, month);
    final lastDayOfMonth = DateTime(widget.currentYear, month, daysInMonth);

    // Hari Senin di minggu pertama (mundur ke hari Senin terdekat jika tanggal 1 bukan hari Senin)
    final daysFromMonday = firstDayOfMonth.weekday - DateTime.monday;
    final firstMonday = DateTime(
      firstDayOfMonth.year,
      firstDayOfMonth.month,
      firstDayOfMonth.day - daysFromMonday,
    );

    // Hari Minggu di minggu terakhir (maju ke hari Minggu terdekat jika hari terakhir bukan hari Minggu)
    final daysToSunday = DateTime.sunday - lastDayOfMonth.weekday;
    final lastSunday = DateTime(
      lastDayOfMonth.year,
      lastDayOfMonth.month,
      lastDayOfMonth.day + daysToSunday,
    );

    final List<_SummaryItem> weeklyItems = [];
    DateTime currentMonday = firstMonday;
    int weekNum = 1;

    final now = DateTime.now();
    final todayMidnight = DateTime(now.year, now.month, now.day);

    while (!currentMonday.isAfter(lastSunday)) {
      final weekStart = currentMonday;
      final weekEnd = DateTime(
        currentMonday.year,
        currentMonday.month,
        currentMonday.day + 6,
      );

      final startDayStr = weekStart.day.toString().padLeft(2, '0');
      final startMonthStr = DashboardDataStore.monthsShort[weekStart.month - 1];
      final endDayStr = weekEnd.day.toString().padLeft(2, '0');
      final endMonthStr = DashboardDataStore.monthsShort[weekEnd.month - 1];

      final startMidnight = DateTime(weekStart.year, weekStart.month, weekStart.day);
      final endMidnight = DateTime(weekEnd.year, weekEnd.month, weekEnd.day);

      int wIncome = 0;
      int wExpense = 0;

      for (final tx in uniqueTransactions) {
        final txDate = DateTime(tx.year, tx.month + 1, tx.day);
        if (!txDate.isBefore(startMidnight) && !txDate.isAfter(endMidnight)) {
          if (tx.isIncome) {
            wIncome += tx.amount;
          } else {
            wExpense += tx.amount.abs();
          }
        }
      }

      final isCurrentWeek = !todayMidnight.isBefore(startMidnight) &&
          !todayMidnight.isAfter(endMidnight);

      weeklyItems.add(_SummaryItem(
        title: 'Minggu $weekNum',
        subtitle: '$startDayStr $startMonthStr - $endDayStr $endMonthStr',
        income: wIncome,
        expense: wExpense,
        isActive: isCurrentWeek,
      ));

      currentMonday = DateTime(
        currentMonday.year,
        currentMonday.month,
        currentMonday.day + 7,
      );
      weekNum++;
    }

    return _buildSummaryCardList(weeklyItems);
  }

  // 3. Monthly View (12 Bulan dalam currentYear)
  Widget _buildMonthlyView(List<DashboardTransaction> uniqueTransactions) {
    final incomeByMonth = List<int>.filled(12, 0);
    final expenseByMonth = List<int>.filled(12, 0);
    for (final tx in uniqueTransactions) {
      if (tx.year == widget.currentYear && tx.month >= 0 && tx.month < 12) {
        if (tx.isIncome) {
          incomeByMonth[tx.month] += tx.amount;
        } else {
          expenseByMonth[tx.month] += tx.amount.abs();
        }
      }
    }

    final List<_SummaryItem> monthlyItems = List.generate(12, (m) {
      return _SummaryItem(
        title: DashboardDataStore.monthsName[m],
        subtitle: '${widget.currentYear}',
        income: incomeByMonth[m],
        expense: expenseByMonth[m],
        isActive: m == widget.currentMonthIndex,
      );
    });

    return _buildSummaryCardList(monthlyItems);
  }

  // 4. Yearly View (Dekade Aktif)
  Widget _buildYearlyView(List<DashboardTransaction> uniqueTransactions) {
    final minYear = DashboardDataStore.getMinTransactionYear(uniqueTransactions);
    final maxYear = DashboardDataStore.getMaxTransactionYear(uniqueTransactions);

    final startYear = widget.currentDecadeStart < minYear
        ? widget.currentDecadeStart
        : minYear;
    final endYear = (widget.currentDecadeStart + 9) > maxYear
        ? (widget.currentDecadeStart + 9)
        : maxYear;

    final int span = endYear - startYear + 1;
    final incomeByYear = List<int>.filled(span, 0);
    final expenseByYear = List<int>.filled(span, 0);
    for (final tx in uniqueTransactions) {
      final idx = tx.year - startYear;
      if (idx >= 0 && idx < span) {
        if (tx.isIncome) {
          incomeByYear[idx] += tx.amount;
        } else {
          expenseByYear[idx] += tx.amount.abs();
        }
      }
    }

    final List<_SummaryItem> yearlyItems = List.generate(span, (idx) {
      final y = startYear + idx;
      return _SummaryItem(
        title: '$y',
        subtitle: 'Januari - Desember',
        income: incomeByYear[idx],
        expense: expenseByYear[idx],
        isActive: y == widget.currentYear,
      );
    });

    return _buildSummaryCardList(yearlyItems);
  }

  Widget _buildTransactionCard(DashboardTransaction tx) {
    return RepaintBoundary(
      child: _PressableCard(
        onTap: () => widget.onTransactionTap?.call(tx),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  // Ikon 3D Panah Melayang (Pemasukan: Panah Naik, Pengeluaran: Panah Turun) Tanpa Container
                  Image.asset(
                    tx.isIncome
                        ? 'assets/icons/3d/income_arrow.webp'
                        : 'assets/icons/3d/expense_arrow.webp',
                    width: 40,
                    height: 40,
                    fit: BoxFit.contain,
                    cacheWidth: 120,
                    cacheHeight: 120,
                    filterQuality: FilterQuality.low,
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
      ),
    );
  }

  Widget _buildSummaryCardList(List<_SummaryItem> items) {
    if (items.isEmpty) return _buildEmptyState();

    return Column(
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: RepaintBoundary(
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

class _PressableCardState extends State<_PressableCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  // Lazy controller: kartu yang tidak disentuh tidak mengalokasikan Ticker/AnimationController sama sekali.
  AnimationController? _pressController;
  Animation<double>? _pressCurve;

  AnimationController _ensureController() {
    final existing = _pressController;
    if (existing != null) return existing;
    final ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _pressController = ctrl;
    _pressCurve = CurvedAnimation(parent: ctrl, curve: Curves.easeOutCubic);
    return ctrl;
  }

  @override
  void dispose() {
    _pressController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final card = Container(
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
            if (_isPressed == highlighted) return;
            setState(() => _isPressed = highlighted);
            final ctrl = _ensureController();
            if (highlighted) {
              ctrl.forward();
            } else {
              ctrl.reverse();
            }
          },
          onTap: () {
            HapticFeedback.lightImpact();
            widget.onTap?.call();
          },
          child: widget.child,
        ),
      ),
    );

    final curve = _pressCurve;
    if (curve == null) {
      return card;
    }

    return AnimatedBuilder(
      animation: curve,
      child: card,
      builder: (context, child) {
        final t = curve.value;
        if (t == 0.0) return child!;
        return FractionalTranslation(
          translation: Offset(0, 0.025 * t),
          child: Transform.scale(
            scale: 1.0 - (0.02 * t),
            child: child,
          ),
        );
      },
    );
  }
}
