import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/animations.dart';
import '../../data/category_model.dart';

/// Bottom Sheet Interaktif Tambah & Edit Kategori
/// Sesuai referensi HTML 2 Modern Tactile Finance
class AddCategoryModal extends StatefulWidget {
  final CategoryItem? categoryToEdit;
  final bool initialIsExpense;
  final List<String> existingNames;
  final Function(String name, IconData icon, Color color, bool isExpense) onSave;
  final VoidCallback? onDelete;

  const AddCategoryModal({
    super.key,
    this.categoryToEdit,
    required this.initialIsExpense,
    this.existingNames = const [],
    required this.onSave,
    this.onDelete,
  });

  @override
  State<AddCategoryModal> createState() => _AddCategoryModalState();
}

class _AddCategoryModalState extends State<AddCategoryModal> {
  late bool _isExpense;
  late TextEditingController _nameController;
  late IconData _selectedIcon;
  late Color _selectedColor;
  String? _errorMessage;

  // 18 Ikon Populer Keuangan sesuai desain
  final List<IconData> _availableIcons = const [
    Icons.restaurant_rounded,
    Icons.directions_car_rounded,
    Icons.shopping_bag_rounded,
    Icons.receipt_long_rounded,
    Icons.medical_services_rounded,
    Icons.sports_esports_rounded,
    Icons.school_rounded,
    Icons.home_rounded,
    Icons.account_balance_wallet_rounded,
    Icons.trending_up_rounded,
    Icons.savings_rounded,
    Icons.card_giftcard_rounded,
    Icons.flight_rounded,
    Icons.local_cafe_rounded,
    Icons.fitness_center_rounded,
    Icons.pets_rounded,
    Icons.devices_rounded,
    Icons.category_rounded,
  ];

  // 8 Pilihan Warna Tactile Keuangan Modern
  final List<({Color color, Color bgTint, String name})> _colorOptions = const [
    (color: Color(0xFF2563EB), bgTint: Color(0xFFDBEAFE), name: 'Biru'),
    (color: Color(0xFF16A34A), bgTint: Color(0xFFDCFCE7), name: 'Hijau'),
    (color: Color(0xFFDC2626), bgTint: Color(0xFFFFDAD6), name: 'Merah'),
    (color: Color(0xFFEA580C), bgTint: Color(0xFFFFEDD5), name: 'Oranye'),
    (color: Color(0xFF9333EA), bgTint: Color(0xFFF3E8FF), name: 'Ungu'),
    (color: Color(0xFF0D9488), bgTint: Color(0xFFCCFBF1), name: 'Teal'),
    (color: Color(0xFFE11D48), bgTint: Color(0xFFFFE4E6), name: 'Pink'),
    (color: Color(0xFF1E40AF), bgTint: Color(0xFFDDE1FF), name: 'Biru Tua'),
  ];

  bool get _isEditMode => widget.categoryToEdit != null;

  @override
  void initState() {
    super.initState();
    final edit = widget.categoryToEdit;
    if (edit != null) {
      _isExpense = edit.isExpense;
      _nameController = TextEditingController(text: edit.name);
      _selectedIcon = edit.icon;
      _selectedColor = edit.color;
    } else {
      _isExpense = widget.initialIsExpense;
      _nameController = TextEditingController();
      _selectedIcon = _availableIcons.first;
      _selectedColor = _isExpense ? const Color(0xFFDC2626) : const Color(0xFF16A34A);
    }

    _nameController.addListener(_validateName);
  }

