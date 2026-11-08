import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/animations.dart';
import 'animated_amount_text.dart';
import 'header_time_theme.dart';
import 'header_time_background.dart';

/// Header Card Dashboard dengan Animasi Langit Waktu Dinamis (Pagi, Siang, Sore, Malam),
/// Tekstur Diagonal, Sapaan Animatif (Waving Hand Wave), Breathing Cashflow Arrows,
/// Animated Amount Counter, Glassmorphic Month Picker, dan Nav Arrows.
class DashboardTactileHeader extends StatefulWidget {
  final String userName;
  final String periodLabel;
  final int totalIncomeValue;
  final int totalExpenseValue;
  final bool isPrevDisabled;
  final bool isNextDisabled;
  final VoidCallback onOpenPicker;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback? onProfileTap;
  final VoidCallback? onLogout;
  final bool isFilterActive;
  final VoidCallback? onResetToToday;
  final double bottomExtension;
  final DashboardTimeOfDay? timeOfDay;

  const DashboardTactileHeader({
    super.key,
    required this.userName,
    required this.periodLabel,
    required this.totalIncomeValue,
    required this.totalExpenseValue,
    this.isPrevDisabled = false,
    this.isNextDisabled = false,
    required this.onOpenPicker,
    required this.onPrev,
    required this.onNext,
    this.onProfileTap,
    this.onLogout,
    this.isFilterActive = false,
    this.onResetToToday,
    this.bottomExtension = 0.0,
    this.timeOfDay,
  });

  @override
  State<DashboardTactileHeader> createState() => _DashboardTactileHeaderState();
}

