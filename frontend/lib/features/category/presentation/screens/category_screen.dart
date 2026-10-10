import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/widgets/animations.dart';
import '../../data/category_model.dart';
import '../widgets/add_category_modal.dart';
import '../widgets/category_delete_dialog.dart';
import '../widgets/category_empty_state.dart';
import '../widgets/category_grid_item.dart';
import '../widgets/category_skeleton.dart';
import '../../../dashboard/presentation/widgets/tactile_time_header_wrapper.dart';

/// Halaman Manajemen Kategori Modern Tactile Finance
/// Mendukung 4-Column Skeuomorphic Tile Matrix, Slide-up Edit Sheet,
/// Tactile Delete Confirmation Dialog, dan Centerpiece Empty State.
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

  // Kategori bawaan terisi sejak pertama kali pengguna masuk
  late List<CategoryItem> _expenseCategories;
  late List<CategoryItem> _incomeCategories;

  // Pesan Toast Floating Feedback
  String? _toastMessage;

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

  void _showToast(String message) {
    setState(() {
      _toastMessage = message;
    });

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted && _toastMessage == message) {
        setState(() {
          _toastMessage = null;
        });
      }
    });
  }

  void _openAddModal() {
    final existingNames = (_isExpenseTab ? _expenseCategories : _incomeCategories)
        .map((c) => c.name)
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AddCategoryModal(
          initialIsExpense: _isExpenseTab,
          existingNames: existingNames,
          onSave: (name, icon, color, isExpense) {
            final newCategory = CategoryItem(
              id: 'cat-${DateTime.now().millisecondsSinceEpoch}',
              name: name,
              icon: icon,
              color: color,
              isExpense: isExpense,
              isCustom: true,
            );

            setState(() {
              if (isExpense) {
                _expenseCategories.insert(
                  _expenseCategories.isEmpty ? 0 : _expenseCategories.length - 1,
                  newCategory,
                );
                _isExpenseTab = true;
              } else {
                _incomeCategories.insert(
                  _incomeCategories.isEmpty ? 0 : _incomeCategories.length - 1,
                  newCategory,
                );
                _isExpenseTab = false;
              }
            });

            _showToast('Kategori "$name" berhasil disimpan');
          },
        );
      },
    );
  }

  void _handleCategoryClick(CategoryItem category) {
    if (category.isLocked) {
      _showToast('Kategori "${category.name}" adalah kategori sistem bawaan');
      return;
    }

    final existingNames = (_isExpenseTab ? _expenseCategories : _incomeCategories)
        .map((c) => c.name)
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AddCategoryModal(
          categoryToEdit: category,
          initialIsExpense: category.isExpense,
          existingNames: existingNames,
          onSave: (name, icon, color, isExpense) {
            setState(() {
              if (isExpense) {
                final index = _expenseCategories.indexWhere((c) => c.id == category.id);
                if (index != -1) {
                  _expenseCategories[index] = category.copyWith(
                    name: name,
                    icon: icon,
                    color: color,
                  );
                }
              } else {
                final index = _incomeCategories.indexWhere((c) => c.id == category.id);
                if (index != -1) {
                  _incomeCategories[index] = category.copyWith(
                    name: name,
                    icon: icon,
                    color: color,
                  );
                }
              }
            });

            _showToast('Perubahan kategori disimpan');
          },
          onDelete: () {
            _showDeleteDialog(category);
          },
        );
      },
    );
  }

  void _showDeleteDialog(CategoryItem category) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (context) {
        return CategoryDeleteDialog(
          categoryName: category.name,
          transactionCount: 0,
          onConfirmDelete: () {
            setState(() {
              if (category.isExpense) {
                _expenseCategories.removeWhere((c) => c.id == category.id);
              } else {
                _incomeCategories.removeWhere((c) => c.id == category.id);
              }
            });

            _showToast('Kategori "${category.name}" berhasil dihapus');
          },
        );
      },
    );
  }

  void _addQuickCategory(String name, IconData icon, Color color) {
    final newCategory = CategoryItem(
      id: 'quick-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      icon: icon,
      color: color,
      isExpense: _isExpenseTab,
      isCustom: true,
    );

    setState(() {
      if (_isExpenseTab) {
        _expenseCategories.add(newCategory);
      } else {
        _incomeCategories.add(newCategory);
      }
    });

    _showToast('Kategori "$name" berhasil ditambahkan');
  }

  @override
  Widget build(BuildContext context) {
    final currentCategories = _isExpenseTab ? _expenseCategories : _incomeCategories;
    final isEmpty = currentCategories.isEmpty;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFFF1F5F9),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        body: Stack(
          children: [
            Column(
              children: [
                // 1. Header Baru (Gradasi Biru rounded-b-[28px])
                _buildHeader(context),

                // 2. Raised Content Panel (Menimpa Header sebesar 24px)
                Expanded(
                  child: Container(
                    transform: Matrix4.translationValues(0.0, -24.0, 0.0),
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                    ),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
                      child: _isLoading
                          ? const CategorySkeleton(key: ValueKey('skeleton'))
                          : Column(
                              key: const ValueKey('content'),
                              children: [
                                // Tactile Recessed Segmented Toggle Track
                                _buildSegmentedTabTrack(),

                                const SizedBox(height: 14),

                          // Instruction Badge (Jika tidak kosong)
                          if (!isEmpty) ...[
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.touch_app_rounded,
                                    size: 16,
                                    color: Color(0xFF004AC6),
                                  ),
                                  const SizedBox(width: 6),
                                  Flexible(
                                    child: Text(
                                      'Ketuk kategori untuk mengubah atau menghapus',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: const Color(0xFF64748B),
                                      ),
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Konten Kategori (Grid Matrix atau Empty State)
                          if (isEmpty)
                            CategoryEmptyState(
                              isExpense: _isExpenseTab,
                              onAddCategory: _openAddModal,
                              onAddQuickCategory: _addQuickCategory,
                            )
                          else ...[
                            // 4-Column Skeuomorphic Tile Matrix
                            _buildCategoryGrid(currentCategories),

                            const SizedBox(height: 18),

                            // Contextual Information Card: Tips Manajemen Anggaran
                            _buildBudgetTipsCard(),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Floating Toast Notification Pill
            if (_toastMessage != null)
              Positioned(
                top: MediaQuery.of(context).padding.top + 72,
                left: 20,
                right: 20,
                child: Center(
                  child: AnimatedOpacity(
                    opacity: _toastMessage != null ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 250),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF131B2E),
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33000000),
                            blurRadius: 16,
                            offset: Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                            color: Color(0xFF7FFC97),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              _toastMessage!,
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return TactileTimeHeaderWrapper(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 36),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Glassmorphic Back Button (44x44)
              PressableScale(
                onTap: () => Navigator.of(context).maybePop(),
                scaleFactor: 0.92,
                translateY: 2.0,
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
                      size: 22,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),

              // Title
              Text(
                'Kategori',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),

              // Spacer agar judul tetap presisi di tengah seimbang dengan tombol back (44x44)
              const SizedBox(width: 44, height: 44),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSegmentedTabTrack() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE2E7FF),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F131B2E),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Tab 1: Pengeluaran
          Expanded(
            child: PressableScale(
              onTap: () => setState(() => _isExpenseTab = true),
              scaleFactor: 0.96,
              translateY: 1.5,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  gradient: _isExpenseTab
                      ? const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF2563EB),
                            Color(0xFF004AC6),
                          ],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: _isExpenseTab
                      ? const [
                          BoxShadow(
                            color: Color(0x472563EB),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_downward_rounded,
                        size: 15,
                        color: _isExpenseTab ? Colors.white : const Color(0xFF434655),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Pengeluaran (${_expenseCategories.length})',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: _isExpenseTab ? FontWeight.w700 : FontWeight.w500,
                            color: _isExpenseTab ? Colors.white : const Color(0xFF434655),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Tab 2: Pemasukan
          Expanded(
            child: PressableScale(
              onTap: () => setState(() => _isExpenseTab = false),
              scaleFactor: 0.96,
              translateY: 1.5,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  gradient: !_isExpenseTab
                      ? const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF2563EB),
                            Color(0xFF004AC6),
                          ],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: !_isExpenseTab
                      ? const [
                          BoxShadow(
                            color: Color(0x472563EB),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.arrow_upward_rounded,
                        size: 15,
                        color: !_isExpenseTab ? Colors.white : const Color(0xFF434655),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Pemasukan (${_incomeCategories.length})',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 12.5,
                            fontWeight: !_isExpenseTab ? FontWeight.w700 : FontWeight.w500,
                            color: !_isExpenseTab ? Colors.white : const Color(0xFF434655),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid(List<CategoryItem> categories) {
    // 4 Kolom: items kategori + 1 tombol tambah di akhir
    final totalCount = categories.length + 1;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 0.88,
      ),
      itemCount: totalCount,
      itemBuilder: (context, index) {
        if (index == categories.length) {
          // Tombol Tambah di akhir grid
          return CategoryAddTile(
            onTap: _openAddModal,
          );
        }

        final cat = categories[index];
        return CategoryGridItem(
          category: cat,
          onTap: () => _handleCategoryClick(cat),
        );
      },
    );
  }

  Widget _buildBudgetTipsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F2563EB),
            blurRadius: 14,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Color(0x0A0F172A),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lamp Icon Badge
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF7FFC97),
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x26006329),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: const Center(
              child: Icon(
                Icons.lightbulb_rounded,
                size: 22,
                color: Color(0xFF002109),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // Teks Tips
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tips Manajemen Anggaran',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF131B2E),
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Kelompokkan pengeluaran harian maksimal ke dalam 8 kategori inti agar pelacakan pengeluaran bulanan tetap fokus dan rapi.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
