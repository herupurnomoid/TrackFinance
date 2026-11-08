import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/services/auth_service_provider.dart';
import '../../../category/presentation/screens/category_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../transaction/presentation/screens/add_transaction_screen.dart';
import '../../../transaction/data/monthly_summary_model.dart';
import '../../../transaction/data/transaction_action_result.dart';
import '../../../transaction/data/transaction_model.dart';
import '../../../transaction/data/transaction_repository.dart';
import '../../../export/presentation/screens/export_data_screen.dart';
import '../../../report/presentation/screens/report_screen.dart';
import '../../data/dashboard_transaction_model.dart';
import '../widgets/dashboard_date_range_picker_dialog.dart';
import '../widgets/dashboard_overlap_layout.dart';
import '../widgets/dashboard_search_and_filter.dart';
import '../widgets/dashboard_shortcuts_row.dart';
import '../widgets/dashboard_tactile_header.dart';
import '../widgets/dashboard_tactile_skeleton.dart';
import '../widgets/dashboard_transactions_view.dart';
import '../widgets/header_time_theme.dart';

/// Halaman Dashboard Modern Tactile Finance
/// Sesuai referensi visual dengan skeuomorphic blue header, glassmorphic controls,
/// 4 shortcut buttons, sunken search, period filter pills, grouped transactions,
/// dan shimmer skeleton loading.
class DashboardScreen extends StatefulWidget {
  final UserProfile? user;
  final bool? isLoading;
  final int? initialYear;
  final int? initialMonthIndex;

  const DashboardScreen({
    super.key,
    this.user,
    this.isLoading,
    this.initialYear,
    this.initialMonthIndex,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
  late bool _isLoading;

  // Waktu & Filter State
  int _currentYear = 2026;
  int _currentMonthIndex = 9; // 9 = Oktober (0-based)
  late int _currentDecadeStart;
  DashboardPeriod _activePeriod = DashboardPeriod.hari;
  DateTimeRange? _selectedDateRange;

  // Waktu sistem aktif untuk tema background & pull-to-refresh
  DashboardTimeOfDay get _activeTimeOfDay => DashboardTimeOfDay.fromDateTime();

  // Pencarian
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Data Store
  late List<DashboardTransaction> _transactions;

  // Realtime Firestore Subscriptions (TX-12)
  StreamSubscription<List<TransactionModel>>? _txSubscription;
  StreamSubscription<MonthlySummaryModel?>? _summarySubscription;
  MonthlySummaryModel? _monthlySummary;

  // Scroll: header biru tetap diam (pinned) dan tertutup panel putih saat scroll
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _headerKey = GlobalKey();
  final ValueNotifier<bool> _isHeaderCoveredNotifier = ValueNotifier<bool>(false);

  /// Tambahan panjang vertikal untuk layer header bertema waktu agar memanjang
  /// ke bawah di balik content panel. Ini menghilangkan celah samping (corner gap)
  /// akibat lengkungan sudut radius (28px) tanpa mengubah posisi visual konten ataupun
  /// efek transisi scroll/waktu yang sudah ada.
  static const double _headerExtension = 48.0;

  UserProfile? get _effectiveUser =>
      widget.user ?? AuthServiceProvider.instance.currentUser;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final uid = _effectiveUser?.uid;
    _currentYear = widget.initialYear ??
        ((uid != null && uid.isNotEmpty) ? now.year : 2026);
    _currentMonthIndex = widget.initialMonthIndex ??
        ((uid != null && uid.isNotEmpty) ? (now.month - 1) : 9);
    _isLoading = widget.isLoading ?? false;
    _currentDecadeStart = (_currentYear ~/ 10) * 10;
    if (uid != null && uid.isNotEmpty) {
      _transactions = [];
    } else {
      _transactions = List.from(DashboardDataStore.initialTransactions);
    }
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_onScroll);
    _setupStreams();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _txSubscription?.cancel();
    _summarySubscription?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    _isHeaderCoveredNotifier.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      setState(() {});
    }
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
    final covered =
        _scrollController.offset >= (h - 24 - _headerExtension - topInset);
    if (covered != _isHeaderCoveredNotifier.value) {
      _isHeaderCoveredNotifier.value = covered;
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
    if (widget.user != oldWidget.user) {
      _setupStreams();
    }
  }

