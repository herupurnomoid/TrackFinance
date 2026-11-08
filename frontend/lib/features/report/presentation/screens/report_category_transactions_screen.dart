import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/services/auth_service_provider.dart';
import '../../../../core/widgets/animations.dart';
import '../../../category/presentation/widgets/category_3d_icon.dart';
import '../../../dashboard/data/dashboard_transaction_model.dart';
import '../../../dashboard/presentation/widgets/tactile_time_header_wrapper.dart';
import '../../../transaction/data/transaction_action_result.dart';
import '../../../transaction/data/transaction_model.dart';
import '../../../transaction/data/transaction_repository.dart';
import '../../../transaction/presentation/screens/add_transaction_screen.dart';
import '../../data/report_data_model.dart';

/// Halaman Rincian Kategori Transaksi Laporan (ReportCategoryTransactionsScreen)
/// Menampilkan ringkasan kategori (Hero Card dengan Ikon 3D), alokasi persentase,
/// total nominal, serta riwayat daftar transaksi terkait untuk periode bulan terpilih.
class ReportCategoryTransactionsScreen extends StatefulWidget {
  final ReportCategoryItem categoryItem;
  final int year;
  final int monthIndex; // 0-based: 0 = Januari, 9 = Oktober
  final bool isExpense;
  final UserProfile? user;
  final TransactionRepository? repository;
  final List<DashboardTransaction>? initialTransactions;

  const ReportCategoryTransactionsScreen({
    super.key,
    required this.categoryItem,
    required this.year,
    required this.monthIndex,
    required this.isExpense,
    this.user,
    this.repository,
    this.initialTransactions,
  });

  @override
  State<ReportCategoryTransactionsScreen> createState() =>
      _ReportCategoryTransactionsScreenState();
}

