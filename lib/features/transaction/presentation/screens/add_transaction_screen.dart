import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/widgets/animations.dart';
import '../../../category/presentation/screens/category_screen.dart';
import '../widgets/add_transaction_skeleton.dart';
import '../widgets/additional_details_section.dart';
import '../widgets/amount_hero_card.dart';
import '../widgets/category_selector_grid.dart';
import '../widgets/transaction_type_switch.dart';

class AddTransactionScreen extends StatefulWidget {
  final UserProfile? user;
  final bool initialIsExpense;
  final bool initialIsLoading;

  const AddTransactionScreen({
    super.key,
    this.user,
    this.initialIsExpense = true,
    this.initialIsLoading = false,
  });

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  late bool _isExpense;
  late bool _isLoading;
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;

  late String _selectedCategoryId;
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  bool _isSaving = false;
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _isExpense = widget.initialIsExpense;
    _isLoading = widget.initialIsLoading;
    _amountController = TextEditingController(text: '150.000');
    _noteController = TextEditingController();
    _selectedCategoryId = _isExpense ? 'cat-food' : 'cat-salary';
    _selectedDate = DateTime(2025, 5, 24);
    _selectedTime = const TimeOfDay(hour: 14, minute: 30);

    _amountController.addListener(_formatAmountInput);
  }

  @override
  void dispose() {
    _amountController.removeListener(_formatAmountInput);
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  int _parseAmount(String text) {
    final clean = text.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(clean) ?? 0;
  }

  String _formatNumber(int number) {
    if (number == 0) return '0';
    final str = number.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  void _formatAmountInput() {
    final text = _amountController.text;
    final value = _parseAmount(text);
    final formatted = _formatNumber(value);

    if (text != formatted) {
      _amountController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
  }

  void _handleQuickAdd(int added) {
    final current = _parseAmount(_amountController.text);
    final next = current + added;
    _amountController.text = _formatNumber(next);
  }

  void _handleClearAmount() {
    _amountController.text = '0';
  }

  void _handleTypeChanged(bool isExpense) {
    setState(() {
      _isExpense = isExpense;
      _selectedCategoryId = isExpense ? 'cat-food' : 'cat-salary';
    });
  }

  Future<void> _handleRefresh() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _toggleSkeletonPreview() {
    setState(() {
      _isLoading = !_isLoading;
    });
  }

  void _openManageCategories() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CategoryScreen(user: widget.user),
      ),
    );
  }

  Future<void> _handleSaveTransaction() async {
    if (_isSaving || _isSaved) return;

    final amountVal = _parseAmount(_amountController.text);
    if (amountVal <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: const Text(
            'Harap masukkan nominal transaksi lebih dari 0',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    // Simulate saving delay
    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    setState(() {
      _isSaving = false;
      _isSaved = true;
    });

    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;

    final typeText = _isExpense ? 'Pengeluaran' : 'Pemasukan';
    final formattedAmount = _amountController.text;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        margin: const EdgeInsets.only(bottom: 24, left: 20, right: 20),
        content: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: Color(0xFFE2F4FB),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$typeText Rp $formattedAmount berhasil dicatat!',
                style: AppTextStyles.labelMd.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // Main Scrollable Content
          SafeArea(
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
                  top: 76.0, // Space for top blur appbar
                  bottom: 40.0,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  child: _isLoading
                      ? const AddTransactionSkeleton(key: ValueKey('skeleton'))
                      : Column(
                          key: const ValueKey('content'),
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Segmented Control: Pengeluaran vs Pemasukan
                            StaggeredEntrance(
                              index: 0,
                              child: TransactionTypeSwitch(
                                isExpense: _isExpense,
                                onChanged: _handleTypeChanged,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // 2. Hero Input Card: Nominal Transaksi
                            StaggeredEntrance(
                              index: 1,
                              child: AmountHeroCard(
                                controller: _amountController,
                                isExpense: _isExpense,
                                onQuickAdd: _handleQuickAdd,
                                onClear: _handleClearAmount,
                              ),
                            ),

                            const SizedBox(height: 22),

                            // 3. Kategori Selector Grid
                            StaggeredEntrance(
                              index: 2,
                              child: CategorySelectorGrid(
                                isExpense: _isExpense,
                                selectedCategoryId: _selectedCategoryId,
                                onSelect: (cat) {
                                  setState(() {
                                    _selectedCategoryId = cat.id;
                                  });
                                },
                                onManageTap: _openManageCategories,
                              ),
                            ),

                            const SizedBox(height: 22),

                            // 4. Rincian Tambahan (Tanggal, Waktu, Memo)
                            StaggeredEntrance(
                              index: 3,
                              child: AdditionalDetailsSection(
                                selectedDate: _selectedDate,
                                selectedTime: _selectedTime,
                                noteController: _noteController,
                                onDateChanged: (d) =>
                                    setState(() => _selectedDate = d),
                                onTimeChanged: (t) =>
                                    setState(() => _selectedTime = t),
                              ),
                            ),

                            const SizedBox(height: 28),

                            // 5. Primary Floating Clay CTA Button
                            StaggeredEntrance(
                              index: 4,
                              child: _buildSaveButton(),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),

          // Floating Frosted Glass Top App Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildFloatingAppBar(),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingAppBar() {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.85),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button with Tactile Clay Styling
                  PressableScale(
                    onTap: () => Navigator.of(context).maybePop(),
                    scaleFactor: 0.92,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF65D0F4).withValues(alpha: 0.20),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                            spreadRadius: -2,
                          ),
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.9),
                            blurRadius: 3,
                            offset: const Offset(0, -1),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 18,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                  ),

                  // Title
                  Text(
                    'Tambah Transaksi',
                    style: AppTextStyles.headlineSm.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                    ),
                  ),

                  // Skeleton Loading Toggle Button
                  PressableScale(
                    onTap: _toggleSkeletonPreview,
                    scaleFactor: 0.92,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: _isLoading
                            ? AppColors.primaryContainer
                            : AppColors.surfaceContainerLowest,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF65D0F4).withValues(alpha: 0.20),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                            spreadRadius: -2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          _isLoading
                              ? Icons.visibility_rounded
                              : Icons.auto_awesome_rounded,
                          size: 20,
                          color: _isLoading ? Colors.white : AppColors.primary,
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
    );
  }

  Widget _buildSaveButton() {
    return PressableScale(
      onTap: _handleSaveTransaction,
      scaleFactor: 0.97,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: _isSaved ? const Color(0xFF10B981) : AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (_isSaved ? const Color(0xFF10B981) : const Color(0xFF65D0F4))
                  .withValues(alpha: 0.50),
              blurRadius: 28,
              spreadRadius: -3,
              offset: const Offset(0, 14),
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.65),
              blurRadius: 5,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _isSaving
                ? Row(
                    key: const ValueKey('saving'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.6,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Menyimpan...',
                        style: AppTextStyles.headlineSm.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  )
                : _isSaved
                    ? Row(
                        key: const ValueKey('saved'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.done_all_rounded,
                            size: 24,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tersimpan!',
                            style: AppTextStyles.headlineSm.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        key: const ValueKey('idle'),
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle_rounded,
                            size: 22,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Simpan Transaksi',
                            style: AppTextStyles.headlineSm.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
          ),
        ),
      ),
    );
  }
}
