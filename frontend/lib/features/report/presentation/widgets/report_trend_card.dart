import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/report_data_model.dart';

/// Kartu Tren Keuangan Modern Tactile
/// Menampilkan grafik garis ganda (dual-line chart) untuk pengeluaran (merah)
/// dan pemasukan (hijau) secara default tanpa filter, dilengkapi area gradasi,
/// knots titik transaksi, dan tooltip interaktif.
class ReportTrendCard extends StatefulWidget {
  final int expenseTotal;
  final int incomeTotal;
  final bool isEmpty;
  final bool isExpenseMode;
  final List<ReportDailyTrendItem>? dailyTrends;

  const ReportTrendCard({
    super.key,
    this.expenseTotal = 0,
    this.incomeTotal = 0,
    this.isEmpty = true,
    this.isExpenseMode = true,
    this.dailyTrends,
  });

  @override
  State<ReportTrendCard> createState() => _ReportTrendCardState();
}

class _ReportTrendCardState extends State<ReportTrendCard> {
  int? _selectedBarIndex = 0; // Default index 0 (01 Okt) terpilih untuk tooltip

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            Color(0xFFF8FAFC),
          ],
        ),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x142563EB),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Color(0x0D0F172A),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Card: Judul & Legenda (Keluar / Masuk)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Tren Keuangan',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF131B2E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLegendDot(
                    color: const Color(0xFFBA1A1A), // Red Error
                    label: 'Keluar',
                  ),
                  const SizedBox(width: 12),
                  _buildLegendDot(
                    color: const Color(0xFF006329), // Tertiary Green
                    label: 'Masuk',
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 14),

          // 2. Area Grafik (Empty vs Populated dengan Animasi)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: (widget.isEmpty || (widget.dailyTrends != null && widget.dailyTrends!.isEmpty))
                ? _buildEmptyChartArea()
                : _buildPopulatedChartArea(),
          ),

          // 3. Garis Pemisah Tipis
          Container(
            width: double.infinity,
            height: 1,
            margin: const EdgeInsets.symmetric(vertical: 14),
            color: const Color(0xFFC3C6D7).withValues(alpha: 0.7),
          ),

          // 4. Dua Kolom Ringkasan Bawah (Pengeluaran & Pemasukan)
          Row(
            children: [
              Expanded(
                child: _buildSummaryBox(
                  amount: ReportDataStore.formatCurrency(widget.expenseTotal),
                  label: 'Pengeluaran',
                  isExpense: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryBox(
                  amount: ReportDataStore.formatCurrency(widget.incomeTotal),
                  label: 'Pemasukan',
                  isExpense: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF434655),
          ),
        ),
      ],
    );
  }

  /// Tampilan Grafik Kosong (Empty State)
  Widget _buildEmptyChartArea() {
    return SizedBox(
      key: const ValueKey('empty_chart'),
      height: 176,
      child: Stack(
        children: [
          // 4 Grid Putus-Putus Sumbu Y (75k, 50k, 25k, 0)
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _YAxisGridRow(label: '75k'),
              _YAxisGridRow(label: '50k'),
              _YAxisGridRow(label: '25k'),
              _YAxisGridRow(label: '0'),
            ],
          ),

          // Centered Placard Icon & Teks "Belum ada transaksi"
          Center(
            child: Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEAEDFF),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x1F0F172A),
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.show_chart_rounded,
                        size: 20,
                        color: Color(0xFF737686),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Belum ada transaksi',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF434655),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static double _calculateDynamicMaxScale(int highest) {
    if (highest <= 100000) return 120000.0;
    if (highest <= 500000) return 600000.0;
    if (highest <= 1000000) return 1200000.0;
    if (highest <= 3000000) return 3000000.0;
    if (highest <= 6000000) return 6000000.0;
    if (highest <= 12000000) return 12000000.0;
    return highest * 1.25;
  }

  static String _formatYTick(double val) {
    if (val >= 1000000) {
      final jt = val / 1000000;
      return jt % 1 == 0 ? '${jt.toInt()}jt' : '${jt.toStringAsFixed(1)}jt';
    }
    if (val >= 1000) {
      final k = val / 1000;
      return k % 1 == 0 ? '${k.toInt()}k' : '${k.toStringAsFixed(1)}k';
    }
    return val.toInt().toString();
  }

  void _handleTouch(double localX, double plotWidth, int count) {
    if (count == 0) return;
    final double clampedX = localX.clamp(0.0, plotWidth);
    final double fraction = count <= 1 ? 0.0 : clampedX / plotWidth;
    final int index = (fraction * (count - 1)).round().clamp(0, count - 1);
    if (_selectedBarIndex != index) {
      HapticFeedback.selectionClick();
      setState(() {
        _selectedBarIndex = index;
      });
    }
  }

  /// Tampilan Grafik Terisi (Populated State - Dual Line Chart Default)
  Widget _buildPopulatedChartArea() {
    final trends = widget.dailyTrends ?? ReportDataStore.oktoberDailyTrends;

    // Hitung nilai tertinggi dari gabungan pemasukan & pengeluaran tanpa filter
    int highest = 0;
    for (final t in trends) {
      if (t.expense > highest) highest = t.expense;
      if (t.income > highest) highest = t.income;
    }

    final double maxScale;
    final List<String> yLabels;

    final isDefaultOktober = widget.dailyTrends == null ||
        identical(widget.dailyTrends, ReportDataStore.oktoberDailyTrends);

    if (isDefaultOktober) {
      maxScale = 6000000.0;
      yLabels = ['6jt', '4jt', '2jt', '0'];
    } else if (highest <= 0) {
      maxScale = 120000.0;
      yLabels = ['120k', '80k', '40k', '0'];
    } else {
      maxScale = _calculateDynamicMaxScale(highest);
      yLabels = [
        _formatYTick(maxScale),
        _formatYTick(maxScale * 2 / 3),
        _formatYTick(maxScale / 3),
        '0',
      ];
    }

    return LayoutBuilder(
      key: const ValueKey('populated_line_chart'),
      builder: (context, constraints) {
        final double fullWidth = constraints.maxWidth;
        const double leftMargin = 36.0;
        const double rightMargin = 8.0;
        final double plotWidth = (fullWidth - leftMargin - rightMargin).clamp(10.0, fullWidth);
        const double plotHeight = 126.0;
        const double topMargin = 8.0;
        final int count = trends.length;

        return SizedBox(
          height: 196,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // 1. Grid Putus-putus Sumbu Y
              Positioned(
                left: 0,
                right: 0,
                top: topMargin,
                height: plotHeight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: yLabels.map((lbl) => _YAxisGridRow(label: lbl)).toList(),
                ),
              ),

              // 2. Dual Line Chart Interaktif (Canvas Hijau & Merah)
              Positioned(
                left: leftMargin,
                right: rightMargin,
                top: topMargin,
                height: plotHeight,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (details) {
                    _handleTouch(details.localPosition.dx, plotWidth, count);
                  },
                  onPanUpdate: (details) {
                    _handleTouch(details.localPosition.dx, plotWidth, count);
                  },
                  child: TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 650),
                    curve: Curves.easeOutCubic,
                    tween: Tween<double>(begin: 0.0, end: 1.0),
                    builder: (context, progress, child) {
                      return CustomPaint(
                        size: Size(plotWidth, plotHeight),
                        painter: _LineChartPainter(
                          trends: trends,
                          maxScale: maxScale,
                          selectedIndex: _selectedBarIndex,
                          progress: progress,
                        ),
                      );
                    },
                  ),
                ),
              ),

              // 3. Tooltip Melayang di Titik Terpilih
              if (_selectedBarIndex != null && _selectedBarIndex! < count) ...[
                Builder(
                  builder: (context) {
                    final selectedItem = trends[_selectedBarIndex!];
                    final double selX = count <= 1
                        ? plotWidth / 2
                        : (_selectedBarIndex! / (count - 1)) * plotWidth;
                    final double absX = leftMargin + selX;
                    const double tooltipWidth = 114.0;
                    final double tooltipLeft = (absX - tooltipWidth / 2)
                        .clamp(4.0, fullWidth - tooltipWidth - 4.0);

                    final String dateStr = selectedItem.fullDateStr;
                    final String? incomeStr = selectedItem.income > 0
                        ? ReportDataStore.formatCurrency(
                            selectedItem.income,
                            showSign: true,
                            isIncome: true,
                          )
                        : null;
                    final String? expenseStr = selectedItem.expense > 0
                        ? ReportDataStore.formatCurrency(
                            selectedItem.expense,
                            showSign: true,
                            isIncome: false,
                          )
                        : null;

                    return Positioned(
                      left: tooltipLeft,
                      top: 0,
                      width: tooltipWidth,
                      child: _buildFloatingTooltip(
                        dateStr: dateStr,
                        incomeStr: incomeStr,
                        expenseStr: expenseStr,
                      ),
                    );
                  },
                ),
              ],

              // 4. Label Tanggal Sumbu X
              Positioned(
                left: leftMargin,
                right: rightMargin,
                bottom: 2,
                height: 24,
                child: Stack(
                  children: List.generate(count, (idx) {
                    final item = trends[idx];
                    final bool isSelected = _selectedBarIndex == idx;
                    final bool showAll = count <= 10;
                    final int step = (count / 6).ceil().clamp(1, 10);
                    final bool shouldShow = showAll ||
                        (idx % step == 0) ||
                        (idx == count - 1) ||
                        isSelected;

                    if (!shouldShow) return const SizedBox.shrink();

                    final double x = count <= 1
                        ? plotWidth / 2
                        : (idx / (count - 1)) * plotWidth;

                    const double labelWidth = 32.0;
                    final double labelLeft = (x - labelWidth / 2)
                        .clamp(0.0, plotWidth - labelWidth);

                    return Positioned(
                      left: labelLeft,
                      width: labelWidth,
                      top: 4,
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() {
                            _selectedBarIndex = _selectedBarIndex == idx ? null : idx;
                          });
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Text(
                          item.dayStr,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10.5,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                            color: isSelected
                                ? const Color(0xFF0F172A)
                                : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Tooltip Tactile Melayang (e.g. 01 Okt +Rp 4.500.000)
  /// Tooltip Tactile Melayang (menampilkan pemasukan hijau & pengeluaran merah)
  Widget _buildFloatingTooltip({
    required String dateStr,
    String? incomeStr,
    String? expenseStr,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F0F172A),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
              BoxShadow(
                color: Color(0x0A0F172A),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                dateStr,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
              if (incomeStr != null) ...[
                const SizedBox(height: 1),
                Text(
                  incomeStr,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF16A34A),
                  ),
                ),
              ],
              if (expenseStr != null) ...[
                const SizedBox(height: 1),
                Text(
                  expenseStr,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFDC2626),
                  ),
                ),
              ],
              if (incomeStr == null && expenseStr == null) ...[
                const SizedBox(height: 1),
                Text(
                  'Rp 0',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ],
          ),
        ),
        // Segitiga Pointer
        CustomPaint(
          size: const Size(8, 4),
          painter: _TrianglePainter(),
        ),
      ],
    );
  }

  Widget _buildSummaryBox({
    required String amount,
    required String label,
    required bool isExpense,
  }) {
    final Color amountColor = widget.isEmpty
        ? const Color(0xFF737686)
        : (isExpense ? const Color(0xFFDC2626) : const Color(0xFF006329));

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F3FF).withValues(alpha: 0.70),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            amount,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: amountColor,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF434655),
            ),
          ),
        ],
      ),
    );
  }
}