  void _validateName() {
    final text = _nameController.text.trim();
    if (text.isEmpty) {
      if (_errorMessage != null) setState(() => _errorMessage = null);
      return;
    }

    final lower = text.toLowerCase();
    final isDuplicate = widget.existingNames.any((n) {
      if (_isEditMode && n.toLowerCase() == widget.categoryToEdit!.name.toLowerCase()) {
        return false;
      }
      return n.toLowerCase() == lower;
    });

    if (isDuplicate) {
      if (_errorMessage != 'Nama sudah dipakai. Gunakan nama yang berbeda.') {
        setState(() => _errorMessage = 'Nama sudah dipakai. Gunakan nama yang berbeda.');
      }
    } else {
      if (_errorMessage != null) {
        setState(() => _errorMessage = null);
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Color _getBgTint(Color color) {
    for (final opt in _colorOptions) {
      if (opt.color.toARGB32() == color.toARGB32()) return opt.bgTint;
    }
    return const Color(0xFFDBEAFE);
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _errorMessage = 'Nama kategori tidak boleh kosong');
      return;
    }
    if (_errorMessage != null) return;

    widget.onSave(name, _selectedIcon, _selectedColor, _isExpense);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final currentText = _nameController.text.trim();
    final previewDisplayName = currentText.isNotEmpty ? currentText : 'Nama Kategori';

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.90,
      ),
      padding: EdgeInsets.only(
        top: 12,
        left: 20,
        right: 20,
        bottom: bottomInset > 0
            ? bottomInset + 16
            : MediaQuery.of(context).padding.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x330F172A),
            blurRadius: 32,
            offset: Offset(0, -8),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Drag Handle Bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 12),

