import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/widgets/animations.dart';
import '../../../category/presentation/screens/category_screen.dart';
import '../../../dashboard/data/dashboard_transaction_model.dart';
import '../../../dashboard/presentation/widgets/tactile_time_header_wrapper.dart';
import '../../data/transaction_action_result.dart';
import '../widgets/add_transaction_skeleton.dart';
import '../widgets/additional_details_section.dart';
import '../widgets/all_categories_bottom_sheet.dart';
import '../widgets/amount_hero_card.dart';
import '../widgets/category_selector_grid.dart';
import '../widgets/tactile_3d_button.dart';
import '../widgets/transaction_delete_dialog.dart';
import '../widgets/transaction_type_switch.dart';

/// Halaman Tambah & Edit Transaksi Modern Tactile Finance
/// Mengadopsi Soft Skeuomorphism, 3D Buttons, Carved-in Inset Fields,
/// dan Tactile Quick-Add Chips dengan validasi interaktif.
/// Mendukung mode Edit dan Hapus transaksi bila parameter [transaction] diisi.
class AddTransactionScreen extends StatefulWidget {
  final UserProfile? user;
  final bool initialIsExpense;
  final bool initialIsLoading;
  final DashboardTransaction? transaction;

  const AddTransactionScreen({
    super.key,
    this.user,
    this.initialIsExpense = true,
    this.initialIsLoading = false,
    this.transaction,
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
  bool _hasValidationError = false;
  String? _validationErrorMessage;

  bool get isEditMode => widget.transaction != null;

  @override
  void initState() {
    super.initState();
    _isLoading = widget.initialIsLoading;

    if (widget.transaction != null) {
      final tx = widget.transaction!;
      _isExpense = !tx.isIncome;
      _amountController =
          TextEditingController(text: _formatNumber(tx.amount.abs()));
      _selectedCategoryId = _findCategoryId(tx.category, _isExpense);
      _selectedDate = DateTime(tx.year, tx.month + 1, tx.day);

      // Ekstraksi waktu & catatan dari meta (e.g. '16.03 · kopi')
      final parts = tx.meta.split('·').map((e) => e.trim()).toList();
      TimeOfDay time = const TimeOfDay(hour: 14, minute: 30);
      String note = '';
      for (final p in parts) {
        final timeMatch = RegExp(r'^(\d{1,2})[\.:](\d{2})$').firstMatch(p);
        if (timeMatch != null) {
          final h = int.tryParse(timeMatch.group(1)!) ?? 12;
          final m = int.tryParse(timeMatch.group(2)!) ?? 0;
          time = TimeOfDay(hour: h, minute: m);
        } else {
          note = p;
        }
      }
      _selectedTime = time;
      _noteController = TextEditingController(text: note);
    } else {
      _isExpense = widget.initialIsExpense;
      _amountController = TextEditingController(text: '150.000');
      _noteController = TextEditingController();
      _selectedCategoryId = _isExpense ? 'cat-food' : 'cat-salary';
      _selectedDate = DateTime(2025, 5, 24);
      _selectedTime = const TimeOfDay(hour: 14, minute: 30);
    }

    _amountController.addListener(_formatAmountInput);
  }

  @override
  void didUpdateWidget(covariant AddTransactionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIsLoading != widget.initialIsLoading) {
      setState(() {
        _isLoading = widget.initialIsLoading;
      });
    }
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

    if (_hasValidationError && value > 0) {
      setState(() {
        _hasValidationError = false;
        _validationErrorMessage = null;
      });
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
      _hasValidationError = false;
      _validationErrorMessage = null;
    });
  }

