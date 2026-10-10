import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/widgets/animations.dart';
import '../widgets/report_health_card.dart';
import '../widgets/report_month_picker_modal.dart';
import '../widgets/report_skeleton.dart';
import '../widgets/report_structure_card.dart';
import '../widgets/report_trend_card.dart';
import '../../../dashboard/presentation/widgets/tactile_time_header_wrapper.dart';

/// Halaman Laporan Keuangan Modern Tactile Finance
/// Mendukung:
/// - Mode Kosong (Empty State, e.g. Sep 2026)
/// - Mode Pengeluaran / Keluar (Oktober 2026 dengan bar merah, donut merah, 4 kategori, minus kritis)
/// - Mode Pemasukan / Masuk (Oktober 2026 dengan bar ganda, donut hijau, 3 kategori, sehat 95%)
/// - Transisi halus, animasi interaktif bar tooltip & donut, serta skeleton loading.
class ReportScreen extends StatefulWidget {
  final UserProfile? user;
  final int initialYear;
  final int initialMonthIndex; // 0-based: 8 = September, 9 = Oktober
  final bool initialIsExpenseTab;
  final bool initialIsLoading;

  const ReportScreen({
    super.key,
    this.user,
    this.initialYear = 2026,
    this.initialMonthIndex = 9, // Default Oktober 2026 dengan data
    this.initialIsExpenseTab = true, // Default Keluar
    this.initialIsLoading = false,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen>
    with SingleTickerProviderStateMixin {
  late bool _isLoading;
  late int _currentYear;
  late int _currentMonthIndex;
  late bool _isExpenseMode;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  static const List<String> _monthsShort = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  @override
  void initState() {
    super.initState();
    _isLoading = widget.initialIsLoading;
    _currentYear = widget.initialYear;
    _currentMonthIndex = widget.initialMonthIndex;
    _isExpenseMode = widget.initialIsExpenseTab;

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeOutCubic,
      ),
    );

    _fadeController.forward();
  }

  @override
  void didUpdateWidget(covariant ReportScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIsLoading != oldWidget.initialIsLoading) {
      setState(() {
        _isLoading = widget.initialIsLoading;
      });
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  /// Menentukan apakah bulan yang dipilih memiliki data atau kosong
  /// (Bulan Oktober 2026 memiliki data lengkap sesuai referensi, bulan lain kosong)
  bool get _isMonthEmpty {
    return !(_currentYear == 2026 && _currentMonthIndex == 9);
  }

  int get _currentExpenseTotal {
    if (_isMonthEmpty) return 0;
    return 248466;
  }

  int get _currentIncomeTotal {
    if (_isMonthEmpty) return 0;
    // Jika di mode Keluar, tampilan pemasukan di summary bisa 0 sesuai HTML 1,
    // di mode Masuk bernilai Rp 5.000.000 sesuai HTML 2
    return _isExpenseMode ? 0 : 5000000;
  }

  int get _structureTotalAmount {
    if (_isMonthEmpty) return 0;
    return _isExpenseMode ? 248466 : 5000000;
  }

  Future<void> _handleRefresh() async {
    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 650));
    if (mounted) {
      setState(() => _isLoading = false);
      _fadeController.forward(from: 0.0);
    }
  }

  void _openMonthPickerModal() {
    HapticFeedback.lightImpact();
    ReportMonthPickerModal.show(
      context,
      initialYear: _currentYear,
      initialMonthIndex: _currentMonthIndex,
      onApply: (year, monthIndex) {
        setState(() {
          _currentYear = year;
          _currentMonthIndex = monthIndex;
        });
        _fadeController.forward(from: 0.0);
      },
    );
  }

  void _handleTabChanged(bool isExpense) {
    if (_isExpenseMode == isExpense) return;
    HapticFeedback.lightImpact();
    setState(() {
      _isExpenseMode = isExpense;
    });
    _fadeController.forward(from: 0.0);
  }

