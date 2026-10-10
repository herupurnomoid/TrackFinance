import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/services/auth_service_provider.dart';
import '../../../../core/widgets/animations.dart';
import '../../../category/presentation/screens/category_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../transaction/presentation/screens/add_transaction_screen.dart';
import '../../../transaction/data/transaction_action_result.dart';
import '../../../export/presentation/screens/export_data_screen.dart';
import '../../../report/presentation/screens/report_screen.dart';
import '../../data/dashboard_transaction_model.dart';
import '../widgets/dashboard_search_and_filter.dart';
import '../widgets/dashboard_shortcuts_row.dart';
import '../widgets/dashboard_tactile_header.dart';
import '../widgets/dashboard_tactile_skeleton.dart';
import '../widgets/dashboard_time_picker_modal.dart';
import '../widgets/dashboard_transactions_view.dart';
import '../widgets/header_time_theme.dart';

/// Halaman Dashboard Modern Tactile Finance
/// Sesuai referensi visual dengan skeuomorphic blue header, glassmorphic controls,
/// 4 shortcut buttons, sunken search, period filter pills, grouped transactions,
/// dan shimmer skeleton loading.
class DashboardScreen extends StatefulWidget {
  final UserProfile? user;
  final bool? isLoading;

  const DashboardScreen({super.key, this.user, this.isLoading});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late bool _isLoading;

  // Waktu & Filter State
  int _currentYear = 2026;
  int _currentMonthIndex = 9; // 9 = Oktober (0-based)
  late int _currentDecadeStart;
  DashboardPeriod _activePeriod = DashboardPeriod.hari;

  // Waktu sistem aktif untuk tema background & pull-to-refresh
  DashboardTimeOfDay get _activeTimeOfDay => DashboardTimeOfDay.fromDateTime();

  // Pencarian
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Data Store
  late List<DashboardTransaction> _transactions;

  // Scroll: header biru tetap diam (pinned) dan tertutup panel putih saat scroll
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _headerKey = GlobalKey();
  bool _isHeaderCovered = false;

  @override
  void initState() {
    super.initState();
    _isLoading = widget.isLoading ?? false;
    _currentDecadeStart = (_currentYear ~/ 10) * 10;
    _transactions = List.from(DashboardDataStore.initialTransactions);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  double get _headerHeight {
    final box = _headerKey.currentContext?.findRenderObject() as RenderBox?;
    return (box != null && box.hasSize) ? box.size.height : 0;
  }

  /// Ganti warna ikon status bar ketika panel putih sudah menutup header.
  void _onScroll() {
    final h = _headerHeight;
    if (h <= 0) return;
    final topInset = MediaQuery.of(context).padding.top;
    final covered = _scrollController.offset >= (h - 24 - topInset);
    if (covered != _isHeaderCovered) {
      setState(() => _isHeaderCovered = covered);
    }
  }

  @override
  void didUpdateWidget(covariant DashboardScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != null && widget.isLoading != _isLoading) {
      setState(() {
        _isLoading = widget.isLoading!;
      });
    }
  }

