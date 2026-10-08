import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/user_profile.dart';
import '../../../category/presentation/screens/category_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../data/dummy_dashboard_data.dart';
import '../widgets/add_transaction_modal.dart';
import '../widgets/cashflow_chart_card.dart';
import '../widgets/cashflow_summary_card.dart';
import '../widgets/category_distribution_card.dart';
import '../widgets/dashboard_greeting.dart';
import '../widgets/dashboard_search_filter.dart';
import '../widgets/menu_grid_section.dart';
import '../widgets/quick_stats_cards.dart';
import '../widgets/recent_transactions_section.dart';

import '../widgets/dashboard_skeleton.dart';

class DashboardScreen extends StatefulWidget {
  final UserProfile? user;
  final bool? isLoading;

  const DashboardScreen({
    super.key,
    this.user,
    this.isLoading,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late bool _isLoading;

  @override
  void initState() {
    super.initState();
    _isLoading = widget.isLoading ?? false;
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
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1400));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _openProfile(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            ProfileScreen(user: widget.user),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
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
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            ),
            child: child,
          );
        },
      ),
    );
  }

  void _openAddTransaction(BuildContext context) {
    AddTransactionModal.show(
      context,
      onManualInput: () => _showNotification(context, 'Membuka input manual transaksi'),
      onScanReceipt: () => _showNotification(context, 'Membuka kamera AI pemindai struk'),
    );
  }

  void _showNotification(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String displayName = widget.user?.displayName ?? 'Alex Pratama';

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: AppColors.primary,
          backgroundColor: AppColors.surfaceContainerLowest,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.only(
              left: 20.0,
              right: 20.0,
              top: 14.0,
              bottom: 32.0,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              child: _isLoading
                  ? const DashboardSkeleton(key: ValueKey('skeleton'))
                  : Column(
                      key: const ValueKey('content'),
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 1. Salutation Header
                        DashboardGreeting(
                          userName: displayName,
                          onProfileTap: () => _openProfile(context),
                        ),

                        const SizedBox(height: 20),

                        // 2. Perbandingan Arus Kas (Bulan Ini)
                        const CashflowSummaryCard(
                          income: DummyDashboardData.totalIncome,
                          expense: DummyDashboardData.totalExpense,
                        ),

                        const SizedBox(height: 20),

                        // 3. Form Pencarian & Filter Periode Waktu
                        DashboardSearchFilter(
                          onSearchChanged: (query) {
                            // Search filter handler
                          },
                          onPeriodSelected: (period) {
                            _showNotification(context, 'Periode: $period');
                          },
                          onCalendarTap: () {
                            _showNotification(context, 'Pilih bulan kalender');
                          },
                        ),

                        const SizedBox(height: 22),

                        // 4. Analisis Section (Top Pengeluaran & Kesehatan Finansial)
                        QuickStatsCards(
                          topCategory: DummyDashboardData.topExpenseTitle,
                          topAmount: DummyDashboardData.topExpenseAmount,
                          healthStatus: DummyDashboardData.healthStatus,
                          healthScore: DummyDashboardData.healthScore,
                          onTopCategoryTap: () => _openCategories(context),
                          onHealthTap: () => _showNotification(context, 'Detail Kesehatan Finansial'),
                        ),

                        const SizedBox(height: 20),

                        // 5. Menu Section (Kategori, Ekspor, Tanya AI, Tambah)
                        MenuGridSection(
                          onMenuTap: (title) {
                            if (title == 'Kategori') {
                              _openCategories(context);
                            } else if (title == 'Tambah') {
                              _openAddTransaction(context);
                            } else {
                              _showNotification(context, 'Membuka menu $title');
                            }
                          },
                        ),

                        const SizedBox(height: 22),

                        // 6. Tren Arus Kas (Grafik Bar 5 Hari)
                        const CashflowChartCard(
                          dataPoints: DummyDashboardData.chartPoints,
                        ),

                        const SizedBox(height: 22),

                        // 7. Distribusi Kategori (Donut Chart & Breakdown)
                        const CategoryDistributionCard(
                          items: DummyDashboardData.expenseCategories,
                        ),

                        const SizedBox(height: 22),

                        // 8. Rincian Transaksi (Grouped by Date)
                        RecentTransactionsSection(
                          groups: DummyDashboardData.transactionGroups,
                          onSortTap: () => _showNotification(context, 'Urutkan transaksi'),
                          onTransactionTap: (tx) => _showNotification(context, 'Detail transaksi: ${tx.title}'),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