  Future<void> _handleRefresh() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }


  void _openManageCategories() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CategoryScreen(user: widget.user),
      ),
    );
  }

  static String _findCategoryId(String categoryName, bool isExpense) {
    final list = isExpense
        ? AllCategoriesBottomSheet.allExpenseCategories
        : AllCategoriesBottomSheet.allIncomeCategories;
    for (final item in list) {
      if (item.name.toLowerCase() == categoryName.toLowerCase()) {
        return item.id;
      }
    }
    for (final item in list) {
      if (item.name.toLowerCase().contains(categoryName.toLowerCase()) ||
          categoryName.toLowerCase().contains(item.name.toLowerCase())) {
        return item.id;
      }
    }
    return isExpense ? 'cat-food' : 'cat-salary';
  }

  static TransactionCategoryOption _getCategoryOption(
    String id,
    bool isExpense,
  ) {
    final list = isExpense
        ? AllCategoriesBottomSheet.allExpenseCategories
        : AllCategoriesBottomSheet.allIncomeCategories;
    for (final item in list) {
      if (item.id == id) return item;
    }
    return list.first;
  }

  Future<void> _handleDeleteTransaction() async {
    if (_isSaving) return;
    HapticFeedback.lightImpact();

    final catOption = _getCategoryOption(_selectedCategoryId, _isExpense);
    final amountText = 'Rp ${_amountController.text}';

    final confirmed = await TransactionDeleteDialog.show(
      context,
      categoryName: catOption.name,
      formattedAmount: amountText,
    );

    if (confirmed == true && mounted) {
      HapticFeedback.heavyImpact();
      final txId = widget.transaction?.id ?? '';
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
                  color: Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFDC2626),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Transaksi ${catOption.name} berhasil dihapus',
                  style: AppTextStyles.labelMd.copyWith(
                    color: AppColors.tactileTextPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      Navigator.of(context).pop(TransactionActionResult.deleted(txId));
    }
  }

  Future<void> _handleSaveTransaction() async {
    if (_isSaving || _isSaved) return;

    final amountVal = _parseAmount(_amountController.text);
    if (amountVal <= 0) {
      HapticFeedback.mediumImpact();
      setState(() {
        _hasValidationError = true;
        _validationErrorMessage = 'Mohon lengkapi data bertanda merah';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _hasValidationError = false;
      _validationErrorMessage = null;
    });

    HapticFeedback.lightImpact();

    // Simulasi penyimpanan transaksi
    await Future.delayed(const Duration(milliseconds: 650));

    if (!mounted) return;

    setState(() {
      _isSaving = false;
      _isSaved = true;
    });

    HapticFeedback.heavyImpact();

    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;

    final catOption = _getCategoryOption(_selectedCategoryId, _isExpense);
    final typeText = _isExpense ? 'Pengeluaran' : 'Pemasukan';
    final formattedAmount = _amountController.text;

    final timeStr =
        '${_selectedTime.hour.toString().padLeft(2, '0')}.${_selectedTime.minute.toString().padLeft(2, '0')}';
    final note = _noteController.text.trim();
    final metaStr = note.isNotEmpty ? '$timeStr · $note' : timeStr;

    final txId = widget.transaction?.id ??
        'tx-${DateTime.now().millisecondsSinceEpoch}';
    final updatedTx = DashboardTransaction(
      id: txId,
      dateStr:
          '${_selectedDate.day} ${DashboardDataStore.monthsName[_selectedDate.month - 1]} ${_selectedDate.year}',
      dateKey:
          '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
      year: _selectedDate.year,
      month: _selectedDate.month - 1,
      day: _selectedDate.day,
      category: catOption.name,
      meta: metaStr,
      amount: _isExpense ? -amountVal : amountVal,
      type: _isExpense ? TransactionType.expense : TransactionType.income,
      icon: catOption.icon,
    );

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
                color: Color(0xFFDCFCE7),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.tactileGreen,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isEditMode
                    ? 'Transaksi $typeText berhasil diperbarui!'
                    : '$typeText Rp $formattedAmount berhasil dicatat!',
                style: AppTextStyles.labelMd.copyWith(
                  color: AppColors.tactileTextPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    Navigator.of(context).pop(TransactionActionResult.updated(txId, updatedTx));
  }

  @override
  Widget build(BuildContext context) {
    final currentAmount = _parseAmount(_amountController.text);
    final bool isFormValid = currentAmount > 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F3FF), // surface-container-low
      body: Column(
        children: [
          // 1. Header Baru Waktu Dinamis (rounded-b-[28px])
          _buildHeaderBar(),

          // 2. Raised Content Panel (Menimpa Header sebesar 20px seperti halaman Kategori)
          Expanded(
            child: Container(
              transform: Matrix4.translationValues(0.0, -20.0, 0.0),
              decoration: const BoxDecoration(
                color: Color(0xFFF2F3FF),
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
                  color: AppColors.tactilePrimary,
                  backgroundColor: Colors.white,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 20, 16, 36),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      child: _isLoading
                          ? const AddTransactionSkeleton(key: ValueKey('skeleton'))
                          : Column(
                              key: const ValueKey('content'),
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            // Interactive Error Alert Toast (if validation failed)
                            if (_hasValidationError) ...[
                              _buildErrorToast(),
                              const SizedBox(height: 12),
                            ],

                            // 1. Segmented Control Switch: Pengeluaran vs Pemasukan
                            StaggeredEntrance(
                              index: 0,
                              child: TransactionTypeSwitch(
                                isExpense: _isExpense,
                                onChanged: _handleTypeChanged,
                              ),
                            ),

                            const SizedBox(height: 16),

                            // 2. Elevated Nominal Card with Carved Inset Well
                            StaggeredEntrance(
                              index: 1,
                              child: AmountHeroCard(
                                controller: _amountController,
                                isExpense: _isExpense,
                                hasError: _hasValidationError && currentAmount <= 0,
                                onQuickAdd: _handleQuickAdd,
                                onClear: _handleClearAmount,
                              ),
                            ),

                            const SizedBox(height: 18),

                            // 3. Category Selector Section (4-Column Squircle Matrix)
                            StaggeredEntrance(
                              index: 2,
                              child: CategorySelectorGrid(
                                isExpense: _isExpense,
                                selectedCategoryId: _selectedCategoryId,
                                hasError: _hasValidationError && _selectedCategoryId.isEmpty,
                                onSelect: (cat) {
                                  setState(() {
                                    _selectedCategoryId = cat.id;
                                  });
                                },
                                onManageTap: _openManageCategories,
                              ),
                            ),

                            const SizedBox(height: 18),

                            // 4. Date & Time Elevated Blocks & Recessed Note Well
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

                            const SizedBox(height: 24),

                            // 5. Sticky-like Action Area: 3D Button + Trust Info
                            StaggeredEntrance(
                              index: 4,
                              child: _buildBottomActionArea(isFormValid),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  ),
);
}

  /// Fixed Top Header Bar dengan gradien waktu dinamis, tombol kembali frosted, dan rounded-b-[28px]
  /// Mengadopsi layout dan dimensi luas yang seragam dengan Halaman Kategori dan Ekspor
  Widget _buildHeaderBar() {
    return TactileTimeHeaderWrapper(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 36),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Back Button: 44x44 circular frosted glass button
              PressableScale(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).maybePop();
                },
                scaleFactor: 0.93,
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
                        color: const Color(0xFF0F172A).withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
              ),

              // Header Title
              Text(
                isEditMode ? 'Edit Transaksi' : 'Tambah Transaksi',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),

              // Right Action: Frosted Delete Button (Edit Mode) or Spacer (Add Mode)
              if (isEditMode)
                PressableScale(
                  onTap: () {
                    HapticFeedback.lightImpact();
                    _handleDeleteTransaction();
                  },
                  scaleFactor: 0.93,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.35),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFDC2626).withValues(alpha: 0.25),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                )
              else
                const SizedBox(width: 44, height: 44),
            ],
          ),
        ),
      ),
    );
  }

  /// Interactive Error Alert Toast (Haptic Feedback Simulation dari HTML 2)
  Widget _buildErrorToast() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.errorContainer,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withValues(alpha: 0.18),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(
                Icons.report_problem_rounded,
                size: 20,
                color: AppColors.error,
              ),
              const SizedBox(width: 8),
              Text(
                _validationErrorMessage ?? 'Mohon lengkapi data bertanda merah',
                style: AppTextStyles.labelMd.copyWith(
                  color: AppColors.onErrorContainer,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
          PressableScale(
            onTap: () {
              setState(() {
                _hasValidationError = false;
                _validationErrorMessage = null;
              });
            },
            scaleFactor: 0.90,
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 16,
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Sticky-like Action Area: 3D Button + Trust Info Footer
  Widget _buildBottomActionArea(bool isFormValid) {
    return Column(
      children: [
        // 3D Skeuomorphic CTA Button
        Tactile3DButton(
          onTap: _handleSaveTransaction,
          isEnabled: isFormValid,
          isLoading: _isSaving,
          text: _isSaved
              ? (isEditMode ? 'Perubahan Disimpan!' : 'Transaksi Tersimpan!')
              : (isEditMode ? 'Perbarui Transaksi' : 'Simpan Transaksi'),
          icon: _isSaved
              ? Icons.check_circle_rounded
              : (isEditMode ? Icons.check_rounded : Icons.check_circle_rounded),
          gradientColors: _isSaved
              ? const [
                  Color(0xFF16A34A),
                  Color(0xFF15803D),
                ]
              : const [
                  Color(0xFF2563EB),
                  Color(0xFF1E40AF),
                ],
          height: 52,
          borderRadius: 18,
        ),

        // Tombol Hapus Transaksi Sekunder di Mode Edit
        if (isEditMode) ...[
          const SizedBox(height: 12),
          PressableScale(
            onTap: _isSaving ? null : _handleDeleteTransaction,
            scaleFactor: 0.96,
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFFECACA),
                  width: 1.2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A0F172A),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.delete_outline_rounded,
                    size: 19,
                    color: Color(0xFFDC2626),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Hapus Transaksi',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFDC2626),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        const SizedBox(height: 10),

        // Synchronized Wallet Status Note
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.verified_user_rounded,
              size: 16,
              color: AppColors.tactileGreen,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                isEditMode
                    ? 'Perubahan akan otomatis terbarui di laporan'
                    : 'Data tersinkron otomatis ke dompet utama',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodySm.copyWith(
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
