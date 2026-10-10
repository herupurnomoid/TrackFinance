import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/animations.dart';
import '../../data/dummy_dashboard_data.dart';

class CategoryDistributionCard extends StatefulWidget {
  final List<CategoryBreakdownItem> items;

  const CategoryDistributionCard({super.key, required this.items});

  @override
  State<CategoryDistributionCard> createState() =>
      _CategoryDistributionCardState();
}

class _CategoryDistributionCardState extends State<CategoryDistributionCard>
    with SingleTickerProviderStateMixin {
  bool _isExpenseSelected = true;
  late final AnimationController _sweepController;
  late final Animation<double> _sweep;

  @override
  void initState() {
    super.initState();
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    // First ~35% is a wait so the sweep starts after the card has slid in.
    _sweep = CurvedAnimation(
      parent: _sweepController,
      curve: const Interval(0.35, 1.0, curve: Curves.easeInOutCubic),
    );
    _sweepController.forward();
  }

  @override
  void dispose() {
    _sweepController.dispose();
    super.dispose();
  }

  void _select(bool expense) {
    if (expense == _isExpenseSelected) return;
    setState(() => _isExpenseSelected = expense);
    // Replay sweep without the initial wait.
    _sweepController.value = 0.35;
    _sweepController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x3865D0F4), // rgba(101,208,244,0.22)
            blurRadius: 24,
            spreadRadius: -6,
            offset: Offset(0, 12),
          ),
          BoxShadow(
            color: Color(0x0A0D2C3A),
            blurRadius: 10,
            spreadRadius: -2,
            offset: Offset(0, 4),
          ),
          BoxShadow(color: Colors.white, blurRadius: 6, offset: Offset(0, -3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Text(
            'Distribusi Kategori',
            style: AppTextStyles.headlineSm.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 16),

          // Clay Toggle Switch (Pengeluaran / Pemasukan)
          Container(
            width: double.infinity,
            height: 40,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(999),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x100D2C3A),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _select(true),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        color: _isExpenseSelected
                            ? AppColors.primaryContainer
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: _isExpenseSelected
                            ? const [
                                BoxShadow(
                                  color: Color(0x6665D0F4),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          'Pengeluaran',
                          style: AppTextStyles.labelMd.copyWith(
                            color: _isExpenseSelected
                                ? Colors.white
                                : AppColors.secondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _select(false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        color: !_isExpenseSelected
                            ? AppColors.primaryContainer
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: !_isExpenseSelected
                            ? const [
                                BoxShadow(
                                  color: Color(0x6665D0F4),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Center(
                        child: Text(
                          'Pemasukan',
                          style: AppTextStyles.labelMd.copyWith(
                            color: !_isExpenseSelected
                                ? Colors.white
                                : AppColors.secondary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Donut Chart with Center Content
          Center(
            child: SizedBox(
              width: 190,
              height: 190,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedBuilder(
                    animation: _sweep,
                    builder: (context, _) => CustomPaint(
                      size: const Size(190, 190),
                      painter: _DonutChartPainter(
                        items: widget.items,
                        progress: _sweep.value,
                      ),
                    ),
                  ),

                  // Donut Center Content Pill
                  Container(
                    width: 108,
                    height: 108,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x3365D0F4),
                          blurRadius: 16,
                          spreadRadius: -4,
                          offset: Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Colors.white,
                          blurRadius: 5,
                          offset: Offset(0, -3),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _isExpenseSelected
                                    ? 'Total Keluar'
                                    : 'Total Masuk',
                                style: AppTextStyles.labelSm.copyWith(
                                  color: AppColors.secondary,
                                  fontSize: 10,
                                ),
                              ),
                              const SizedBox(height: 2),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 350),
                                transitionBuilder: (child, anim) =>
                                    FadeTransition(
                                      opacity: anim,
                                      child: ScaleTransition(
                                        scale: Tween(begin: 0.8, end: 1.0)
                                            .animate(
                                              CurvedAnimation(
                                                parent: anim,
                                                curve: Curves.easeOutBack,
                                              ),
                                            ),
                                        child: child,
                                      ),
                                    ),
                                child: Text(
                                  _isExpenseSelected
                                      ? 'Rp 4,25 Jt'
                                      : 'Rp 9,80 Jt',
                                  key: ValueKey(_isExpenseSelected),
                                  style: AppTextStyles.headlineSm.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Bulan Ini',
                                style: AppTextStyles.labelSm.copyWith(
                                  color: AppColors.primary,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Categories Legend Breakdown List
          Column(
            children: widget.items.asMap().entries.map((entry) {
              final item = entry.value;
              return StaggeredEntrance(
                index: entry.key,
                stagger: const Duration(milliseconds: 90),
                duration: const Duration(milliseconds: 900),
                offsetY: 14,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    children: [
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: item.color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: item.color.withValues(alpha: 0.35),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          item.name,
                          style: AppTextStyles.labelMd.copyWith(
                            color: AppColors.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        item.amount,
                        style: AppTextStyles.bodySm.copyWith(
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${item.percentage}%',
                        style: AppTextStyles.labelMd.copyWith(
                          color: item.percentage >= 40
                              ? AppColors.primary
                              : AppColors.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<CategoryBreakdownItem> items;
  final double progress;

  _DonutChartPainter({required this.items, this.progress = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 14;

    // Background track ring
    final bgPaint = Paint()
      ..color = AppColors.surfaceContainerHighest.withValues(alpha: 0.40)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;

    canvas.drawCircle(center, radius, bgPaint);

    if (progress <= 0) return;

    // Total visible angle grows with progress; segments are revealed in order.
    final visibleEnd = -math.pi / 2 + 2 * math.pi * progress;
    double startAngle = -math.pi / 2;

    for (final item in items) {
      final sweepAngle = (item.percentage / 100.0) * 2 * math.pi;
      final segStart = startAngle + 0.04;
      final fullSweep = (sweepAngle - 0.08).clamp(0.01, 2 * math.pi);
      final visibleSweep = math.min(fullSweep, visibleEnd - segStart);

      if (visibleSweep > 0) {
        final segmentPaint = Paint()
          ..color = item.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 20
          ..strokeCap = StrokeCap.round;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius),
          segStart,
          visibleSweep,
          false,
          segmentPaint,
        );
      }

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutChartPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.items != items;
}