  Future<void> _handleRefresh() async {
    HapticFeedback.lightImpact();
    // Refresh in-place tanpa mengganti UI dengan skeleton agar layar tidak blank
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) {
      setState(() {
        _transactions = List.from(DashboardDataStore.initialTransactions);
      });
    }
  }

  // Filtered transactions berdasarkan pencarian
  List<DashboardTransaction> get _filteredTransactions {
    if (_searchQuery.trim().isEmpty) return _transactions;
    final query = _searchQuery.toLowerCase();
    return _transactions.where((item) {
      return item.category.toLowerCase().contains(query) ||
          item.meta.toLowerCase().contains(query);
    }).toList();
  }

  // Label Periode pada Glass Pill Header
  String get _periodLabel {
    if (_activePeriod == DashboardPeriod.hari ||
        _activePeriod == DashboardPeriod.minggu) {
      return '${DashboardDataStore.monthsName[_currentMonthIndex]} $_currentYear';
    } else if (_activePeriod == DashboardPeriod.bulan) {
      return '$_currentYear';
    } else {
      return '$_currentDecadeStart - ${_currentDecadeStart + 9}';
    }
  }

  // Total Pemasukan & Pengeluaran Header (Raw Values for Animated Counter)
  int get _totalIncomeRaw {
    int total = 0;
    final list = _filteredTransactions;

    if (_activePeriod == DashboardPeriod.hari ||
        _activePeriod == DashboardPeriod.minggu) {
      for (final tx in list) {
        if (tx.year == _currentYear && tx.month == _currentMonthIndex) {
          if (tx.isIncome) total += tx.amount;
        }
      }
    } else if (_activePeriod == DashboardPeriod.bulan) {
      for (final tx in list) {
        if (tx.year == _currentYear) {
          if (tx.isIncome) total += tx.amount;
        }
      }
    } else {
      final decadeEnd = _currentDecadeStart + 9;
      for (final tx in list) {
        if (tx.year >= _currentDecadeStart && tx.year <= decadeEnd) {
          if (tx.isIncome) total += tx.amount;
        }
      }
    }
    return total;
  }

  int get _totalExpenseRaw {
    int total = 0;
    final list = _filteredTransactions;

    if (_activePeriod == DashboardPeriod.hari ||
        _activePeriod == DashboardPeriod.minggu) {
      for (final tx in list) {
        if (tx.year == _currentYear && tx.month == _currentMonthIndex) {
          if (!tx.isIncome) total += tx.amount.abs();
        }
      }
    } else if (_activePeriod == DashboardPeriod.bulan) {
      for (final tx in list) {
        if (tx.year == _currentYear) {
          if (!tx.isIncome) total += tx.amount.abs();
        }
      }
    } else {
      final decadeEnd = _currentDecadeStart + 9;
      for (final tx in list) {
        if (tx.year >= _currentDecadeStart && tx.year <= decadeEnd) {
          if (!tx.isIncome) total += tx.amount.abs();
        }
      }
    }
    return total;
  }

  bool get _isFilterActive {
    final now = DateTime.now();
    return _activePeriod == DashboardPeriod.bulan ||
        _activePeriod == DashboardPeriod.tahun ||
        _currentYear != now.year ||
        _currentMonthIndex != (now.month - 1);
  }

  void _handleResetToToday() {
    HapticFeedback.mediumImpact();
    setState(() {
      final now = DateTime.now();
      _activePeriod = DashboardPeriod.hari;
      _currentYear = now.year;
      _currentMonthIndex = now.month - 1;
      _currentDecadeStart = (now.year ~/ 10) * 10;
    });
  }

  bool get _isPrevDisabled {
    if (_activePeriod == DashboardPeriod.tahun) {
      final minYear = DashboardDataStore.getMinTransactionYear(_transactions);
      return _currentDecadeStart <= minYear;
    }
    return false;
  }

  bool get _isNextDisabled {
    if (_activePeriod == DashboardPeriod.tahun) {
      final maxYear = DashboardDataStore.getMaxTransactionYear(_transactions);
      return (_currentDecadeStart + 9) >= maxYear;
    }
    return false;
  }

  void _handlePrevPeriod() {
    setState(() {
      if (_activePeriod == DashboardPeriod.hari ||
          _activePeriod == DashboardPeriod.minggu) {
        _currentMonthIndex--;
        if (_currentMonthIndex < 0) {
          _currentMonthIndex = 11;
          _currentYear--;
          _currentDecadeStart = (_currentYear ~/ 10) * 10;
        }
      } else if (_activePeriod == DashboardPeriod.bulan) {
        _currentYear--;
        _currentDecadeStart = (_currentYear ~/ 10) * 10;
      } else if (_activePeriod == DashboardPeriod.tahun) {
        final minYear = DashboardDataStore.getMinTransactionYear(_transactions);
        if (_currentDecadeStart > minYear) {
          _currentDecadeStart -= 10;
        }
      }
    });
  }

  void _handleNextPeriod() {
    setState(() {
      if (_activePeriod == DashboardPeriod.hari ||
          _activePeriod == DashboardPeriod.minggu) {
        _currentMonthIndex++;
        if (_currentMonthIndex > 11) {
          _currentMonthIndex = 0;
          _currentYear++;
          _currentDecadeStart = (_currentYear ~/ 10) * 10;
        }
      } else if (_activePeriod == DashboardPeriod.bulan) {
        _currentYear++;
        _currentDecadeStart = (_currentYear ~/ 10) * 10;
      } else if (_activePeriod == DashboardPeriod.tahun) {
        final maxYear = DashboardDataStore.getMaxTransactionYear(_transactions);
        if (_currentDecadeStart + 9 < maxYear) {
          _currentDecadeStart += 10;
        }
      }
    });
  }

  void _openTimePickerModal() {
    DashboardTimePickerModal.show(
      context,
      period: _activePeriod,
      currentYear: _currentYear,
      currentMonthIndex: _currentMonthIndex,
      currentDecadeStart: _currentDecadeStart,
      minYear: DashboardDataStore.getMinTransactionYear(_transactions),
      maxYear: DashboardDataStore.getMaxTransactionYear(_transactions),
      onSelectMonthAndYear: (monthIndex, year) {
        setState(() {
          _currentMonthIndex = monthIndex;
          _currentYear = year;
          _currentDecadeStart = (_currentYear ~/ 10) * 10;
        });
      },
      onSelectMonth: (index) {
        setState(() => _currentMonthIndex = index);
      },
      onSelectYear: (year) {
        setState(() {
          _currentYear = year;
          _currentDecadeStart = (_currentYear ~/ 10) * 10;
        });
      },
      onSelectDecade: (decadeStart) {
        setState(() => _currentDecadeStart = decadeStart);
      },
    );
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar dari Akun?'),
        content: const Text('Anda akan dialihkan kembali ke halaman login.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      await AuthServiceProvider.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  void _openProfile(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ProfileScreen(user: widget.user),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          );
        },
      ),
    );
  }

  void _openCategories(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            CategoryScreen(user: widget.user),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          );
        },
      ),
    );
  }

  void _openExport(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ExportDataScreen(user: widget.user),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          );
        },
      ),
    );
  }

  Future<void> _openAddTransaction(BuildContext context) async {
    final result = await Navigator.of(context).push<dynamic>(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            AddTransactionScreen(user: widget.user),
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                child: child,
              );
            },
      ),
    );

    if (!mounted || result == null) return;

    if (result is TransactionActionResult &&
        result.updatedTransaction != null) {
      setState(() {
        _transactions.insert(0, result.updatedTransaction!);
      });
    }
  }

  Future<void> _openEditTransaction(
    BuildContext context,
    DashboardTransaction tx,
  ) async {
    final result = await Navigator.of(context).push<dynamic>(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            AddTransactionScreen(user: widget.user, transaction: tx),
        transitionsBuilder:
            (context, animation, secondaryAnimation, child) {
              return SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                child: child,
              );
            },
      ),
    );

    if (!mounted || result == null) return;

    if (result is TransactionActionResult) {
      if (result.isDeleted) {
        setState(() {
          _transactions.removeWhere((t) => t.id == result.transactionId);
        });
      } else if (result.updatedTransaction != null) {
        final idx =
            _transactions.indexWhere((t) => t.id == result.transactionId);
        if (idx != -1) {
          setState(() {
            _transactions[idx] = result.updatedTransaction!;
          });
        }
      }
    }
  }

  void _openReports(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ReportScreen(user: widget.user),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
                .animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                ),
            child: child,
          );
        },
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final String displayName = widget.user?.displayName ?? 'Heru';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: _isHeaderCovered
            ? Brightness.dark
            : Brightness.light,
        statusBarBrightness: _isHeaderCovered
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarColor: const Color(0xFFF1F5F9),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        body: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          // Latar terbelah: warna waktu aktif di atas (untuk pull-to-refresh), abu terang di bawah
          // agar efek bounce di dasar halaman tidak memunculkan strip biru/warna berbeda.
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _activeTimeOfDay.pullToRefreshTopColor,
                _activeTimeOfDay.pullToRefreshTopColor,
                const Color(0xFFF1F5F9),
                const Color(0xFFF1F5F9),
              ],
              stops: const [0.0, 0.4, 0.4, 1.0],
            ),
          ),
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            color: const Color(0xFF2563EB),
            backgroundColor: Colors.white,
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _isLoading
                    ? const DashboardTactileSkeleton(key: ValueKey('skeleton'))
                    : Column(
                        key: const ValueKey('content'),
                        children: [
                          // 1. Header Card (pinned): digeser balik sebesar offset scroll
                          // sehingga tetap diam, lalu tertutup panel putih di bawahnya.
                          AnimatedBuilder(
                            animation: _scrollController,
                            child: KeyedSubtree(
                              key: _headerKey,
                              child: DashboardTactileHeader(
                                userName: displayName,
                                periodLabel: _periodLabel,
                                totalIncomeValue: _totalIncomeRaw,
                                totalExpenseValue: _totalExpenseRaw,
                                isPrevDisabled: _isPrevDisabled,
                                isNextDisabled: _isNextDisabled,
                                onOpenPicker: _openTimePickerModal,
                                onPrev: _handlePrevPeriod,
                                onNext: _handleNextPeriod,
                                onProfileTap: () => _openProfile(context),
                                onLogout: _handleLogout,
                                isFilterActive: _isFilterActive,
                                onResetToToday: _handleResetToToday,
                              ),
                            ),
                            builder: (context, child) {
                              final rawOffset = _scrollController.hasClients
                                  ? _scrollController.offset
                                  : 0.0;
                              final offset = rawOffset < 0 ? 0.0 : rawOffset;
                              final h = _headerHeight;
                              final progress = h > 0
                                  ? (offset / h).clamp(0.0, 1.0)
                                  : 0.0;
                              return Transform.translate(
                                offset: Offset(0, offset),
                                child: Opacity(
                                  opacity: 1 - (progress * 0.55),
                                  child: Transform.scale(
                                    scale: 1 - (progress * 0.06),
                                    alignment: Alignment.topCenter,
                                    child: child,
                                  ),
                                ),
                              );
                            },
                          ),

                          // 2. Content Panel Overlapping Header (-24px margin-top)
                          Transform.translate(
                            offset: const Offset(0, -24),
                            child: Container(
                              width: double.infinity,
                              constraints: BoxConstraints(
                                minHeight: MediaQuery.of(context).size.height,
                              ),
                              decoration: const BoxDecoration(
                                color: Color(
                                  0xFFF1F5F9,
                                ), // Slate 100 App Canvas
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(28),
                                  topRight: Radius.circular(28),
                                ),
                                // Bayangan tepi atas agar panel terasa "naik" menutupi header
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0x290F172A),
                                    blurRadius: 24,
                                    offset: Offset(0, -6),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  20,
                                  16,
                                  32,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // 3. Empat Tombol Pintasan (Tambah, Kategori, Ekspor/Impor, Laporan)
                                    DashboardShortcutsRow(
                                      onAdd: () => _openAddTransaction(context),
                                      onCategory: () =>
                                          _openCategories(context),
                                      onExportImport: () =>
                                          _openExport(context),
                                      onReports: () => _openReports(context),
                                    ),
                                    const SizedBox(height: 14),

                                    // 4. Sunken Search Box & 5. Period Filter Pills
                                    DashboardSearchAndFilter(
                                      searchController: _searchController,
                                      activePeriod: _activePeriod,
                                      onSearchChanged: (query) {
                                        setState(() => _searchQuery = query);
                                      },
                                      onPeriodChanged: (period) {
                                        setState(() {
                                          _activePeriod = period;
                                          if (period == DashboardPeriod.hari) {
                                            final now = DateTime.now();
                                            _currentYear = now.year;
                                            _currentMonthIndex = now.month - 1;
                                            _currentDecadeStart =
                                                (_currentYear ~/ 10) * 10;
                                          } else if (period == DashboardPeriod.tahun) {
                                            _currentDecadeStart =
                                                (_currentYear ~/ 10) * 10;
                                          }
                                        });
                                      },
                                    ),

                                    // Banner & Button "Kembali ke Hari Ini" saat filter bulan/tahun aktif
                                    if (_isFilterActive) ...[
                                      const SizedBox(height: 12),
                                      _buildReturnToTodayBanner(),
                                    ],

                                    const SizedBox(height: 16),

                                    // 6. Grouped Transactions List
                                    DashboardTransactionsView(
                                      period: _activePeriod,
                                      transactions: _filteredTransactions,
                                      currentYear: _currentYear,
                                      currentMonthIndex: _currentMonthIndex,
                                      currentDecadeStart: _currentDecadeStart,
                                      onTransactionTap: (tx) => _openEditTransaction(context, tx),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Banner tactile interaktif dengan tombol "Kembali ke Hari Ini" saat filter bulan/tahun aktif
  Widget _buildReturnToTodayBanner() {
    String filterDesc = '';
    IconData filterIcon = Icons.filter_alt_rounded;

    if (_activePeriod == DashboardPeriod.bulan) {
      filterDesc = 'Filter Bulan aktif: Tahun $_currentYear';
      filterIcon = Icons.calendar_view_month_rounded;
    } else if (_activePeriod == DashboardPeriod.tahun) {
      filterDesc =
          'Filter Tahun aktif: $_currentDecadeStart - ${_currentDecadeStart + 9}';
      filterIcon = Icons.date_range_rounded;
    } else {
      filterDesc =
          'Filter: ${DashboardDataStore.monthsName[_currentMonthIndex]} $_currentYear';
      filterIcon = Icons.calendar_today_rounded;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF), // Soft Blue Tint
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFBFDBFE),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Filter Info Badge
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDBEAFE),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF93C5FD),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      filterIcon,
                      size: 16,
                      color: const Color(0xFF2563EB),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    filterDesc,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E40AF),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Tactile 3D "Kembali ke Hari Ini" Button
          PressableScale(
            onTap: _handleResetToToday,
            scaleFactor: 0.94,
            translateY: 2.5,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF3B82F6),
                    Color(0xFF1D4ED8),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF60A5FA),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.replay_rounded,
                    size: 15,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Kembali ke Hari Ini',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.2,
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
}
