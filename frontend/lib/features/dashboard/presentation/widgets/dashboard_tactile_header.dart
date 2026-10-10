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
  });

  @override
  State<DashboardTactileHeader> createState() => _DashboardTactileHeaderState();
}

class _DashboardTactileHeaderState extends State<DashboardTactileHeader>
    with TickerProviderStateMixin {
  late AnimationController _waveController;
  late Animation<double> _waveAnimation;

  late AnimationController _breatheController;
  late Animation<double> _breatheAnimation;

  DashboardTimeOfDay get _currentTimeOfDay =>
      DashboardTimeOfDay.fromDateTime();

  @override
  void initState() {
    super.initState();

    // 1. Animasi Lambaian Tangan Sapaan (Waving Hand 👋)
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _waveAnimation = Tween<double>(begin: -0.15, end: 0.20).animate(
      CurvedAnimation(
        parent: _waveController,
        curve: Curves.easeInOutSine,
      ),
    );

    // 2. Animasi Denyut / Melayang Panah Aliran Uang (Breathing Cashflow)
    _breatheController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _breatheAnimation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _breatheController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _waveController.dispose();
    _breatheController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    return _currentTimeOfDay.greeting;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: _currentTimeOfDay.skyGradientColors.first
                .withValues(alpha: 0.25),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        child: Stack(
          children: [
            // 1. Background Animasi Waktu Dinamis (Pagi, Siang, Sore, Malam)
            Positioned.fill(
              child: HeaderTimeBackground(
                timeOfDay: _currentTimeOfDay,
              ),
            ),

            // 2. Tekstur Garis Diagonal Halus
            Positioned.fill(
              child: const CustomPaint(
                painter: _HeaderHatchPainter(),
              ),
            ),

            // 3. Konten Utama Header
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 38),
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
                                      _getGreeting(),
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

                                        // Tangan Melambai Beranimasi 👋
                                        AnimatedBuilder(
                                          animation: _waveAnimation,
                                          builder: (context, child) {
                                            return Transform.rotate(
                                              angle: _waveAnimation.value,
                                              alignment: Alignment.bottomRight,
                                              child: const Text(
                                                '👋',
                                                style: TextStyle(fontSize: 20),
                                              ),
                                            );
                                          },
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

                  const SizedBox(height: 14),

                  // Baris 3: Rekapitulasi Pemasukan & Pengeluaran dengan Animated Rolling Counter
                  Column(
                    children: [
                      // Kartu Pemasukan
                      _buildSummaryCard(
                        title: 'Pemasukan',
                        amountValue: widget.totalIncomeValue,
                        isIncome: true,
                      ),
                      const SizedBox(height: 8),
                      // Kartu Pengeluaran
                      _buildSummaryCard(
                        title: 'Pengeluaran',
                        amountValue: widget.totalExpenseValue,
                        isIncome: false,
                      ),
                    ],
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

  Widget _buildSummaryCard({
    required String title,
    required int amountValue,
    required bool isIncome,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.36),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.24),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.20),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                // Icon Badge Lingkaran dengan Animasi Breathing Melayang
                AnimatedBuilder(
                  animation: _breatheAnimation,
                  builder: (context, child) {
                    final dy = isIncome
                        ? _breatheAnimation.value
                        : -_breatheAnimation.value;
                    return Transform.translate(
                      offset: Offset(0, dy),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: isIncome
                                ? const [Color(0xFF22C55E), Color(0xFF16A34A)]
                                : const [Color(0xFFEF4444), Color(0xFFDC2626)],
                          ),
                          border: Border.all(
                            color: isIncome
                                ? const Color(0xFF4ADE80)
                                : const Color(0xFFF87171),
                            width: 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: (isIncome
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFFDC2626))
                                  .withValues(alpha: 0.35),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            isIncome
                                ? Icons.arrow_downward_rounded
                                : Icons.arrow_upward_rounded,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      shadows: const [
                        Shadow(
                          color: Color(0x99000000),
                          blurRadius: 3,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Nilai Angka Beranimasi dengan Kapsul Kontras Tinggi (High Contrast Amount Capsule)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.20),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: AnimatedAmountText(
              targetAmount: amountValue,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 15.5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.2,
                shadows: const [
                  Shadow(
                    color: Color(0xCC000000),
                    blurRadius: 4,
                    offset: Offset(0, 1.5),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderHatchPainter extends CustomPainter {
  const _HeaderHatchPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.035)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    const spacing = 12.0;
    final total = size.width + size.height;

    for (double i = -size.height; i < total; i += spacing) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i + size.height, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
