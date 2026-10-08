import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/models/user_profile.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../data/category_model.dart';
import '../widgets/add_category_modal.dart';
import '../widgets/category_grid_item.dart';
import '../widgets/category_intro_card.dart';
import '../widgets/category_tab_bar.dart';

class CategoryScreen extends StatefulWidget {
  final UserProfile? user;

  const CategoryScreen({
    super.key,
    this.user,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  bool _isExpenseTab = true;

  late List<CategoryItem> _expenseCategories;
  late List<CategoryItem> _incomeCategories;

  @override
  void initState() {
    super.initState();
    _expenseCategories = List.from(DefaultCategories.defaultExpenseCategories);
    _incomeCategories = List.from(DefaultCategories.defaultIncomeCategories);
  }

  void _openAddCategoryModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AddCategoryModal(
          initialIsExpense: _isExpenseTab,
          onSave: (name, icon, isExpense) {
            final newCategory = CategoryItem(
              id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
              name: name,
              icon: icon,
              isExpense: isExpense,
              isCustom: true,
            );

            setState(() {
              if (isExpense) {
                _expenseCategories.insert(0, newCategory);
                _isExpenseTab = true;
              } else {
                _incomeCategories.insert(0, newCategory);
                _isExpenseTab = false;
              }
            });

            _showSuccessToast('Kategori "$name" berhasil disimpan!');
          },
        );
      },
    );
  }

  void _showSuccessToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.white,
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(99)),
        margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
        content: Row(
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: AppColors.primary,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: AppTextStyles.labelMd.copyWith(
                  color: AppColors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentList = _isExpenseTab ? _expenseCategories : _incomeCategories;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface.withValues(alpha: 0.95),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Container(
              height: 64,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back button
                  InkWell(
                    onTap: () => Navigator.of(context).maybePop(),
                    borderRadius: BorderRadius.circular(22),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryContainer.withValues(alpha: 0.18),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                            spreadRadius: -2,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 19,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                  ),

                  // Title
                  Expanded(
                    child: Text(
                      'Atur Kategori & Alokasi',
                      style: AppTextStyles.headlineSm.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Avatar indicator
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(user: widget.user),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.person_rounded,
                          size: 18,
                          color: Colors.white,
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
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Column(
            children: [
              // Intro Card: Alokasi & Kategori
              const CategoryIntroCard(),

              const SizedBox(height: 20),

              // Segmented Tab Toggle: Pengeluaran vs Pemasukan
              CategoryTabBar(
                isExpenseSelected: _isExpenseTab,
                onTabChanged: (isExpense) {
                  setState(() {
                    _isExpenseTab = isExpense;
                  });
                },
              ),

              const SizedBox(height: 20),

              // 3-Column Category Grid
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.95,
                ),
                itemCount: currentList.length,
                itemBuilder: (context, index) {
                  final cat = currentList[index];
                  return CategoryGridItem(
                    category: cat,
                    onTap: () {
                      _showSuccessToast('Kategori ${cat.name} dipilih');
                    },
                  );
                },
              ),

              const SizedBox(height: 28),

              // Primary Floating/Action Button: Tambah Kategori Baru
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(99),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryContainer.withValues(alpha: 0.45),
                      blurRadius: 28,
                      spreadRadius: -4,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(99),
                    onTap: _openAddCategoryModal,
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.add_circle_outline_rounded,
                            size: 22,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tambah Kategori Baru',
                            style: AppTextStyles.labelLg.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
