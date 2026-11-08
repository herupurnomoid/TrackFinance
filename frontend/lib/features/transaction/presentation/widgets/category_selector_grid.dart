import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/animations.dart';
import '../../../category/data/category_model.dart';
import '../../../category/presentation/widgets/category_3d_icon.dart';
import 'all_categories_bottom_sheet.dart';

class TransactionCategoryOption {
  final String id;
  final String name;
  final IconData icon;
  final Color tintColor;
  final Color iconColor;

  const TransactionCategoryOption({
    required this.id,
    required this.name,
    required this.icon,
    this.tintColor = const Color(0xFFDBE1FF),
    this.iconColor = const Color(0xFF004AC6),
  });

  /// Konversi dari CategoryItem domain model ke UI Option
  factory TransactionCategoryOption.fromCategoryItem(CategoryItem item) {
    return TransactionCategoryOption(
      id: item.id,
      name: item.name,
      icon: item.icon,
      tintColor: const Color(0xFFDBE1FF),
      iconColor: const Color(0xFF004AC6),
    );
  }

  static Color getTintBackground([Color? color]) {
    return const Color(0xFFDBE1FF);
  }
}

class CategorySelectorGrid extends StatelessWidget {
  final bool isExpense;
  final String selectedCategoryId;
  final bool hasError;
  final List<TransactionCategoryOption>? categories;
  final ValueChanged<TransactionCategoryOption> onSelect;
  final VoidCallback? onManageTap;

  const CategorySelectorGrid({
    super.key,
    required this.isExpense,
    required this.selectedCategoryId,
    this.hasError = false,
    this.categories,
    required this.onSelect,
    this.onManageTap,
  });

  // Kategori pengeluaran bawaan dari Category Management
  static List<TransactionCategoryOption> get topExpenseCategories =>
      DefaultCategories.defaultExpenseCategories
          .map((c) => TransactionCategoryOption.fromCategoryItem(c))
          .toList();

  // Kategori pemasukan bawaan dari Category Management
  static List<TransactionCategoryOption> get topIncomeCategories =>
      DefaultCategories.defaultIncomeCategories
          .map((c) => TransactionCategoryOption.fromCategoryItem(c))
          .toList();

  void _openAllCategories(
    BuildContext context,
    List<TransactionCategoryOption> fullList,
  ) {
    AllCategoriesBottomSheet.show(
      context,
      isExpense: isExpense,
      selectedCategoryId: selectedCategoryId,
      categories: fullList,
      onSelect: onSelect,
      onManageTap: onManageTap ?? () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    final availableCategories = categories ??
        (isExpense ? topExpenseCategories : topIncomeCategories);

    // Ambil maksimal 3 kategori pertama untuk baris pertama
    final topList = availableCategories.take(3).toList();

    // Cek apakah kategori yang dipilih berada di dalam top 3
    final bool isSelectedInTop3 =
        topList.any((c) => c.id == selectedCategoryId);

    const moreTile = TransactionCategoryOption(
      id: 'more',
      name: 'Lebih Banyak',
      icon: Icons.more_horiz_rounded,
      tintColor: Color(0xFFDAE2FD),
      iconColor: Color(0xFF434655),
    );

    List<TransactionCategoryOption> displayList;
    if (isSelectedInTop3 || selectedCategoryId.isEmpty) {
      displayList = [...topList, moreTile];
    } else {
      // Tampilkan kategori luar yang sedang dipilih di slot ke-3 agar selalu terlihat aktif
      final selectedCategory = availableCategories.firstWhere(
        (c) => c.id == selectedCategoryId,
        orElse: () => moreTile,
      );
      if (topList.length >= 3) {
        displayList = [topList[0], topList[1], selectedCategory, moreTile];
      } else {
        displayList = [...topList, selectedCategory, moreTile];
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Row: Judul Kategori & Optional Error Indicator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Kategori',
                    style: AppTextStyles.headlineSm.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: AppColors.tactileTextPrimary,
                    ),
                  ),
                  if (hasError) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.errorContainer.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Pilih 1 kategori',
                        style: AppTextStyles.labelSm.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Matriks 1 Row x 4 Column (3 Kategori + 1 Ikon "Lebih Banyak" di paling kanan)
        // Menampilkan ikon 3D bebas tanpa kontainer dan tanpa background color
        GridView.builder(
          padding: EdgeInsets.zero,
          clipBehavior: Clip.none,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 0,
            mainAxisExtent: 88,
          ),
          itemCount: displayList.length,
          itemBuilder: (context, index) {
            final cat = displayList[index];
            final bool isSelected = cat.id == selectedCategoryId;
            final bool isLastTile = index == displayList.length - 1;

            return PressableScale(
              onTap: () {
                if (isLastTile && cat.id == 'more') {
                  // Klik tile "Lebih Banyak" memunculkan seluruh kategori terdaftar
                  _openAllCategories(context, availableCategories);
                } else {
                  onSelect(cat);
                }
              },
              scaleFactor: 0.93,
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Stack untuk Ikon 3D dan Checkmark Badge saat terpilih
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // 3D Category Icon (Besar 52x52) murni tanpa batasan background atau kontainer
                        Category3DIcon(
                          id: cat.id,
                          name: cat.name,
                          icon: cat.icon,
                          isExpense: isExpense,
                          size: 52,
                        ),

                        // Indikator centang bulat jika item ini terpilih
                        if (isSelected)
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 18,
                              height: 18,
                              decoration: BoxDecoration(
                                color: const Color(0xFF004AC6),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1.5,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x35004AC6),
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.check_rounded,
                                  size: 10,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 5),

                    // Label Teks Kategori
                    Text(
                      cat.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.labelSm.copyWith(
                        fontSize: 11,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w600,
                        color: isSelected
                            ? const Color(0xFF004AC6)
                            : AppColors.tactileTextPrimary,
                        height: 1.15,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
