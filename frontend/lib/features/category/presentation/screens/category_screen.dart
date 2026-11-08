import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/services/auth_service_provider.dart';
import '../../../../core/widgets/animations.dart';
import '../../../../core/widgets/tactile_swipe_detector.dart';
import '../../data/category_model.dart';
import '../../data/category_repository.dart';
import '../widgets/add_category_modal.dart';
import '../widgets/category_delete_dialog.dart';
import '../widgets/category_empty_state.dart';
import '../widgets/category_grid_item.dart';
import '../widgets/category_skeleton.dart';
import '../widgets/category_tab_bar.dart';
import '../../../dashboard/presentation/widgets/tactile_time_header_wrapper.dart';

/// Halaman Manajemen Kategori Modern Tactile Finance
/// Mendukung 4-Column Skeuomorphic Tile Matrix, Slide-up Edit Sheet,
/// Tactile Delete Confirmation Dialog, dan Centerpiece Empty State.
class CategoryScreen extends StatefulWidget {
  final UserProfile? user;
  final bool? isLoading;
  final CategoryRepository? repository;

  const CategoryScreen({
    super.key,
    this.user,
    this.isLoading,
    this.repository,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  late bool _isLoading;
  late CategoryRepository _repository;
  bool _isExpenseTab = true;

  // Kategori bawaan terisi sejak pertama kali pengguna masuk
  List<CategoryItem> _expenseCategories = List.from(CategoryRepository.inMemoryExpenseCategories);
  List<CategoryItem> _incomeCategories = List.from(CategoryRepository.inMemoryIncomeCategories);

  // Pesan Toast Floating Feedback
  String? _toastMessage;
  Timer? _toastTimer;

  String? get _uid =>
      widget.user?.uid ?? AuthServiceProvider.instance.currentUser?.uid;

  @override
  void initState() {
    super.initState();
    _isLoading = widget.isLoading ?? false;
    _repository = widget.repository ?? CategoryRepository.instance;

    final uid = _uid;
    if (uid != null && uid.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initAfterTransition();
      });
    }
  }

  void _initAfterTransition() {
    if (!mounted) return;
    final animation = ModalRoute.of(context)?.animation;
    if (animation != null && !animation.isCompleted) {
      void listener(AnimationStatus status) {
        if (status == AnimationStatus.completed) {
          animation.removeStatusListener(listener);
          _seedCategories();
        }
      }
      animation.addStatusListener(listener);
    } else {
      _seedCategories();
    }
  }

  void _seedCategories() {
    final uid = _uid;
    if (uid != null && uid.isNotEmpty) {
      _repository.seedDefaultCategoriesIfEmpty(uid);
    }
  }