class _ReportCategoryTransactionsScreenState
    extends State<ReportCategoryTransactionsScreen> {
  late TransactionRepository _repository;
  StreamSubscription<List<TransactionModel>>? _txSubscription;
  List<DashboardTransaction> _transactions = [];
  bool _isLoading = true;

  UserProfile? get _effectiveUser =>
      widget.user ?? AuthServiceProvider.instance.currentUser;

  String? get _uid => _effectiveUser?.uid;

  String get _monthKey =>
      '${widget.year}-${(widget.monthIndex + 1).toString().padLeft(2, '0')}';

  String get _periodLabel {
    final monthName = (widget.monthIndex >= 0 &&
            widget.monthIndex < DashboardDataStore.monthsName.length)
        ? DashboardDataStore.monthsName[widget.monthIndex]
        : '';
    return '$monthName ${widget.year}';
  }

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? TransactionRepository.instance;

    if (widget.initialTransactions != null) {
      _transactions = List.from(widget.initialTransactions!);
      _isLoading = false;
    } else {
      _initTransactions();
    }
  }

  @override
  void dispose() {
    _txSubscription?.cancel();
    super.dispose();
  }

  void _initTransactions() {
    final uid = _uid;
    if (uid != null && uid.isNotEmpty) {
      _txSubscription?.cancel();
      _txSubscription = _repository
          .watchTransactionsByMonth(uid, _monthKey)
          .listen(
        (list) {
          if (!mounted) return;
          final filtered = _filterTransactions(
            list.map((m) => m.toDashboardTransaction()).toList(),
          );

          setState(() {
            _transactions = filtered;
            _isLoading = false;
          });
        },
        onError: (e) {
          debugPrint('[ReportCategoryTransactions] stream error: $e');
          if (mounted) {
            _loadFallbackTransactions();
          }
        },
      );
    } else {
      _loadFallbackTransactions();
    }
  }

  void _loadFallbackTransactions() {
    final allFallback = DashboardDataStore.initialTransactions;
    final filtered = _filterTransactions(allFallback);

    if (filtered.isEmpty && widget.categoryItem.amount > 0) {
      // Jika demo/fallback tidak memiliki transaksi yang cocok persis namanya,
      // buatkan 1-2 item transaksi representatif agar tampilan tetap kaya dan konsisten.
      final day = 7;
      final monthName = (widget.monthIndex >= 0 &&
              widget.monthIndex < DashboardDataStore.monthsName.length)
          ? DashboardDataStore.monthsName[widget.monthIndex]
          : 'Oktober';
      final dateStr = '$day $monthName ${widget.year}';
      final dateKey =
          '${widget.year}-${(widget.monthIndex + 1).toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

      filtered.add(
        DashboardTransaction(
          id: 'demo-${widget.categoryItem.id ?? widget.categoryItem.name}',
          dateStr: dateStr,
          dateKey: dateKey,
          year: widget.year,
          month: widget.monthIndex,
          day: day,
          category: widget.categoryItem.name,
          meta: '14.00 · Transaksi ${widget.categoryItem.name}',
          amount: widget.isExpense
              ? -widget.categoryItem.amount
              : widget.categoryItem.amount,
          type: widget.isExpense
              ? TransactionType.expense
              : TransactionType.income,
          icon: widget.categoryItem.icon,
        ),
      );
    }

    setState(() {
      _transactions = filtered;
      _isLoading = false;
    });
  }

  List<DashboardTransaction> _filterTransactions(
      List<DashboardTransaction> source) {
    final catId = widget.categoryItem.id?.toLowerCase().trim() ?? '';
    final catName = widget.categoryItem.name.toLowerCase().trim();

    return source.where((tx) {
      // Filter tipe (income / expense)
      final typeMatches = tx.isIncome == !widget.isExpense;
      if (!typeMatches) return false;

      // Filter periode bulan dan tahun
      final dateMatches =
          tx.year == widget.year && tx.month == widget.monthIndex;
      if (!dateMatches) return false;

      // Filter kesesuaian kategori
      final txCat = tx.category.toLowerCase().trim();
      final idMatches = catId.isNotEmpty &&
          (tx.id.toLowerCase().contains(catId) || txCat.contains(catId));
      final nameMatches = txCat == catName ||
          txCat.contains(catName) ||
          catName.contains(txCat);

      return idMatches || nameMatches;
    }).toList();
  }

  Future<void> _handleRefresh() async {
    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300));
    _initTransactions();
  }

  Future<void> _openEditTransaction(DashboardTransaction tx) async {
    final result = await Navigator.of(context).push<dynamic>(
      PageRouteBuilder(
        opaque: true,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (context, animation, secondaryAnimation) =>
            AddTransactionScreen(
          user: _effectiveUser,
          transaction: tx,
        ),
      ),
    );

    if (!mounted || result == null) return;

    if (result is TransactionActionResult) {
      if (result.isDeleted) {
        setState(() {
          _transactions.removeWhere((t) => t.id == tx.id);
        });
      } else if (result.updatedTransaction != null) {
        final updated = result.updatedTransaction!;
        setState(() {
          final idx = _transactions.indexWhere((t) => t.id == updated.id);
          if (idx != -1) {
            _transactions[idx] = updated;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFFF1F5F9),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        body: Column(
          children: [
            // 1. Header Tactile Biru Konsisten
            _buildHeader(context),

            // 2. Konten Canvas dengan Pull-to-Refresh
            Expanded(
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                color: const Color(0xFF2563EB),
                backgroundColor: Colors.white,
                child: SizedBox.expand(
                  child: SingleChildScrollView(
                    clipBehavior: Clip.none,
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: EdgeInsets.fromLTRB(
                      16,
                      20,
                      16,
                      MediaQuery.of(context).padding.bottom + 40,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // A. Hero Category Summary Card
                        RepaintBoundary(
                          child: _buildHeroCategoryCard(),
                        ),

                        const SizedBox(height: 20),

                        // B. Section Title & List Transaksi
                        _buildTransactionSectionHeader(),

                        const SizedBox(height: 12),

                        // C. Grouped Transactions atau Empty State
                        _isLoading
                            ? _buildLoadingSkeleton()
                            : (_transactions.isEmpty
                                ? _buildEmptyState()
                                : _buildGroupedTransactionsList()),
                      ],
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

  /// 1. Header Tactile Bergradasi Biru dengan Glassmorphic Back Button
  Widget _buildHeader(BuildContext context) {
    return TactileTimeHeaderWrapper(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Glassmorphic Back Button (44x44)
              PressableScale(
                onTap: () => Navigator.of(context).maybePop(),
                scaleFactor: 0.92,
                translateY: 2.0,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.20),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.30),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color:
                            const Color(0xFF0F172A).withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_back_rounded,
                      size: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Title & Subtitle Periode di Tengah
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.categoryItem.name,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _periodLabel,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),

              // Spacer agar judul tetap presisi di tengah seimbang dengan tombol back (44x44)
              const SizedBox(width: 44, height: 44),
            ],
          ),
        ),
      ),
    );
  }

  /// A. Hero Category Summary Card
  Widget _buildHeroCategoryCard() {
    final cat = widget.categoryItem;
    final isExp = widget.isExpense;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
            color: Color(0x0A2563EB),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Color(0x060F172A),
            blurRadius: 4,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Baris Atas: Ikon 3D Kategori + Nama & Pill Kategori
          Row(
            children: [
              // Ikon 3D Kategori Taktil Bebas Tanpa Container / Background
              Category3DIcon(
                id: cat.id,
                name: cat.name,
                icon: cat.icon,
                isExpense: isExp,
                size: 52,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cat.name,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // Pill Jenis Transaksi
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: isExp
                                ? const Color(0xFFFFECEB)
                                : const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            isExp ? 'Pengeluaran' : 'Pemasukan',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isExp
                                  ? const Color(0xFFDC2626)
                                  : const Color(0xFF16A34A),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Pill Persentase Struktur
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: cat.containerColor,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${cat.percentage.toStringAsFixed(1)}% porsi',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: cat.badgeTextColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          const Divider(color: Color(0xFFF1F5F9), height: 1, thickness: 1),
          const SizedBox(height: 16),

          // Baris Bawah: Total Nominal & Jumlah Transaksi
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Kolom Nominal
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isExp ? 'Total Pengeluaran' : 'Total Pemasukan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    ReportDataStore.formatCurrency(cat.amount),
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: isExp
                          ? const Color(0xFFDC2626)
                          : const Color(0xFF16A34A),
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),

              // Info Counter Catatan
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_transactions.length} Transaksi',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF334155),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// B. Section Header untuk Daftar Transaksi
  Widget _buildTransactionSectionHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Daftar Transaksi',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.2,
            ),
          ),
          Text(
            'Klik untuk rincian / edit',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  /// C. Grouped Transactions List
  Widget _buildGroupedTransactionsList() {
    // Kelompokkan transaksi berdasarkan tanggal
    final Map<String, List<DashboardTransaction>> grouped = {};
    for (final tx in _transactions) {
      grouped.putIfAbsent(tx.dateStr, () => []).add(tx);
    }

    return Column(
      children: grouped.entries.map((entry) {
        final dateStr = entry.key;
        final items = entry.value;

        int groupTotal = 0;
        for (final item in items) {
          groupTotal += item.amount;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Tanggal
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 6,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      dateStr,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      DashboardDataStore.formatCurrency(
                        groupTotal,
                        showSign: true,
                      ),
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: widget.isExpense
                            ? const Color(0xFFDC2626)
                            : const Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
              ),

              // Item Kartu Transaksi
              Column(
                children: items.map((tx) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: RepaintBoundary(
                      child: _buildTransactionCard(tx),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Kartu Transaksi Tactile Modern
  Widget _buildTransactionCard(DashboardTransaction tx) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          _openEditTransaction(tx);
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x062563EB),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
              BoxShadow(
                color: Color(0x040F172A),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              // Ikon 3D Panah Melayang (Pemasukan: Naik, Pengeluaran: Turun) Tanpa Kontainer
              Image.asset(
                tx.isIncome
                    ? 'assets/icons/3d/income_arrow.webp'
                    : 'assets/icons/3d/expense_arrow.webp',
                width: 38,
                height: 38,
                fit: BoxFit.contain,
                cacheWidth: 114,
                cacheHeight: 114,
              ),
              const SizedBox(width: 12),

              // Detail Deskripsi & Waktu / Catatan
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.meta.isNotEmpty ? tx.meta : tx.category,
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
                      tx.category,
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

              const SizedBox(width: 8),

              // Nominal Transaksi
              Text(
                DashboardDataStore.formatCurrency(tx.amount, showSign: true),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
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
      ),
    );
  }

  /// Empty State jika tidak ada transaksi
  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x062563EB),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFDBEAFE)),
              ),
              child: const Center(
                child: Icon(
                  Icons.receipt_long_rounded,
                  size: 26,
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
              'Tidak ada catatan transaksi untuk kategori ini pada periode $_periodLabel.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Skeleton Loading sederhana & ringan
  Widget _buildLoadingSkeleton() {
    return Container(
      width: double.infinity,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: Color(0xFF2563EB),
          ),
        ),
      ),
    );
  }
}
