import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

class AddCategoryModal extends StatefulWidget {
  final bool initialIsExpense;
  final Function(String name, IconData icon, bool isExpense) onSave;

  const AddCategoryModal({
    super.key,
    required this.initialIsExpense,
    required this.onSave,
  });

  @override
  State<AddCategoryModal> createState() => _AddCategoryModalState();
}

class _AddCategoryModalState extends State<AddCategoryModal> {
  late bool _isExpense;
  final TextEditingController _nameController = TextEditingController();
  IconData _selectedIcon = Icons.local_cafe_rounded;

  final List<IconData> _availableIcons = const [
    Icons.local_cafe_rounded,
    Icons.shopping_cart_rounded,
    Icons.directions_car_rounded,
    Icons.theaters_rounded,
    Icons.sports_esports_rounded,
    Icons.fitness_center_rounded,
    Icons.flight_rounded,
    Icons.menu_book_rounded,
    Icons.medical_services_rounded,
    Icons.music_note_rounded,
    Icons.pets_rounded,
    Icons.work_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _isExpense = widget.initialIsExpense;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan masukkan nama kategori'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    widget.onSave(name, _selectedIcon, _isExpense);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pull bar
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tambah Kategori Baru',
                  style: AppTextStyles.headlineMd.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: AppColors.surfaceContainerLow,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Type Switch: Pengeluaran vs Pemasukan
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTypeToggle(
                      title: 'Pengeluaran',
                      isSelected: _isExpense,
                      onTap: () => setState(() => _isExpense = true),
                    ),
                  ),
                  Expanded(
                    child: _buildTypeToggle(
                      title: 'Pemasukan',
                      isSelected: !_isExpense,
                      onTap: () => setState(() => _isExpense = false),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Input: Nama Kategori
            Text(
              'NAMA KATEGORI',
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.secondary,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(99),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0D2C3A).withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.edit_rounded,
                    size: 20,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _nameController,
                      style: AppTextStyles.bodyMd,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Contoh: Langganan Streaming',
                        hintStyle: TextStyle(
                          color: AppColors.outline,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Icon Picker Grid
            Text(
              'PILIH IKON',
              style: AppTextStyles.labelSm.copyWith(
                color: AppColors.secondary,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.1,
              ),
              itemCount: _availableIcons.length,
              itemBuilder: (context, index) {
                final icon = _availableIcons[index];
                final isSelected = icon == _selectedIcon;

                return InkWell(
                  onTap: () => setState(() => _selectedIcon = icon),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryContainer
                          : AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? AppColors.primaryContainer.withValues(alpha: 0.45)
                              : AppColors.clayShadow.withValues(alpha: 0.12),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        icon,
                        size: 24,
                        color: isSelected ? Colors.white : AppColors.secondary,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Action Buttons: Batal & Simpan
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: TextButton(
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(99),
                      ),
                      backgroundColor: AppColors.surfaceContainerLow,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Batal',
                      style: AppTextStyles.labelLg.copyWith(
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(99),
                      ),
                      backgroundColor: AppColors.primaryContainer,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      shadowColor: AppColors.primaryContainer.withValues(alpha: 0.5),
                    ),
                    onPressed: _handleSave,
                    child: Text(
                      'Simpan Kategori',
                      style: AppTextStyles.labelLg.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeToggle({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(99),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(99),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryContainer.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: AppTextStyles.labelMd.copyWith(
            color: isSelected ? Colors.white : AppColors.secondary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