  /// Inisialisasi atau pembaruan listener realtime ke Firestore
  void _setupStreams() {
    final uid = _effectiveUser?.uid;
    if (uid == null || uid.isEmpty) return;

    _txSubscription?.cancel();

    if (_selectedDateRange != null) {
      _summarySubscription?.cancel();
      _summarySubscription = null;
      _monthlySummary = null;

      _txSubscription = TransactionRepository.instance
          .watchAllTransactions(uid)
          .listen(
        (list) {
          if (mounted) {
            setState(() {
              final seen = <String>{};
              _transactions = list
                  .map((m) => m.toDashboardTransaction())
                  .where((t) => seen.add(t.id))
                  .toList();
            });
          }
        },
        onError: (e) {
          debugPrint('[DashboardScreen] watchAllTransactions error: $e');
        },
      );
    } else if (_activePeriod == DashboardPeriod.hari) {
      final monthKey =
          '$_currentYear-${(_currentMonthIndex + 1).toString().padLeft(2, '0')}';

      _txSubscription = TransactionRepository.instance
          .watchTransactionsByMonth(uid, monthKey)
          .listen(
        (list) {
          if (mounted) {
            setState(() {
              final seen = <String>{};
              _transactions = list
                  .map((m) => m.toDashboardTransaction())
                  .where((t) => seen.add(t.id))
                  .toList();
            });
          }
        },
        onError: (e) {
          debugPrint('[DashboardScreen] watchTransactionsByMonth error: $e');
        },
      );

      _summarySubscription?.cancel();
      _summarySubscription = TransactionRepository.instance
          .watchMonthlySummary(uid, monthKey)
          .listen(
        (summary) {
          if (mounted) {
            setState(() {
              _monthlySummary = summary;
            });
          }
        },
        onError: (e) {
          debugPrint('[DashboardScreen] watchMonthlySummary error: $e');
        },
      );
    } else {
      // Periode Minggu, Bulan, atau Tahun:
      // Ambil seluruh data transaksi pengguna secara realtime agar seluruh data minggu
      // (termasuk tanggal di awal/akhir minggu yang melintasi batas bulan),
      // seluruh bulan (Januari s/d Desember), dan seluruh dekade/tahun terakumulasi dengan akurat.
      _summarySubscription?.cancel();
      _summarySubscription = null;
      _monthlySummary = null;

      _txSubscription = TransactionRepository.instance
          .watchAllTransactions(uid)
          .listen(
        (list) {
          if (mounted) {
            setState(() {
              final seen = <String>{};
              _transactions = list
                  .map((m) => m.toDashboardTransaction())
                  .where((t) => seen.add(t.id))
                  .toList();
            });
          }
        },
        onError: (e) {
          debugPrint('[DashboardScreen] watchAllTransactions error: $e');
        },
      );
    }
  }

  Future<void> _handleRefresh() async {
    HapticFeedback.lightImpact();
    final uid = _effectiveUser?.uid;
    if (uid != null && uid.isNotEmpty) {
      _setupStreams();
    } else {
      // Refresh in-place tanpa mengganti UI dengan skeleton agar layar tidak blank
      await Future.delayed(const Duration(milliseconds: 700));
      if (mounted) {
        setState(() {
          _transactions = List.from(DashboardDataStore.initialTransactions);
        });
      }
    }
  }

  // Filtered transactions berdasarkan pencarian (1-pass deduplikasi + filter)
  List<DashboardTransaction> get _filteredTransactions {
    final seen = <String>{};
    final trimmedQuery = _searchQuery.trim();
    if (trimmedQuery.isEmpty) {
      return _transactions.where((item) => seen.add(item.id)).toList();
    }
    final query = trimmedQuery.toLowerCase();
    final result = <DashboardTransaction>[];
    for (final item in _transactions) {
      if (!seen.add(item.id)) continue;
      if (item.category.toLowerCase().contains(query) ||
          item.meta.toLowerCase().contains(query)) {
        result.add(item);
      }
    }
    return result;
  }

