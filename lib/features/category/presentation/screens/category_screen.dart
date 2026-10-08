import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/widgets/animations.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../data/category_model.dart';
import '../widgets/add_category_modal.dart';
import '../widgets/category_grid_item.dart';
import '../widgets/category_intro_card.dart';
import '../widgets/category_search_bar.dart';
import '../widgets/category_skeleton.dart';
import '../widgets/category_tab_bar.dart';

class CategoryScreen extends StatefulWidget {
  final UserProfile? user;
  final bool? isLoading;

  const CategoryScreen({
    super.key,
    this.user,
    this.isLoading,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late bool _isLoading;
  bool _isExpenseTab = true;

  late List<CategoryItem> _expenseCategories;
  late List<CategoryItem> _incomeCategories;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _isLoading = widget.isLoading ?? false;
    _expenseCategories = List.from(DefaultCategories.defaultExpenseCategories);
    _incomeCategories = List.from(DefaultCategories.defaultIncomeCategories);
  }

  @override
  void didUpdateWidget(covariant CategoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != null && widget.isLoading != _isLoading) {
      setState(() {
        _isLoading = widget.isLoading!;
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _toggleSkeleton() {
    setState(() {
      _isLoading = !_isLoading;
    });
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

  void _deleteCategory(CategoryItem category) {
    setState(() {
      if (category.isExpense) {
        _expenseCategories.removeWhere((item) => item.id == category.id);
      } else {
        _incomeCategories.removeWhere((item) => item.id == category.id);
      }
    });

    _showSuccessToast('Kategori "${category.name}" berhasil dihapus');
  }

  void _showCategoryDetails(CategoryItem category) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 18,
            bottom: MediaQuery.of(context).padding.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
            boxShadow: [
              BoxShadow(
                color: Color(0x2E006780),
                blurRadius: 30,
                offset: Offset(0, -10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const SizedBox(height: 20),

              // Category Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryContainer.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    category.icon,
                    size: 32,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              Text(
                category.name,
                style: AppTextStyles.headlineSm.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                category.isExpense ? 'Kategori Pengeluaran' : 'Kategori Pemasukan',
                style: AppTextStyles.bodySm.copyWith(
                  color: AppColors.secondary,
                ),
              ),

              const SizedBox(height: 24),

              // Quick Actions inside modal
              if (category.isCustom)
                PressableScale(
                  onTap: () {
                    Navigator.of(context).pop();
                    _deleteCategory(category);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: AppColors.errorContainer,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.onErrorContainer,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Hapus Kategori Ini',
                            style: AppTextStyles.labelLg.copyWith(
                              color: AppColors.onErrorContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.verified_user_rounded,
                        size: 20,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Kategori bawaan sistem tidak dapat dihapus',
                          style: AppTextStyles.bodySm.copyWith(
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 12),

              PressableScale(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Center(
                    child: Text(
                      'Tutup',
                      style: AppTextStyles.labelLg.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showSuccessToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
        margin: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
        content: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: Color(0xFFE2F4FB),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: 18,
              ),
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
    final filteredList = _searchQuery.isEmpty
        ? currentList
        : currentList
            .where(
              (cat) => cat.name.toLowerCase().contains(_searchQuery.toLowerCase()),
            )
            .toList();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Stack(
        children: [
          // Main Scrollable Area
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
                  top: 76.0, // Space for top blur app bar
                  bottom: 40.0,
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  child: _isLoading
                      ? const CategorySkeleton(key: ValueKey('skeleton'))
                      : Column(
                          key: const ValueKey('content'),
                          children: [
                            // 1. Intro Card: Alokasi & Kategori with lively stats
                            StaggeredEntrance(
                              index: 0,
                              child: CategoryIntroCard(
                                expenseCount: _expenseCategories.length,
                                incomeCount: _incomeCategories.length,
                              ),
                            ),

                            const SizedBox(height: 18),

                            // 2. Segmented Tab Bar: Pengeluaran vs Pemasukan
                            StaggeredEntrance(
                              index: 1,
                              child: CategoryTabBar(
                                isExpenseSelected: _isExpenseTab,
                                expenseCount: _expenseCategories.length,
                                incomeCount: _incomeCategories.length,
                                onTabChanged: (isExpense) {
                                  setState(() {
                                    _isExpenseTab = isExpense;
                                  });
                                },
                              ),
                            ),

                            const SizedBox(height: 16),

                            // 3. Sunken Clay Search Bar
                            StaggeredEntrance(
                              index: 2,
                              child: CategorySearchBar(
                                controller: _searchController,
                                onChanged: (query) {
                                  setState(() {
                                    _searchQuery = query;
                                  });
                                },
                                onClear: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              ),
                            ),

                            const SizedBox(height: 18),

                            // 4. 3-Column Category Grid or Empty Search
                            StaggeredEntrance(
                              index: 3,
                              child: filteredList.isEmpty
                                  ? _buildEmptyState()
                                  : GridView.builder(
                                      physics: const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        crossAxisSpacing: 12,
                                        mainAxisSpacing: 12,
                                        childAspectRatio: 0.90,
                                      ),
                                      itemCount: filteredList.length,
                                      itemBuilder: (context, index) {
                                        final cat = filteredList[index];
                                        return CategoryGridItem(
                                          category: cat,
                                          onTap: () => _showCategoryDetails(cat),
                                          onDelete: cat.isCustom
                                              ? () => _deleteCategory(cat)
                                              : null,
                                        );
                                      },
                                    ),
                            ),

                            const SizedBox(height: 28),

                            // 5. Primary Floating CTA Button: Tambah Kategori Baru
                            StaggeredEntrance(
                              index: 4,
                              child: PressableScale(
                                onTap: _openAddCategoryModal,
                                scaleFactor: 0.97,
                                child: Container(
                                  width: double.infinity,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryContainer,
                                    borderRadius: BorderRadius.circular(999),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primaryContainer
                                            .withValues(alpha: 0.45),
                                        blurRadius: 28,
                                        spreadRadius: -4,
                                        offset: const Offset(0, 14),
                                      ),
                                      BoxShadow(
                                        color: Colors.white.withValues(alpha: 0.65),
                                        blurRadius: 4,
                                        offset: const Offset(0, -2),
                                      ),
                                    ],
                                  ),
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
                                            fontSize: 15,
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

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              size: 28,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Kategori Tidak Ditemukan',
            style: AppTextStyles.labelLg.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tidak ada kategori yang cocok dengan "$_searchQuery"',
            style: AppTextStyles.bodySm.copyWith(
              color: AppColors.secondary,
            ),
            textAlign: TextAlign.center,
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
            color: AppColors.surface.withValues(alpha: 0.88),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
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
                  // Back button
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
                            color: AppColors.primaryContainer.withValues(alpha: 0.18),
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
                  Expanded(
                    child: Text(
                      'Atur Kategori & Alokasi',
                      style: AppTextStyles.headlineSm.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 16.5,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Right Action: Skeleton Loading Preview & Avatar
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Skeleton preview toggle
                      PressableScale(
                        onTap: _toggleSkeleton,
                        scaleFactor: 0.92,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: _isLoading
                                ? AppColors.primaryContainer
                                : AppColors.surfaceContainerLowest,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryContainer.withValues(alpha: 0.18),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                                spreadRadius: -2,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Icon(
                              _isLoading
                                  ? Icons.visibility_rounded
                                  : Icons.auto_awesome_rounded,
                              size: 18,
                              color: _isLoading ? Colors.white : AppColors.primary,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 8),

                      // Avatar indicator
                      PressableScale(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => ProfileScreen(user: widget.user),
                            ),
                          );
                        },
                        scaleFactor: 0.92,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.person_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
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