            // Sheet Header Simetris & Terpusat
            Row(
              children: [
                const SizedBox(width: 40, height: 40),
                Expanded(
                  child: Text(
                    _isEditMode ? 'Edit Kategori' : 'Tambah Kategori',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0F172A),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                PressableScale(
                  onTap: () => Navigator.of(context).pop(),
                  scaleFactor: 0.90,
                  translateY: 1.5,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Live Preview Card (Tactile Squircle 88x88)
            Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white,
                        Color(0xFFF8FAFC),
                      ],
                    ),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _selectedColor.withValues(alpha: 0.20),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                      const BoxShadow(
                        color: Color(0x0A0F172A),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: _getBgTint(_selectedColor),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: _selectedColor.withValues(alpha: 0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Icon(
                            _selectedIcon,
                            size: 24,
                            color: _selectedColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          previewDisplayName,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: _errorMessage != null
                                ? const Color(0xFFBA1A1A)
                                : const Color(0xFF0F172A),
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Field 1: Nama Kategori
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Nama kategori',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      '${_nameController.text.length}/20',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _errorMessage != null
                            ? const Color(0xFFBA1A1A)
                            : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: _errorMessage != null
                        ? const Color(0xFFFEF2F2)
                        : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _errorMessage != null
                          ? const Color(0xFFBA1A1A)
                          : const Color(0xFFE2E8F0),
                      width: 1.0,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0F0F172A),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          maxLength: 20,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF0F172A),
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none,
                            counterText: '',
                            hintText: 'Masukkan nama kategori',
                            hintStyle: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      if (_errorMessage != null)
                        const Icon(
                          Icons.error_outline_rounded,
                          size: 20,
                          color: Color(0xFFBA1A1A),
                        ),
                    ],
                  ),
                ),
                if (_errorMessage != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        size: 14,
                        color: Color(0xFFBA1A1A),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFBA1A1A),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),

            const SizedBox(height: 16),

            // Field 2: Jenis Transaksi (Segmented Toggle)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jenis transaksi',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    // Tombol 3D Soft Skeuomorphic: Pengeluaran
                    Expanded(
                      child: GestureDetector(
                        onTap: _isEditMode
                            ? null
                            : () => setState(() {
                                  _isExpense = true;
                                  if (_selectedColor == const Color(0xFF16A34A)) {
                                    _selectedColor = const Color(0xFFDC2626);
                                  }
                                }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: _isExpense
                                ? const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.white,
                                      Color(0xFFFFF1F2),
                                    ],
                                  )
                                : const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0xFFF8FAFC),
                                      Color(0xFFF1F5F9),
                                    ],
                                  ),
                            border: Border.all(
                              color: _isExpense
                                  ? const Color(0xFFFDA4AF)
                                  : const Color(0xFFE2E8F0),
                              width: _isExpense ? 1.5 : 1.0,
                            ),
                            boxShadow: _isExpense
                                ? [
                                    // Specular Highlight atas
                                    BoxShadow(
                                      color: Colors.white.withValues(alpha: 0.95),
                                      blurRadius: 2,
                                      offset: const Offset(0, -1.5),
                                    ),
                                    // 3D Depth Shadow lembut
                                    BoxShadow(
                                      color: const Color(0xFFDC2626).withValues(alpha: 0.22),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                    BoxShadow(
                                      color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                                      blurRadius: 3,
                                      offset: const Offset(0, 1),
                                    ),
                                  ]
                                : [
                                    BoxShadow(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      blurRadius: 2,
                                      offset: const Offset(0, -1),
                                    ),
                                    BoxShadow(
                                      color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  gradient: _isExpense
                                      ? const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFFFFE4E6),
                                            Color(0xFFFFCDD2),
                                          ],
                                        )
                                      : null,
                                  color: _isExpense ? null : const Color(0xFFE2E8F0),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                  boxShadow: _isExpense
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFFDC2626).withValues(alpha: 0.25),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.arrow_downward_rounded,
                                    size: 15,
                                    color: _isExpense
                                        ? const Color(0xFFDC2626)
                                        : const Color(0xFF94A3B8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Pengeluaran',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5,
                                  fontWeight: _isExpense
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  color: _isExpense
                                      ? const Color(0xFFDC2626)
                                      : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Tombol 3D Soft Skeuomorphic: Pemasukan
                    Expanded(
                      child: GestureDetector(
                        onTap: _isEditMode
                            ? null
                            : () => setState(() {
                                  _isExpense = false;
                                  if (_selectedColor == const Color(0xFFDC2626)) {
                                    _selectedColor = const Color(0xFF16A34A);
                                  }
                                }),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          height: 56,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: !_isExpense
                                ? const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.white,
                                      Color(0xFFF0FDF4),
                                    ],
                                  )
                                : const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Color(0xFFF8FAFC),
                                      Color(0xFFF1F5F9),
                                    ],
                                  ),
                            border: Border.all(
                              color: !_isExpense
                                  ? const Color(0xFFA7F3D0)
                                  : const Color(0xFFE2E8F0),
                              width: !_isExpense ? 1.5 : 1.0,
                            ),
                            boxShadow: !_isExpense
                                ? [
                                    // Specular Highlight atas
                                    BoxShadow(
                                      color: Colors.white.withValues(alpha: 0.95),
                                      blurRadius: 2,
                                      offset: const Offset(0, -1.5),
                                    ),
                                    // 3D Depth Shadow lembut
                                    BoxShadow(
                                      color: const Color(0xFF16A34A).withValues(alpha: 0.22),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                    BoxShadow(
                                      color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                                      blurRadius: 3,
                                      offset: const Offset(0, 1),
                                    ),
                                  ]
                                : [
                                    BoxShadow(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      blurRadius: 2,
                                      offset: const Offset(0, -1),
                                    ),
                                    BoxShadow(
                                      color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  gradient: !_isExpense
                                      ? const LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            Color(0xFFDCFCE7),
                                            Color(0xFFBBF7D0),
                                          ],
                                        )
                                      : null,
                                  color: !_isExpense ? null : const Color(0xFFE2E8F0),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                  boxShadow: !_isExpense
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF16A34A).withValues(alpha: 0.25),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.arrow_upward_rounded,
                                    size: 15,
                                    color: !_isExpense
                                        ? const Color(0xFF16A34A)
                                        : const Color(0xFF94A3B8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Pemasukan',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 13.5,
                                  fontWeight: !_isExpense
                                      ? FontWeight.w700
                                      : FontWeight.w600,
                                  color: !_isExpense
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_isEditMode) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Jenis transaksi tidak dapat diubah setelah kategori dibuat.',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 11,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 16),

            // Field 3: Pilih Ikon (Grid 6 Kolom, 18 Tiles)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pilih ikon',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: _availableIcons.length,
                    itemBuilder: (context, index) {
                      final icon = _availableIcons[index];
                      final isSelected = _selectedIcon == icon;

                      return InkWell(
                        onTap: () => setState(() => _selectedIcon = icon),
                        borderRadius: BorderRadius.circular(10),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          decoration: BoxDecoration(
                            gradient: isSelected
                                ? LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.white,
                                      _getBgTint(_selectedColor),
                                    ],
                                  )
                                : const LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.white,
                                      Color(0xFFF8FAFC),
                                    ],
                                  ),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? _selectedColor
                                  : const Color(0xFFE2E8F0),
                              width: isSelected ? 1.5 : 1.0,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.white.withValues(alpha: 0.9),
                                      blurRadius: 2,
                                      offset: const Offset(0, -1),
                                    ),
                                    BoxShadow(
                                      color: _selectedColor.withValues(alpha: 0.28),
                                      blurRadius: 8,
                                      offset: const Offset(0, 3),
                                    ),
                                  ]
                                : const [
                                    BoxShadow(
                                      color: Colors.white,
                                      blurRadius: 1,
                                      offset: Offset(0, -1),
                                    ),
                                    BoxShadow(
                                      color: Color(0x0A0F172A),
                                      blurRadius: 3,
                                      offset: Offset(0, 1.5),
                                    ),
                                  ],
                          ),
                          child: Center(
                            child: Icon(
                              icon,
                              size: 20,
                              color: isSelected
                                  ? _selectedColor
                                  : const Color(0xFF475569),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Field 4: Warna Ikon (8 Lingkaran Warna Tactile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Warna ikon',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _colorOptions.map((opt) {
                    final isSelected = _selectedColor.toARGB32() == opt.color.toARGB32();
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = opt.color),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: opt.color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(color: Colors.white, width: 2)
                              : null,
                          boxShadow: [
                            BoxShadow(
                              color: opt.color.withValues(alpha: isSelected ? 0.45 : 0.20),
                              blurRadius: isSelected ? 8 : 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: isSelected
                            ? const Center(
                                child: Icon(
                                  Icons.check_rounded,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Action Buttons Row
            Row(
              children: [
                // Tombol Hapus (Hanya jika mode edit dan bukan kategori locked)
                if (_isEditMode && !(widget.categoryToEdit?.isLocked ?? false) && widget.onDelete != null) ...[
                  Expanded(
                    flex: 1,
                    child: PressableScale(
                      onTap: () {
                        Navigator.of(context).pop();
                        widget.onDelete!();
                      },
                      scaleFactor: 0.95,
                      translateY: 2.0,
                      child: Container(
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white,
                              Color(0xFFFFF1F2),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFFFDA4AF),
                            width: 1.2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.95),
                              blurRadius: 2,
                              offset: const Offset(0, -1.5),
                            ),
                            BoxShadow(
                              color: const Color(0xFFDC2626).withValues(alpha: 0.20),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                            BoxShadow(
                              color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.delete_outline_rounded,
                              size: 18,
                              color: Color(0xFFDC2626),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Hapus',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFFDC2626),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],

                // Tombol 3D Soft Skeuomorphic: Simpan Kategori
                Expanded(
                  flex: 2,
                  child: PressableScale(
                    onTap: _submit,
                    scaleFactor: 0.95,
                    translateY: 2.0,
                    child: Container(
                      height: 54,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF3B82F6),
                            Color(0xFF2563EB),
                            Color(0xFF1D4ED8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: const Color(0xFF93C5FD).withValues(alpha: 0.70),
                          width: 1.2,
                        ),
                        boxShadow: [
                          // Specular Highlight atas
                          BoxShadow(
                            color: Colors.white.withValues(alpha: 0.40),
                            blurRadius: 2,
                            offset: const Offset(0, -1.5),
                          ),
                          // 3D Depth Shadow kaya
                          BoxShadow(
                            color: const Color(0xFF1D4ED8).withValues(alpha: 0.38),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                          // Ambient Base Shadow
                          BoxShadow(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.12),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withValues(alpha: 0.30),
                                  Colors.white.withValues(alpha: 0.10),
                                ],
                              ),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.45),
                                width: 1.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF1E3A8A).withValues(alpha: 0.30),
                                  blurRadius: 3,
                                  offset: const Offset(0, 1),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isEditMode ? 'Simpan Perubahan' : 'Simpan Kategori',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              letterSpacing: 0.2,
                              shadows: const [
                                Shadow(
                                  color: Color(0x661E3A8A),
                                  blurRadius: 3,
                                  offset: Offset(0, 1.5),
                                ),
                              ],
                            ),
                          ),
                        ],
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
}
