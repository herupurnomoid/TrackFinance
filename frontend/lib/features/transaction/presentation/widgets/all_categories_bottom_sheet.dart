import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/animations.dart';
import '../../../category/data/category_model.dart';
import 'category_selector_grid.dart';

/// Bottom Sheet untuk menampilkan SELURUH kategori yang terdaftar
/// ketika user menekan tile "Lebih Banyak".
class AllCategoriesBottomSheet extends StatefulWidget {
  final bool isExpense;
  final String selectedCategoryId;
  final List<TransactionCategoryOption>? categories;
  final ValueChanged<TransactionCategoryOption> onSelect;
  final VoidCallback onManageTap;

  const AllCategoriesBottomSheet({
    super.key,
    required this.isExpense,
    required this.selectedCategoryId,
    this.categories,
    required this.onSelect,
    required this.onManageTap,
  });

  static Future<void> show(
    BuildContext context, {
    required bool isExpense,
    required String selectedCategoryId,
    List<TransactionCategoryOption>? categories,
    required ValueChanged<TransactionCategoryOption> onSelect,
    required VoidCallback onManageTap,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: const Color(0xFF0F172A).withValues(alpha: 0.45),
      builder: (context) => AllCategoriesBottomSheet(
        isExpense: isExpense,
        selectedCategoryId: selectedCategoryId,
        categories: categories,
        onSelect: onSelect,
        onManageTap: onManageTap,
      ),
    );
  }

  // Daftar lengkap seluruh kategori pengeluaran terdaftar dari Category Management
  static List<TransactionCategoryOption> get allExpenseCategories =>
      DefaultCategories.defaultExpenseCategories
          .map((c) => TransactionCategoryOption.fromCategoryItem(c))
          .toList();

  // Daftar lengkap seluruh kategori pemasukan terdaftar dari Category Management
  static List<TransactionCategoryOption> get allIncomeCategories =>
      DefaultCategories.defaultIncomeCategories
          .map((c) => TransactionCategoryOption.fromCategoryItem(c))
          .toList();

  @override
  State<AllCategoriesBottomSheet> createState() =>
      _AllCategoriesBottomSheetState();
}

class _AllCategoriesBottomSheetState extends State<AllCategoriesBottomSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fullList = widget.categories ??
        (widget.isExpense
            ? AllCategoriesBottomSheet.allExpenseCategories
            : AllCategoriesBottomSheet.allIncomeCategories);

    final filteredList = fullList.where((cat) {
      if (_searchQuery.isEmpty) return true;
      return cat.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    final typeTitle =
        widget.isExpense ? 'Kategori Pengeluaran' : 'Kategori Pemasukan';

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.78,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x300F172A),
            blurRadius: 32,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Drag Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Title Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Semua $typeTitle',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.headlineSm.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.tactileTextPrimary,
                            fontSize: 16.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Pilih salah satu kategori untuk transaksi',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySm.copyWith(
                            color: const Color(0xFF64748B),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      widget.onManageTap();
                    },
                    borderRadius: BorderRadius.circular(999),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      child: Text(
                        'Kelola',
                        style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.tactilePrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Search Box
              Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFE2E8F0),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: Color(0xFF64748B),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val),
                        style: AppTextStyles.bodyMd.copyWith(
                          color: AppColors.tactileTextPrimary,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Cari kategori...',
                          hintStyle: AppTextStyles.bodyMd.copyWith(
                            color: const Color(0xFF94A3B8),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                        child: const Icon(
                          Icons.cancel_rounded,
                          size: 18,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Grid of All Categories
              Expanded(
                child: filteredList.isEmpty
                    ? Center(
                        child: Text(
                          'Kategori tidak ditemukan',
                          style: AppTextStyles.bodyMd.copyWith(
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.only(top: 4, bottom: 24),
                        clipBehavior: Clip.none,
                        physics: const BouncingScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          mainAxisExtent: 82,
                        ),
                        itemCount: filteredList.length,
                        itemBuilder: (context, index) {
                          final cat = filteredList[index];
                          final isSelected =
                              cat.id == widget.selectedCategoryId;

                          return Stack(
                            clipBehavior: Clip.none,
                            children: [
                              PressableScale(
                                onTap: () {
                                  widget.onSelect(cat);
                                  Navigator.of(context).pop();
                                },
                                scaleFactor: 0.94,
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 160),
                                  width: double.infinity,
                                  height: 82,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(16),
                                    color: isSelected
                                        ? const Color(0xFFDBE1FF)
                                        : Colors.white,
                                    border: Border.all(
                                      color: isSelected
                                          ? const Color(0xFF004AC6)
                                          : const Color(0xFFE2E8F0),
                                      width: isSelected ? 2 : 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: isSelected
                                            ? const Color(0xFF004AC6)
                                                .withValues(alpha: 0.20)
                                            : const Color(0xFF2563EB)
                                                .withValues(alpha: 0.05),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      // Icon Container (Compact 36x36)
                                      Container(
                                        width: 36,
                                        height: 36,
                                        decoration: BoxDecoration(
                                          color: cat.tintColor,
                                          borderRadius:
                                              BorderRadius.circular(11),
                                        ),
                                        child: Center(
                                          child: Icon(
                                            cat.icon,
                                            size: 20,
                                            color: cat.iconColor,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 3),

                                      // Label text tightly under icon
                                      Text(
                                        cat.name,
                                        textAlign: TextAlign.center,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTextStyles.labelSm.copyWith(
                                          fontSize: 10.5,
                                          fontWeight: isSelected
                                              ? FontWeight.w700
                                              : FontWeight.w600,
                                          color: AppColors.tactileTextPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Checkmark badge if selected
                              if (isSelected)
                                Positioned(
                                  top: -3,
                                  right: -3,
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF004AC6),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Center(
                                      child: Icon(
                                        Icons.check_rounded,
                                        size: 11,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
