import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/report_data_model.dart';

/// Kartu Tren Keuangan Modern Tactile
/// Mendukung 3 Kondisi:
/// 1. Kondisi Kosong (Empty State): Placard 'Belum ada transaksi' & sumbu Y 75k..0
/// 2. Kondisi Pengeluaran (Keluar): Bar chart merah tunggal (skala 120k)
/// 3. Kondisi Pemasukan (Masuk): Bar chart ganda merah & hijau (skala 6jt) dengan tooltip aktif
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
            child: widget.isEmpty
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
                        Icons.bar_chart_rounded,
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

  /// Tampilan Grafik Terisi (Populated State)
  Widget _buildPopulatedChartArea() {
    final trends = widget.dailyTrends ?? ReportDataStore.oktoberDailyTrends;
    final isIncome = !widget.isExpenseMode;

    // Sumbu Y labels
    final List<String> yLabels = isIncome
        ? ['6jt', '4jt', '2jt', '0']
        : ['120k', '80k', '40k', '0'];

    // Skala maksimum untuk normalisasi bar height (100% tinggi bar ~ 116px)
    final double maxScale = isIncome ? 6000000.0 : 120000.0;
    const double maxBarHeight = 116.0;

    return SizedBox(
      key: ValueKey('populated_chart_${widget.isExpenseMode}'),
      height: 196,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Grid Putus-putus Sumbu Y
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: yLabels.map((lbl) => _YAxisGridRow(label: lbl)).toList(),
          ),

          // Container Bar Chart Interaktif
          Positioned(
            left: 36,
            right: 8,
            top: 10,
            bottom: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(trends.length, (idx) {
                final item = trends[idx];
                final isSelected = _selectedBarIndex == idx;

                // Perhitungan tinggi bar dengan clamping
                final double expHeight = ((item.expense / maxScale) * maxBarHeight)
                    .clamp(isIncome ? 2.0 : 6.0, maxBarHeight);
                final double incHeight = ((item.income / maxScale) * maxBarHeight)
                    .clamp(0.0, maxBarHeight);

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() {
                      _selectedBarIndex = _selectedBarIndex == idx ? null : idx;
                    });
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Tooltip melayang jika dipilih
                      if (isSelected && isIncome && item.income > 0)
                        _buildFloatingTooltip(
                          dateStr: item.fullDateStr,
                          amountStr: ReportDataStore.formatCurrency(
                            item.income,
                            showSign: true,
                            isIncome: true,
                          ),
                        )
                      else if (isSelected && !isIncome)
                        _buildFloatingTooltip(
                          dateStr: item.fullDateStr,
                          amountStr: ReportDataStore.formatCurrency(
                            item.expense,
                            showSign: true,
                            isIncome: false,
                          ),
                        )
                      else
                        const SizedBox(height: 38), // placeholder penyeimbang spasi

                      // Batang Grafik
                      SizedBox(
                        height: maxBarHeight,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // Batang Pengeluaran (Merah)
                            TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeOutCubic,
                              tween: Tween<double>(begin: 0, end: expHeight),
                              builder: (context, val, child) {
                                return Container(
                                  width: isIncome ? 10 : 14,
                                  height: val,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Color(0xFFEF4444),
                                        Color(0xFFDC2626),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x33DC2626),
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),

                            // Batang Pemasukan (Hijau) hanya muncul pada mode Masuk
                            if (isIncome && item.income > 0) ...[
                              const SizedBox(width: 4),
                              TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 700),
                                curve: Curves.easeOutCubic,
                                tween: Tween<double>(begin: 0, end: incHeight),
                                builder: (context, val, child) {
                                  return Container(
                                    width: 10,
                                    height: val,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Color(0xFF16A34A),
                                          Color(0xFF006329),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(6),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Color(0x3316A34A),
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Label Tanggal (X-Axis)
                      Text(
                        item.dayStr,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                          color: isSelected
                              ? const Color(0xFF0F172A)
                              : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  /// Tooltip Tactile Melayang (e.g. 01 Okt +Rp 4.500.000)
  Widget _buildFloatingTooltip({
    required String dateStr,
    required String amountStr,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
              Text(
                amountStr,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: widget.isExpenseMode
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF006329),
                ),
              ),
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