  /// Menghitung daftar transaksi unik terfilter beserta total pemasukan & pengeluaran
  /// sekaligus dalam satu lintasan (single-pass) per siklus `build()` agar hemat CPU & alokasi GC.
  ({
    List<DashboardTransaction> transactions,
    int totalIncome,
    int totalExpense,
  }) _computeDashboardMetrics() {
    final list = _filteredTransactions;

    if (_selectedDateRange != null) {
      final range = _selectedDateRange!;
      int income = 0;
      int expense = 0;
      for (final tx in list) {
        if (_isTxInDateRange(tx, range)) {
          if (tx.isIncome) {
            income += tx.amount;
          } else {
            expense += tx.amount.abs();
          }
        }
      }
      return (transactions: list, totalIncome: income, totalExpense: expense);
    }

    if ((_activePeriod == DashboardPeriod.hari ||
            _activePeriod == DashboardPeriod.minggu) &&
        _monthlySummary != null) {
      return (
        transactions: list,
        totalIncome: _monthlySummary!.totalIncome,
        totalExpense: _monthlySummary!.totalExpense,
      );
    }

    int income = 0;
    int expense = 0;
    if (_activePeriod == DashboardPeriod.hari ||
        _activePeriod == DashboardPeriod.minggu) {
      for (final tx in list) {
        if (tx.year == _currentYear && tx.month == _currentMonthIndex) {
          if (tx.isIncome) {
            income += tx.amount;
          } else {
            expense += tx.amount.abs();
          }
        }
      }
    } else if (_activePeriod == DashboardPeriod.bulan) {
      for (final tx in list) {
        if (tx.year == _currentYear) {
          if (tx.isIncome) {
            income += tx.amount;
          } else {
            expense += tx.amount.abs();
          }
        }
      }
    } else {
      final decadeEnd = _currentDecadeStart + 9;
      for (final tx in list) {
        if (tx.year >= _currentDecadeStart && tx.year <= decadeEnd) {
          if (tx.isIncome) {
            income += tx.amount;
          } else {
            expense += tx.amount.abs();
          }
        }
      }
    }

    return (transactions: list, totalIncome: income, totalExpense: expense);
  }

  bool _isTxInDateRange(DashboardTransaction tx, DateTimeRange range) {
    final txDate = DateTime(tx.year, tx.month + 1, tx.day);
    final startDate = DateTime(range.start.year, range.start.month, range.start.day);
    final endDate = DateTime(range.end.year, range.end.month, range.end.day);
    return !txDate.isBefore(startDate) && !txDate.isAfter(endDate);
  }

  String _formatDateRangeLabel(DateTimeRange range) {
    final start = range.start;
    final end = range.end;
    final months = DashboardDataStore.monthsShort;

    if (start.year == end.year && start.month == end.month && start.day == end.day) {
      return '${start.day} ${months[start.month - 1]} ${start.year}';
    } else if (start.year == end.year && start.month == end.month) {
      return '${start.day} - ${end.day} ${months[start.month - 1]} ${start.year}';
    } else if (start.year == end.year) {
      return '${start.day} ${months[start.month - 1]} - ${end.day} ${months[end.month - 1]} ${start.year}';
    } else {
      return '${start.day} ${months[start.month - 1]} ${start.year} - ${end.day} ${months[end.month - 1]} ${end.year}';
    }
  }

  // Label Periode pada Glass Pill Header
  String get _periodLabel {
    if (_selectedDateRange != null) {
      return _formatDateRangeLabel(_selectedDateRange!);
    }
    if (_activePeriod == DashboardPeriod.hari ||
        _activePeriod == DashboardPeriod.minggu) {
      return '${DashboardDataStore.monthsName[_currentMonthIndex]} $_currentYear';
    } else if (_activePeriod == DashboardPeriod.bulan) {
      return '$_currentYear';
    } else {
      return '$_currentDecadeStart - ${_currentDecadeStart + 9}';
    }
  }

  bool get _isFilterActive {
    if (_selectedDateRange != null) return true;
    final now = DateTime.now();
    final uid = _effectiveUser?.uid;
    final defaultMonth = (uid != null && uid.isNotEmpty) ? (now.month - 1) : 9;
    final defaultYear = (uid != null && uid.isNotEmpty) ? now.year : 2026;
    return _activePeriod == DashboardPeriod.bulan ||
        _activePeriod == DashboardPeriod.tahun ||
        _currentYear != defaultYear ||
        _currentMonthIndex != defaultMonth;
  }

  void _handleResetToToday() {
    HapticFeedback.mediumImpact();
    setState(() {
      final now = DateTime.now();
      final uid = _effectiveUser?.uid;
      _selectedDateRange = null;
      _activePeriod = DashboardPeriod.hari;
      _currentYear = (uid != null && uid.isNotEmpty) ? now.year : 2026;
      _currentMonthIndex = (uid != null && uid.isNotEmpty) ? (now.month - 1) : 9;
      _currentDecadeStart = (_currentYear ~/ 10) * 10;
    });
    _setupStreams();
  }

  bool get _isPrevDisabled {
    if (_selectedDateRange != null) {
      return _selectedDateRange!.start.year <= 2020;
    }
    if (_activePeriod == DashboardPeriod.tahun) {
      final minYear = DashboardDataStore.getMinTransactionYear(_transactions);
      return _currentDecadeStart <= minYear;
    }
    return false;
  }

