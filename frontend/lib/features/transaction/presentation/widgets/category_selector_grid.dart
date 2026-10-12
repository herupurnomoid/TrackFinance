import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/widgets/animations.dart';
import '../../../category/data/category_model.dart';
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
    this.iconColor = AppColors.tactilePrimary,
  });

  /// Konversi dari CategoryItem domain model ke UI Option
  factory TransactionCategoryOption.fromCategoryItem(CategoryItem item) {
    return TransactionCategoryOption(
      id: item.id,
      name: item.name,
      icon: item.icon,
      tintColor: getTintBackground(item.color),
      iconColor: item.color,
    );
  }

  static Color getTintBackground(Color color) {
    final value = color.toARGB32();
    if (value == const Color(0xFFDC2626).toARGB32() ||
        value == const Color(0xFFBA1A1A).toARGB32()) {
      return const Color(0xFFFFDAD6); // red tint container
    } else if (value == const Color(0xFF16A34A).toARGB32() ||
        value == const Color(0xFF007F36).toARGB32()) {
      return const Color(0xFFDCFCE7); // green tint container
    } else if (value == const Color(0xFFEA580C).toARGB32()) {
      return const Color(0xFFFFEDD5); // orange tint container
    } else if (value == const Color(0xFF9333EA).toARGB32()) {
      return const Color(0xFFF3E8FF); // purple tint container
    } else if (value == const Color(0xFF0D9488).toARGB32()) {
      return const Color(0xFFCCFBF1); // teal tint container
    } else if (value == const Color(0xFFE11D48).toARGB32()) {
      return const Color(0xFFFFE4E6); // pink tint container
    } else if (value == const Color(0xFF1E40AF).toARGB32()) {
      return const Color(0xFFDDE1FF); // dark blue tint
    }
    return const Color(0xFFDBEAFE); // primary blue tint
  }
}

class CategorySelectorGrid extends StatelessWidget {
  final bool isExpense;
  final String selectedCategoryId;
  final bool hasError;
  final List<TransactionCategoryOption>? categories;
  final ValueChanged<TransactionCategoryOption> onSelect;
  final VoidCallback onManageTap;

  const CategorySelectorGrid({
    super.key,
    required this.isExpense,
    required this.selectedCategoryId,
    this.hasError = false,
    this.categories,
    required this.onSelect,
    required this.onManageTap,
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
      onManageTap: onManageTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final availableCategories = categories ??
        (isExpense ? topExpenseCategories : topIncomeCategories);

    final topList = availableCategories.take(7).toList();

    // Cek apakah kategori yang dipilih berada di luar top 7
    final bool isSelectedInTop7 =
        topList.any((c) => c.id == selectedCategoryId);

    TransactionCategoryOption eighthTile;
    if (isSelectedInTop7 || selectedCategoryId.isEmpty) {
      eighthTile = const TransactionCategoryOption(
        id: 'more',
        name: 'Lebih Banyak',
        icon: Icons.more_horiz_rounded,
        tintColor: Color(0xFFDAE2FD),
        iconColor: Color(0xFF434655),
      );
    } else {
      // Tampilkan kategori luar yang sedang dipilih
      eighthTile = availableCategories.firstWhere(
        (c) => c.id == selectedCategoryId,
        orElse: () => const TransactionCategoryOption(
          id: 'more',
          name: 'Lebih Banyak',
          icon: Icons.more_horiz_rounded,
          tintColor: Color(0xFFDAE2FD),
          iconColor: Color(0xFF434655),
        ),
      );
    }

    final displayList = [...topList, eighthTile];

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
              // Hitungan "Semua (8)" telah dihapus sesuai permintaan
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Matriks 2 Row x 4 Column (Tepat 8 tiles)
        GridView.builder(
          padding: EdgeInsets.zero,
          clipBehavior: Clip.none,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            mainAxisExtent: 80, // Tinggi lebih compact agar proporsional
          ),
          itemCount: displayList.length,
          itemBuilder: (context, index) {
            final cat = displayList[index];
            final bool isSelected = cat.id == selectedCategoryId;
            final bool isLastTile = index == displayList.length - 1;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                PressableScale(
                  onTap: () {
                    if (isLastTile && (cat.id == 'more' || !isSelectedInTop7)) {
                      // Klik tile "Lebih Banyak" memunculkan seluruh kategori terdaftar
                      _openAllCategories(context, availableCategories);
                    } else {
                      onSelect(cat);
                    }
                  },
                  scaleFactor: 0.94,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOutCubic,
                    width: double.infinity,
                    height: 80,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: isSelected
                          ? const Color(0xFFDBE1FF) // primary-fixed
                          : Colors.white,
                      gradient: isSelected
                          ? null
                          : const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white,
                                Color(0xFFF2F3FF),
                              ],
                            ),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF004AC6)
                            : const Color(0xFFE2E8F0),
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF004AC6)
                                    .withValues(alpha: 0.22),
                                blurRadius: 10,
                                offset: const Offset(0, 3),
                              ),
                              const BoxShadow(
                                color: Colors.white,
                                blurRadius: 0,
                                offset: Offset(0, -1),
                              ),
                            ]
                          : [
                              BoxShadow(
                                color: const Color(0xFF2563EB)
                                    .withValues(alpha: 0.05),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                              BoxShadow(
                                color: const Color(0xFF0F172A)
                                    .withValues(alpha: 0.03),
                                blurRadius: 2,
                                offset: const Offset(0, 1),
                              ),
                              const BoxShadow(
                                color: Colors.white,
                                blurRadius: 0,
                                offset: Offset(0, -1),
                              ),
                            ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon Box Squircle (Compact 36x36)
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: cat.tintColor,
                            borderRadius: BorderRadius.circular(11),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.65),
                                blurRadius: 0,
                                offset: const Offset(0, -1),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              cat.icon,
                              size: 20,
                              color: cat.iconColor,
                            ),
                          ),
                        ),

                        // Jarak vertikal ketat & proporsional
                        const SizedBox(height: 3),

                        // Title Kategori
                        Text(
                          cat.name,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.labelSm.copyWith(
                            fontSize: 10.5,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: AppColors.tactileTextPrimary,
                            height: 1.15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Blue Checkmark Badge di pojok kanan atas saat terpilih
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
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x40004AC6),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
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

        const SizedBox(height: 12),

        // Action Pill Banner: Kelola Kategori & Ikon
        PressableScale(
          onTap: onManageTap,
          scaleFactor: 0.98,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFDBE1FF).withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFDBE1FF),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF2563EB).withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
                const BoxShadow(
                  color: Colors.white,
                  blurRadius: 0,
                  offset: Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF0F172A).withValues(alpha: 0.06),
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.settings_rounded,
                          size: 18,
                          color: AppColors.tactilePrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Kelola Kategori & Ikon',
                      style: AppTextStyles.labelMd.copyWith(
                        color: AppColors.tactilePrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: AppColors.tactilePrimary,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