class _DashboardTactileHeaderState extends State<DashboardTactileHeader>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _breatheController;

  DashboardTimeOfDay get _currentTimeOfDay =>
      widget.timeOfDay ?? DashboardTimeOfDay.fromDateTime();

  @override
  void initState() {
    super.initState();

    // 1. Animasi Lambaian Tangan Sapaan (2 siklus sambutan lalu settle ke 0% CPU saat idle)
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..forward();

    // 2. Animasi Denyut Panah Aliran Uang (aktif saat masuk & saat nominal berubah, 0% CPU saat idle)
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
  }

  @override
  void didUpdateWidget(covariant DashboardTactileHeader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.totalIncomeValue != widget.totalIncomeValue ||
        oldWidget.totalExpenseValue != widget.totalExpenseValue) {
      if (!MediaQuery.disableAnimationsOf(context)) {
        _breatheController.forward(from: 0.0);
      }
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    _breatheController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeTimeOfDay = _currentTimeOfDay;

    // Jika header dipanjangkan ke bawah untuk menutup celah di balik panel konten,
    // ratakan sudut bawah agar background menutup sempurna dari ujung ke ujung.
    final effectiveBorderRadius = widget.bottomExtension > 0
        ? BorderRadius.zero
        : const BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: effectiveBorderRadius,
        boxShadow: widget.bottomExtension > 0
            ? null
            : [
                BoxShadow(
                  color: activeTimeOfDay.skyGradientColors.first
                      .withValues(alpha: 0.25),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: effectiveBorderRadius,
        child: Stack(
          children: [
            // 1. Background Animasi Waktu Dinamis (Pagi, Siang, Sore, Malam)
            Positioned.fill(
              child: HeaderTimeBackground(
                timeOfDay: activeTimeOfDay,
              ),
            ),

            // 2. Konten Utama Header
            SafeArea(
              bottom: false,
              child: Padding(
                // Tambahkan tinggi dari dalam header: konten turun, sementara
                // latar langit tetap menutup area atas dan bawah tanpa celah samping.
                padding: EdgeInsets.fromLTRB(
                  20,
                  34,
                  20,
                  44 + widget.bottomExtension,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Baris 1: Sapaan Animatif & Badge Pemilih Waktu
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                widget.onProfileTap?.call();
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 2,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      activeTimeOfDay.greeting,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white
                                            .withValues(alpha: 0.85),
                                        height: 1.3,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            widget.userName.isNotEmpty
                                                ? widget.userName
                                                : 'Pengguna',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                              letterSpacing: -0.4,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),

                                        // Tangan Melambai Beranimasi 👋 (settle mulus ke 0 rad setelah sambutan)
                                        RepaintBoundary(
                                          child: AnimatedBuilder(
                                            animation: _waveController,
                                            child: const Text(
                                              '👋',
                                              style: TextStyle(fontSize: 20),
                                            ),
                                            builder: (context, child) {
                                              if (_waveController.isCompleted) {
                                                return child!;
                                              }
                                              final t = _waveController.value;
                                              final angle = math.sin(t * 4 * math.pi) *
                                                  0.20 *
                                                  (1.0 - t);
                                              return Transform.rotate(
                                                angle: angle,
                                                alignment: Alignment.bottomRight,
                                                child: child,
                                              );
                                            },
                                          ),
                                        ),

                                        const SizedBox(width: 6),
                                        Icon(
                                          Icons.chevron_right_rounded,
                                          size: 20,
                                          color: Colors.white
                                              .withValues(alpha: 0.70),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    // Baris 2: Month Picker Glass Pill & Nav Arrow Group
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Month / Period Glass Pill
                      Expanded(
                        child: PressableScale(
                          onTap: widget.onOpenPicker,
                          scaleFactor: 0.96,
                          translateY: 2.0,
                          child: Container(
                            height: 44,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.35),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.12),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.calendar_today_rounded,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      widget.periodLabel,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    size: 18,
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                      const SizedBox(width: 10),

                      // Nav Arrow Group (Prev, Next, and Today if active)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.isFilterActive) ...[
                            _buildHeaderGlassButton(
                              icon: Icons.today_rounded,
                              tooltip: 'Kembali ke Hari Ini',
                              onTap: () {
                                HapticFeedback.mediumImpact();
                                widget.onResetToToday?.call();
                              },
                            ),
                            const SizedBox(width: 8),
                          ],
                          _buildHeaderGlassButton(
                            icon: Icons.chevron_left_rounded,
                            tooltip: 'Sebelumnya',
                            isDisabled: widget.isPrevDisabled,
                            onTap: widget.onPrev,
                          ),
                          const SizedBox(width: 8),
                          _buildHeaderGlassButton(
                            icon: Icons.chevron_right_rounded,
                            tooltip: 'Berikutnya',
                            isDisabled: widget.isNextDisabled,
                            onTap: widget.onNext,
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Baris 3: Ikon 3D & Nominal Pemasukan / Pengeluaran Berdampingan
                  // Tanpa teks label, tanpa kontainer, tanpa background color, dengan
                  // warna & bayangan yang diadaptasi terhadap kondisi tema waktu aktif.
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isCompact = constraints.maxWidth < 290;
                      final iconSize = isCompact ? 36.0 : 42.0;
                      final itemGap = isCompact ? 6.0 : 8.0;

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Pemasukan: Ikon 3D Panah Naik + Nominal
                          Expanded(
                            child: _buildCashflowMetric(
                              amountValue: widget.totalIncomeValue,
                              isIncome: true,
                              timeOfDay: activeTimeOfDay,
                              iconSize: iconSize,
                              itemGap: itemGap,
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Pengeluaran: Ikon 3D Panah Turun + Nominal
                          Expanded(
                            child: _buildCashflowMetric(
                              amountValue: widget.totalExpenseValue,
                              isIncome: false,
                              timeOfDay: activeTimeOfDay,
                              iconSize: iconSize,
                              itemGap: itemGap,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
  }

  Widget _buildHeaderGlassButton({
    required IconData icon,
    required String tooltip,
    bool isDisabled = false,
    required VoidCallback onTap,
  }) {
    return PressableScale(
      onTap: isDisabled ? null : onTap,
      scaleFactor: 0.92,
      translateY: 2.0,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: isDisabled ? 0.35 : 1.0,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withValues(alpha: 0.18),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.40),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Icon(
              icon,
              size: 20,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCashflowMetric({
    required int amountValue,
    required bool isIncome,
    required DashboardTimeOfDay timeOfDay,
    required double iconSize,
    required double itemGap,
  }) {
    final textColor = isIncome
        ? timeOfDay.incomeAmountColor
        : timeOfDay.expenseAmountColor;
    final textShadows = isIncome
        ? timeOfDay.incomeAmountShadows
        : timeOfDay.expenseAmountShadows;
    final cachePixelSize = (iconSize * 3).round();

    return Semantics(
      label: isIncome ? 'Nominal pemasukan' : 'Nominal pengeluaran',
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Ikon 3D Panah Melayang Tanpa Kontainer & Tanpa Background Color
            RepaintBoundary(
              child: AnimatedBuilder(
                animation: _breatheController,
                builder: (context, child) {
                  if (_breatheController.isCompleted) {
                    return child!;
                  }
                  final t = _breatheController.value;
                  final pulse = math.sin(t * 2 * math.pi) * 2.2 * (1.0 - t);
                  final dy = isIncome ? -pulse : pulse;
                  return Transform.translate(
                    offset: Offset(0, dy),
                    child: child,
                  );
                },
                child: Image.asset(
                  isIncome
                      ? 'assets/icons/3d/income_arrow.webp'
                      : 'assets/icons/3d/expense_arrow.webp',
                  width: iconSize,
                  height: iconSize,
                  fit: BoxFit.contain,
                  cacheWidth: cachePixelSize,
                  cacheHeight: cachePixelSize,
                  filterQuality: FilterQuality.low,
                ),
              ),
            ),
            SizedBox(width: itemGap),

            // Angka Nominal Tanpa Kontainer & Tanpa Background Color,
            // Warna & Bayangan Disesuaikan dengan Tema Waktu Aktif
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: AnimatedAmountText(
                  targetAmount: amountValue,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: textColor,
                    letterSpacing: -0.3,
                    height: 1.2,
                    fontFeatures: const [FontFeature.tabularFigures()],
                    shadows: textShadows,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
