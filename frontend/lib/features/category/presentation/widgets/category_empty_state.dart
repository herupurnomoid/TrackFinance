import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'category_3d_icon.dart';

/// Centerpiece Empty State Illustration & Interactive Showcase
/// Sesuai referensi HTML 4 Modern Tactile Finance
class CategoryEmptyState extends StatelessWidget {
  final bool isExpense;
  final VoidCallback onAddCategory;
  final Function(String name, IconData icon) onAddQuickCategory;

  const CategoryEmptyState({
    super.key,
    required this.isExpense,
    required this.onAddCategory,
    required this.onAddQuickCategory,
  });

  @override
  Widget build(BuildContext context) {
    final title = isExpense
        ? 'Belum ada kategori pengeluaran'
        : 'Belum ada kategori pemasukan';
    final description = isExpense
        ? 'Tambahkan kategori agar pencatatan pengeluaran harian Anda lebih terorganisir dan rapi'
        : 'Tambahkan kategori agar pencatatan arus masuk dana Anda lebih terorganisir dan rapi';

    final badgeColor = isExpense ? const Color(0xFFDC2626) : const Color(0xFF007F36);
    final badgeIcon = isExpense ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;

    // Starter suggestions
    final quickSuggestions = isExpense
        ? const [
            (name: 'Makanan & Minuman', icon: Icons.restaurant_rounded),
            (name: 'Transportasi', icon: Icons.directions_car_rounded),
            (name: 'Belanja', icon: Icons.shopping_bag_rounded),
          ]
        : const [
            (name: 'Gaji Pokok', icon: Icons.payments_rounded),
            (name: 'Investasi', icon: Icons.trending_up_rounded),
            (name: 'Bonus', icon: Icons.card_giftcard_rounded),
          ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Ikon 3D Utama Bebas Batasan Tanpa Kontainer Pembatas
          Stack(
            clipBehavior: Clip.none,
            children: [
              Category3DIcon(
                isExpense: isExpense,
                size: 92,
              ),

              // Floating Trend Indicator Badge
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: badgeColor.withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      badgeIcon,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 2. Typography Block
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              description,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF64748B),
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 24),

          // 3. Tactile CTA Button: Tambah Kategori
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onAddCategory,
              borderRadius: BorderRadius.circular(16),
              child: Ink(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 13),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF2563EB),
                      Color(0xFF004AC6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x592563EB),
                      blurRadius: 18,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.add_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Tambah Kategori',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 36),

          // 4. Suggested Starter Chips Carousel / Sparkle Hint
          Text(
            'SARAN KATEGORI CEPAT',
            style: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: const Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: quickSuggestions.map((item) {
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => onAddQuickCategory(item.name, item.icon),
                  borderRadius: BorderRadius.circular(999),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: const Color(0xFFE2E8F0),
                        width: 1.0,
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Category3DIcon(
                          name: item.name,
                          icon: item.icon,
                          isExpense: isExpense,
                          size: 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          item.name,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