  @override
  void didUpdateWidget(covariant CategoryScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != null && widget.isLoading != _isLoading) {
      setState(() {
        _isLoading = widget.isLoading!;
      });
    }
    if (widget.repository != null && widget.repository != _repository) {
      _repository = widget.repository!;
    }
    if (_uid != oldWidget.user?.uid) {
      final uid = _uid;
      if (uid != null && uid.isNotEmpty) {
        _repository.seedDefaultCategoriesIfEmpty(uid);
      }
    }
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    super.dispose();
  }

  void _showToast(String message) {
    _toastTimer?.cancel();
    setState(() {
      _toastMessage = message;
    });

    _toastTimer = Timer(const Duration(milliseconds: 2500), () {
      if (mounted && _toastMessage == message) {
        setState(() {
          _toastMessage = null;
        });
      }
    });
  }

  Future<void> _handleRefresh() async {
    HapticFeedback.lightImpact();
    setState(() => _isLoading = true);
    final uid = _uid;
    if (uid != null && uid.isNotEmpty) {
      try {
        final items = await _repository.getCategories(uid);
        if (items.isNotEmpty && mounted) {
          setState(() {
            _expenseCategories = items.where((c) => c.isExpense).toList();
            _incomeCategories = items.where((c) => !c.isExpense).toList();
          });
        }
      } catch (e) {
        debugPrint('CategoryScreen refresh error: $e');
      }
    }
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) {
      setState(() => _isLoading = false);
    }
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
          onSave: (name, icon, isExpense) async {
            final uid = _uid;
            final newCategory = CategoryItem(
              id: 'cat-${DateTime.now().millisecondsSinceEpoch}',
              name: name,
              icon: icon,
              isExpense: isExpense,
              isCustom: true,
              order: (isExpense ? _expenseCategories.length : _incomeCategories.length) + 1,
            );

            if (uid != null && uid.isNotEmpty) {
              await _repository.addCategory(uid, newCategory);
            } else {
              setState(() {
                if (isExpense) {
                  CategoryRepository.inMemoryExpenseCategories.insert(
                    CategoryRepository.inMemoryExpenseCategories.isEmpty ? 0 : CategoryRepository.inMemoryExpenseCategories.length - 1,
                    newCategory,
                  );
                  _expenseCategories = List.from(CategoryRepository.inMemoryExpenseCategories);
                  _isExpenseTab = true;
                } else {
                  CategoryRepository.inMemoryIncomeCategories.insert(
                    CategoryRepository.inMemoryIncomeCategories.isEmpty ? 0 : CategoryRepository.inMemoryIncomeCategories.length - 1,
                    newCategory,
                  );
                  _incomeCategories = List.from(CategoryRepository.inMemoryIncomeCategories);
                  _isExpenseTab = false;
                }
              });
            }

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
          onSave: (name, icon, isExpense) async {
            final updated = category.copyWith(
              name: name,
              icon: icon,
              isExpense: isExpense,
            );

            final uid = _uid;
            if (uid != null && uid.isNotEmpty) {
              await _repository.updateCategory(uid, updated);
            } else {
              setState(() {
                if (isExpense) {
                  final index = CategoryRepository.inMemoryExpenseCategories.indexWhere((c) => c.id == category.id);
                  if (index != -1) {
                    CategoryRepository.inMemoryExpenseCategories[index] = updated;
                  }
                  _expenseCategories = List.from(CategoryRepository.inMemoryExpenseCategories);
                } else {
                  final index = CategoryRepository.inMemoryIncomeCategories.indexWhere((c) => c.id == category.id);
                  if (index != -1) {
                    CategoryRepository.inMemoryIncomeCategories[index] = updated;
                  }
                  _incomeCategories = List.from(CategoryRepository.inMemoryIncomeCategories);
                }
              });
            }

            _showToast('Perubahan kategori disimpan');
          },
          onDelete: () {
            _showDeleteDialog(category);
          },
        );
      },
    );
  }

  void _showDeleteDialog(CategoryItem category) async {
    final uid = _uid;
    int txCount = 0;
    if (uid != null && uid.isNotEmpty) {
      try {
        txCount = await _repository.countTransactionsByCategory(uid, category.id);
      } catch (_) {
        txCount = 0;
      }
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (context) {
        return CategoryDeleteDialog(
          categoryName: category.name,
          transactionCount: txCount,
          onConfirmDelete: () async {
            try {
              if (uid != null && uid.isNotEmpty) {
                if (txCount > 0) {
                  final fallbackId = category.isExpense ? 'exp-8' : 'inc-6';
                  await _repository.migrateTransactionsCategory(
                    uid,
                    fromCategoryId: category.id,
                    toCategoryId: fallbackId,
                  );
                }
                await _repository.deleteCategory(uid, category.id);
              } else {
                setState(() {
                  if (category.isExpense) {
                    CategoryRepository.inMemoryExpenseCategories.removeWhere((c) => c.id == category.id);
                    _expenseCategories = List.from(CategoryRepository.inMemoryExpenseCategories);
                  } else {
                    CategoryRepository.inMemoryIncomeCategories.removeWhere((c) => c.id == category.id);
                    _incomeCategories = List.from(CategoryRepository.inMemoryIncomeCategories);
                  }
                });
              }

              _showToast('Kategori "${category.name}" berhasil dihapus');
            } catch (e) {
              _showToast('Gagal menghapus kategori: $e');
            }
          },
        );
      },
    );
  }

  void _addQuickCategory(String name, IconData icon) async {
    final uid = _uid;
    final newCategory = CategoryItem(
      id: 'quick-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      icon: icon,
      isExpense: _isExpenseTab,
      isCustom: true,
      order: (_isExpenseTab ? _expenseCategories.length : _incomeCategories.length) + 1,
    );

    if (uid != null && uid.isNotEmpty) {
      await _repository.addCategory(uid, newCategory);
    } else {
      setState(() {
        if (_isExpenseTab) {
          CategoryRepository.inMemoryExpenseCategories.add(newCategory);
          _expenseCategories = List.from(CategoryRepository.inMemoryExpenseCategories);
        } else {
          CategoryRepository.inMemoryIncomeCategories.add(newCategory);
          _incomeCategories = List.from(CategoryRepository.inMemoryIncomeCategories);
        }
      });
    }

    _showToast('Kategori "$name" berhasil ditambahkan');
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFFF1F5F9),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF1F5F9),
        body: TactileSwipeDetector(
          behavior: HitTestBehavior.translucent,
          onSwipeLeft: () {
            if (_isExpenseTab) {
              setState(() => _isExpenseTab = false);
            }
          },
          onSwipeRight: () {
            if (!_isExpenseTab) {
              setState(() => _isExpenseTab = true);
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              Column(
                children: [
                  // 1. Header Baru (Gradasi Biru rounded-b-[28px])
                  _buildHeader(context),

                  // 2. Main Content Canvas (seperti Halaman Profil)
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _handleRefresh,
                      color: const Color(0xFF2563EB),
                      backgroundColor: Colors.white,
                      child: SizedBox.expand(
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: EdgeInsets.fromLTRB(
                            16,
                            20,
                            16,
                            MediaQuery.of(context).padding.bottom + 64,
                          ),
                          child: _isLoading
                            ? const CategorySkeleton(key: ValueKey('skeleton'))
                            : StreamBuilder<List<CategoryItem>>(
                                stream: (_uid != null && _uid!.isNotEmpty)
                                    ? _repository.getCategoriesStream(_uid!)
                                    : null,
                                initialData: [
                                  ..._expenseCategories,
                                  ..._incomeCategories,
                                ],
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                                    return const CategorySkeleton(key: ValueKey('skeleton'));
                                  }

                                  if (snapshot.hasData &&
                                      snapshot.data != null &&
                                      _uid != null &&
                                      _uid!.isNotEmpty) {
                                    final allDocs = snapshot.data!;
                                    _expenseCategories = allDocs.where((c) => c.isExpense).toList();
                                    _incomeCategories = allDocs.where((c) => !c.isExpense).toList();
                                  }

                                  return Column(
                                    key: const ValueKey('content'),
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // 1. Segmented Switcher Control (Pengeluaran vs Pemasukan)
                                      _buildSegmentedTabTrack(),

                                      const SizedBox(height: 14),

                                      // 2. Konten Tab (Pengeluaran atau Pemasukan)
                                      AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 250),
                                        child: _isExpenseTab
                                            ? RepaintBoundary(
                                                child: _buildTabContent(
                                                  categories: _expenseCategories,
                                                  isExpense: true,
                                                ),
                                              )
                                            : RepaintBoundary(
                                                child: _buildTabContent(
                                                  categories: _incomeCategories,
                                                  isExpense: false,
                                                ),
                                              ),
                                      ),
                                    ],
                                  );
                                },
                              ),
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
    ),
  );
}

  Widget _buildHeader(BuildContext context) {
    return TactileTimeHeaderWrapper(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
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
    return CategoryTabBar(
      isExpenseSelected: _isExpenseTab,
      expenseCount: _expenseCategories.length,
      incomeCount: _incomeCategories.length,
      onTabChanged: (isExpense) {
        setState(() => _isExpenseTab = isExpense);
      },
    );
  }

  Widget _buildTabContent({
    required List<CategoryItem> categories,
    required bool isExpense,
  }) {
    if (categories.isEmpty) {
      return CategoryEmptyState(
        key: ValueKey('empty_$isExpense'),
        isExpense: isExpense,
        onAddCategory: _openAddModal,
        onAddQuickCategory: _addQuickCategory,
      );
    }

    // 4-Column Skeuomorphic Tile Matrix
    return KeyedSubtree(
      key: ValueKey('grid_$isExpense'),
      child: _buildCategoryGrid(categories),
    );
  }

  Widget _buildCategoryGrid(List<CategoryItem> categories) {
    // 4 Kolom: items kategori + 1 tombol tambah di akhir
    final totalCount = categories.length + 1;

    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      clipBehavior: Clip.none,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 18,
        crossAxisSpacing: 8,
        mainAxisExtent: 104,
      ),
      itemCount: totalCount,
      itemBuilder: (context, index) {
        if (index == categories.length) {
          // Tombol Tambah di akhir grid
          return RepaintBoundary(
            child: CategoryAddTile(
              onTap: _openAddModal,
            ),
          );
        }

        final cat = categories[index];
        return RepaintBoundary(
          child: CategoryGridItem(
            category: cat,
            onTap: () => _handleCategoryClick(cat),
          ),
        );
      },
    );
  }
}