class _YAxisGridRow extends StatelessWidget {
  final String label;

  const _YAxisGridRow({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 28,
          child: Text(
            label,
            textAlign: TextAlign.right,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 1,
            color: const Color(0xFFE2E8F0),
          ),
        ),
      ],
    );
  }
}

class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _LineChartPainter extends CustomPainter {
  final List<ReportDailyTrendItem> trends;
  final double maxScale;
  final int? selectedIndex;
  final double progress;

  _LineChartPainter({
    required this.trends,
    required this.maxScale,
    required this.selectedIndex,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (trends.isEmpty) return;

    final int count = trends.length;
    final double safeMaxScale = maxScale <= 0 ? 1.0 : maxScale;

    // Helper to calculate X and Y
    double getX(int index) {
      if (count <= 1) return size.width / 2;
      return (index / (count - 1)) * size.width;
    }

    double getY(int amount) {
      if (amount <= 0) return size.height;
      final double fraction = ((amount / safeMaxScale).clamp(0.0, 1.0)) * progress;
      final double rawY = (1.0 - fraction) * size.height;
      return rawY.clamp(4.0, size.height - 4.0);
    }

    // Build data points
    final List<Offset> expensePoints = [];
    final List<Offset> incomePoints = [];

    for (int i = 0; i < count; i++) {
      final x = getX(i);
      final item = trends[i];
      expensePoints.add(Offset(x, getY(item.expense)));
      incomePoints.add(Offset(x, getY(item.income)));
    }

    // 1. Draw Vertical Indicator Guideline at selectedIndex
    if (selectedIndex != null && selectedIndex! >= 0 && selectedIndex! < count) {
      final double selX = getX(selectedIndex!);
      final guidelinePaint = Paint()
        ..color = const Color(0xFF94A3B8).withValues(alpha: 0.6)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;

      // Dashed vertical line
      const double dashHeight = 4.0;
      const double dashSpace = 3.0;
      double startY = 0;
      while (startY < size.height) {
        canvas.drawLine(
          Offset(selX, startY),
          Offset(selX, (startY + dashHeight).clamp(0.0, size.height)),
          guidelinePaint,
        );
        startY += dashHeight + dashSpace;
      }
    }

    // 2. Draw Income Line & Gradient (Selalu Ditampilkan Secara Default)
    final incomePath = _createSmoothPath(incomePoints);

    // Area fill
    final incomeArea = _createAreaPath(incomePath, incomePoints, size.height);
    final incomeGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF16A34A).withValues(alpha: 0.22),
        const Color(0xFF16A34A).withValues(alpha: 0.0),
      ],
    );
    final incomeAreaPaint = Paint()
      ..shader = incomeGradient.createShader(Offset.zero & size)
      ..style = PaintingStyle.fill;
    canvas.drawPath(incomeArea, incomeAreaPaint);

    // Stroke
    final incomeStrokePaint = Paint()
      ..color = const Color(0xFF16A34A)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(incomePath, incomeStrokePaint);

    // 3. Draw Expense Line & Gradient (Selalu Ditampilkan Secara Default)
    final expensePath = _createSmoothPath(expensePoints);

    // Area fill
    final expenseArea = _createAreaPath(expensePath, expensePoints, size.height);
    final expenseGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFFDC2626).withValues(alpha: 0.20),
        const Color(0xFFDC2626).withValues(alpha: 0.0),
      ],
    );
    final expenseAreaPaint = Paint()
      ..shader = expenseGradient.createShader(Offset.zero & size)
      ..style = PaintingStyle.fill;
    canvas.drawPath(expenseArea, expenseAreaPaint);

    // Stroke
    final expenseStrokePaint = Paint()
      ..color = const Color(0xFFDC2626)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(expensePath, expenseStrokePaint);

    // 4. Draw Knots / Data points (Hijau & Merah)
    final bool showAllKnots = count <= 12;

    for (int i = 0; i < count; i++) {
      final bool isSelected = selectedIndex == i;
      if (!showAllKnots && !isSelected) continue;

      final bool hasIncome = trends[i].income > 0;
      final bool hasExpense = trends[i].expense > 0;

      // Income knot
      if (hasIncome || isSelected) {
        _drawKnot(
          canvas: canvas,
          center: incomePoints[i],
          color: const Color(0xFF16A34A),
          isSelected: isSelected && hasIncome,
        );
      }

      // Expense knot
      if (hasExpense || isSelected) {
        _drawKnot(
          canvas: canvas,
          center: expensePoints[i],
          color: const Color(0xFFDC2626),
          isSelected: isSelected && hasExpense,
        );
      }
    }
  }

  void _drawKnot({
    required Canvas canvas,
    required Offset center,
    required Color color,
    required bool isSelected,
  }) {
    if (isSelected) {
      // Outer glow / shadow
      final shadowPaint = Paint()
        ..color = color.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(center, 7, shadowPaint);

      // Outer ring
      final outerRingPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, 5.5, outerRingPaint);

      // Inner dot
      final innerDotPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, 3.5, innerDotPaint);
    } else {
      // Regular knot
      final dotPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawCircle(center, 3.0, dotPaint);

      final borderPaint = Paint()
        ..color = color
        ..strokeWidth = 1.8
        ..style = PaintingStyle.stroke;
      canvas.drawCircle(center, 3.0, borderPaint);
    }
  }

  Path _createSmoothPath(List<Offset> points) {
    final path = Path();
    if (points.isEmpty) return path;
    path.moveTo(points[0].dx, points[0].dy);
    if (points.length == 1) return path;
    if (points.length == 2) {
      path.lineTo(points[1].dx, points[1].dy);
      return path;
    }

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = i > 0 ? points[i - 1] : points[i];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i < points.length - 2 ? points[i + 2] : p2;

      final cp1x = p1.dx + (p2.dx - p0.dx) / 6;
      final cp1y = p1.dy + (p2.dy - p0.dy) / 6;
      final cp2x = p2.dx - (p3.dx - p1.dx) / 6;
      final cp2y = p2.dy - (p3.dy - p1.dy) / 6;

      path.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
    }

    return path;
  }

  Path _createAreaPath(Path linePath, List<Offset> points, double bottomY) {
    final areaPath = Path.from(linePath);
    if (points.isNotEmpty) {
      areaPath.lineTo(points.last.dx, bottomY);
      areaPath.lineTo(points.first.dx, bottomY);
      areaPath.close();
    }
    return areaPath;
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.progress != progress ||
        oldDelegate.maxScale != maxScale ||
        oldDelegate.trends != trends;
  }
}