  @override
  Widget build(BuildContext context) {
    final String currentMonthLabel =
        '${_monthsShort[_currentMonthIndex]} $_currentYear';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Color(0xFFF1F5F9),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        body: Column(
          children: [
            // 1. Header Waktu Dinamis Tactile Skeuomorphic (Fixed Top Header)
            _buildHeader(context),

            // 2. Raised Content Panel (Menimpa Header sebesar 20px seperti Halaman Tambah Transaksi & Kategori)
            Expanded(
              child: Container(
                transform: Matrix4.translationValues(0.0, -20.0, 0.0),
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9), // Slate 100 Canvas
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    topRight: Radius.circular(28),
                  ),
                  child: RefreshIndicator(
                    onRefresh: _handleRefresh,
                    color: const Color(0xFF2563EB),
                    backgroundColor: Colors.white,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: EdgeInsets.fromLTRB(
                        16,
                        20,
                        16,
                        MediaQuery.of(context).padding.bottom + 28,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _isLoading
                            ? const ReportSkeleton(key: ValueKey('skeleton'))
                            : FadeTransition(
                                key: const ValueKey('content'),
                                opacity: _fadeAnimation,
                                child: SlideTransition(
                                  position: _slideAnimation,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Baris Filter Bulan/Tahun & Status Arsip
                                      _buildFilterRow(currentMonthLabel),

                                      const SizedBox(height: 16),

                                      // Kartu 1: Tren Keuangan (Empty / Populated Keluar / Populated Masuk)
                                      ReportTrendCard(
                                        isEmpty: _isMonthEmpty,
                                        isExpenseMode: _isExpenseMode,
                                        expenseTotal: _currentExpenseTotal,
                                        incomeTotal: _currentIncomeTotal,
                                      ),

                                      const SizedBox(height: 16),

                                      // Kartu 2: Struktur Transaksi (Donut Chart & List Kategori)
                                      ReportStructureCard(
                                        isEmpty: _isMonthEmpty,
                                        totalAmount: _structureTotalAmount,
                                        isExpenseTab: _isExpenseMode,
                                        onTabChanged: _handleTabChanged,
                                      ),

                                      const SizedBox(height: 16),

                                      // Kartu 3: Indikator Kesehatan (Gauge Track & Skor)
                                      ReportHealthCard(
                                        isEmpty: _isMonthEmpty,
                                        isExpenseMode: _isExpenseMode,
                                        healthScore: _isMonthEmpty
                                            ? null
                                            : (_isExpenseMode ? -100.0 : 95.0),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Header Gradient Waktu Dinamis dengan Tombol Back Glassmorphic
  Widget _buildHeader(BuildContext context) {
    return TactileTimeHeaderWrapper(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 36),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Tombol Back Frosted Glass 44x44
              PressableScale(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).maybePop();
                },
                scaleFactor: 0.92,
                translateY: 2.0,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.20),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.35),
                      width: 1.0,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1F0F172A),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.chevron_left_rounded,
                      size: 24,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Judul Tengah "Laporan"
              Text(
                'Laporan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),

              // Penyeimbang agar judul tetap tepat di tengah
              const SizedBox(width: 44, height: 44),
            ],
          ),
        ),
      ),
    );
  }

  /// Baris Tombol Pill Filter Bulan & Status Arsip
  Widget _buildFilterRow(String currentMonthLabel) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 1. Pill Filter Bulan (e.g. Okt 2026 / Sep 2026)
        PressableScale(
          onTap: _openMonthPickerModal,
          scaleFactor: 0.95,
          translateY: 2.0,
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white,
                    Color(0xFFF8FAFC),
                  ],
                ),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: const Color(0xFFE2E8F0),
                  width: 1.0,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x142563EB),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                  BoxShadow(
                    color: Color(0x0D0F172A),
                    blurRadius: 3,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    currentMonthLabel,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF131B2E),
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.calendar_month_rounded,
                    size: 18,
                    color: Color(0xFF2563EB),
                  ),
                ],
              ),
            ),
          ),

        // 2. Chip Status (Arsip Non-Aktif saat kosong, atau Status Aktif)
        if (_isMonthEmpty)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F3FF),
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF737686),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Arsip Non-Aktif',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF434655),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