  bool get _isNextDisabled {
    if (_selectedDateRange != null) {
      return _selectedDateRange!.end.year >= 2035;
    }
    if (_activePeriod == DashboardPeriod.tahun) {
      final maxYear = DashboardDataStore.getMaxTransactionYear(_transactions);
      return (_currentDecadeStart + 9) >= maxYear;
    }
    return false;
  }

  void _handlePrevPeriod() {
    setState(() {
      if (_selectedDateRange != null) {
        final days = _selectedDateRange!.end.difference(_selectedDateRange!.start).inDays + 1;
        final newStart = _selectedDateRange!.start.subtract(Duration(days: days));
        final newEnd = _selectedDateRange!.end.subtract(Duration(days: days));
        _selectedDateRange = DateTimeRange(start: newStart, end: newEnd);
        _currentYear = newStart.year;
        _currentMonthIndex = newStart.month - 1;
        _currentDecadeStart = (_currentYear ~/ 10) * 10;
      } else if (_activePeriod == DashboardPeriod.hari ||
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
    _setupStreams();
  }

  void _handleNextPeriod() {
    setState(() {
      if (_selectedDateRange != null) {
        final days = _selectedDateRange!.end.difference(_selectedDateRange!.start).inDays + 1;
        final newStart = _selectedDateRange!.start.add(Duration(days: days));
        final newEnd = _selectedDateRange!.end.add(Duration(days: days));
        _selectedDateRange = DateTimeRange(start: newStart, end: newEnd);
        _currentYear = newStart.year;
        _currentMonthIndex = newStart.month - 1;
        _currentDecadeStart = (_currentYear ~/ 10) * 10;
      } else if (_activePeriod == DashboardPeriod.hari ||
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
    _setupStreams();
  }

  Future<void> _openTimePickerModal() async {
    HapticFeedback.lightImpact();
    final initialRange = _selectedDateRange ??
        DateTimeRange(
          start: DateTime(_currentYear, _currentMonthIndex + 1, 1),
          end: DateTime(
            _currentYear,
            _currentMonthIndex + 1,
            DateUtils.getDaysInMonth(_currentYear, _currentMonthIndex + 1),
          ),
        );

    final picked = await DashboardDateRangePickerDialog.show(
      context,
      initialDateRange: initialRange,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime(2035, 12, 31),
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = picked;
        _currentYear = picked.start.year;
        _currentMonthIndex = picked.start.month - 1;
        _currentDecadeStart = (_currentYear ~/ 10) * 10;
      });
      _setupStreams();
    }
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
      _txSubscription?.cancel();
      _summarySubscription?.cancel();
      await AuthServiceProvider.instance.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  void _openProfile(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (context, animation, secondaryAnimation) =>
            ProfileScreen(user: _effectiveUser),
      ),
    );
  }

  void _openCategories(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (context, animation, secondaryAnimation) =>
            CategoryScreen(user: _effectiveUser),
      ),
    );
  }

  void _openExport(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (context, animation, secondaryAnimation) =>
            ExportDataScreen(user: _effectiveUser),
      ),
    );
  }

  Future<void> _openAddTransaction(BuildContext context) async {
    final now = DateTime.now();
    final defaultDate =
        (_currentYear == now.year && _currentMonthIndex == now.month - 1)
            ? now
            : DateTime(
                _currentYear,
                _currentMonthIndex + 1,
                now.day.clamp(1, 28),
              );
    final result = await Navigator.of(context).push<dynamic>(
      PageRouteBuilder(
        opaque: true,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (context, animation, secondaryAnimation) =>
            AddTransactionScreen(
              user: _effectiveUser,
              initialDate: defaultDate,
              initialTime: TimeOfDay.fromDateTime(now),
            ),
      ),
    );

    if (!mounted || result == null) return;

    if (result is TransactionActionResult &&
        result.updatedTransaction != null) {
      final newTx = result.updatedTransaction!;
      final existingIndex =
          _transactions.indexWhere((t) => t.id == newTx.id);
      setState(() {
        if (existingIndex != -1) {
          _transactions[existingIndex] = newTx;
        } else {
          if (_activePeriod != DashboardPeriod.hari ||
              (newTx.year == _currentYear &&
                  newTx.month == _currentMonthIndex)) {
            _transactions.insert(0, newTx);
          }
        }
      });
    }
  }

  Future<void> _openEditTransaction(
    BuildContext context,
    DashboardTransaction tx,
  ) async {
    final result = await Navigator.of(context).push<dynamic>(
      PageRouteBuilder(
        opaque: true,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (context, animation, secondaryAnimation) =>
            AddTransactionScreen(user: _effectiveUser, transaction: tx),
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
        opaque: true,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
        pageBuilder: (context, animation, secondaryAnimation) =>
            ReportScreen(
              user: _effectiveUser,
              initialYear: _currentYear,
              initialMonthIndex: _currentMonthIndex,
              initialIsLoading:
                  _effectiveUser?.uid != null && _effectiveUser!.uid.isNotEmpty,
            ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final String displayName = _effectiveUser?.displayName?.trim().isNotEmpty == true
        ? _effectiveUser!.displayName!
        : 'Heru';
    final metrics = _isLoading
        ? (
            transactions: const <DashboardTransaction>[],
            totalIncome: 0,
            totalExpense: 0,
          )
        : _computeDashboardMetrics();

    return ValueListenableBuilder<bool>(
      valueListenable: _isHeaderCoveredNotifier,
      builder: (context, isHeaderCovered, scaffoldChild) {
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isHeaderCovered
                ? Brightness.dark
                : Brightness.light,
            statusBarBrightness: isHeaderCovered
                ? Brightness.light
                : Brightness.dark,
            systemNavigationBarColor: const Color(0xFFF1F5F9),
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
          child: scaffoldChild!,
        );
      },
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
                          // Diisolasi dengan RepaintBoundary + TickerMode dinamis agar saat
                          // header tertutup panel konten, animasi langit berhenti total (0% CPU/GPU).
                          AnimatedBuilder(
                            animation: _scrollController,
                            child: RepaintBoundary(
                              child: KeyedSubtree(
                                key: _headerKey,
                                child: ValueListenableBuilder<bool>(
                                  valueListenable: _isHeaderCoveredNotifier,
                                  builder: (context, isHeaderCovered, headerChild) {
                                    return TickerMode(
                                      enabled: !isHeaderCovered &&
                                          !MediaQuery.disableAnimationsOf(context),
                                      child: headerChild!,
                                    );
                                  },
                                  child: DashboardTactileHeader(
                                    userName: displayName,
                                    periodLabel: _periodLabel,
                                    totalIncomeValue: metrics.totalIncome,
                                    totalExpenseValue: metrics.totalExpense,
                                    isPrevDisabled: _isPrevDisabled,
                                    isNextDisabled: _isNextDisabled,
                                    onOpenPicker: _openTimePickerModal,
                                    onPrev: _handlePrevPeriod,
                                    onNext: _handleNextPeriod,
                                    onProfileTap: () => _openProfile(context),
                                    onLogout: _handleLogout,
                                    isFilterActive: _isFilterActive,
                                    onResetToToday: _handleResetToToday,
                                    bottomExtension: _headerExtension,
                                    timeOfDay: _activeTimeOfDay,
                                  ),
                                ),
                              ),
                            ),
                            builder: (context, child) {
                              final rawOffset = _scrollController.hasClients
                                  ? _scrollController.offset
                                  : 0.0;
                              final offset = rawOffset < 0 ? 0.0 : rawOffset;
                              return Transform.translate(
                                offset: Offset(0, offset),
                                child: child,
                              );
                            },
                          ),

                          // 2. Content Panel Overlapping Header
                          // Menggunakan DashboardOverlapLayout agar ukuran layout yang dilaporkan
                          // ke Column disesuaikan (child.height - topOverlap), sehingga panel
                          // menutup sempurna hingga dasar scroll view tanpa meninggalkan celah 72px.
                          DashboardOverlapLayout(
                            topOverlap: 24 + _headerExtension,
                            child: RepaintBoundary(
                              child: ClipRect(
                                // Potong bayangan bawah agar tidak ada garis bayangan horizontal
                                // melintang yang membuat latar belakang tampak "belang".
                                clipper: const TopOnlyShadowClipper(),
                                child: Container(
                                  width: double.infinity,
                                  constraints: BoxConstraints(
                                    minHeight:
                                        MediaQuery.of(context).size.height +
                                        (24 + _headerExtension),
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
                                    padding: EdgeInsets.fromLTRB(
                                      16,
                                      20,
                                      16,
                                      32 +
                                          MediaQuery.of(context).padding.bottom +
                                          24,
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
                                            _selectedDateRange = null;
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
                                          _setupStreams();
                                        },
                                      ),

                                      const SizedBox(height: 16),

                                      // 6. Grouped Transactions List
                                      DashboardTransactionsView(
                                        period: _activePeriod,
                                        dateRange: _selectedDateRange,
                                        transactions: metrics.transactions,
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
}
