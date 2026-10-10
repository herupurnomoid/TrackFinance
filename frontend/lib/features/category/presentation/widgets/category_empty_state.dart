import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centerpiece Empty State Illustration & Interactive Showcase
/// Sesuai referensi HTML 4 Modern Tactile Finance
class CategoryEmptyState extends StatelessWidget {
  final bool isExpense;
  final VoidCallback onAddCategory;
  final Function(String name, IconData icon, Color color) onAddQuickCategory;

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
    final innerWellColor = isExpense
        ? const Color(0xFFFFDAD6).withValues(alpha: 0.6)
        : const Color(0xFFC7FFCA).withValues(alpha: 0.6);
    final iconColor = isExpense ? const Color(0xFFBA1A1A) : const Color(0xFF007F36);

    // Starter suggestions
    final quickSuggestions = isExpense
        ? [
            (name: 'Makanan & Minuman', icon: Icons.restaurant_rounded, color: const Color(0xFFDC2626)),
            (name: 'Transportasi', icon: Icons.directions_car_rounded, color: const Color(0xFF2563EB)),
            (name: 'Belanja', icon: Icons.shopping_bag_rounded, color: const Color(0xFF16A34A)),
          ]
        : [
            (name: 'Gaji Pokok', icon: Icons.payments_rounded, color: const Color(0xFF16A34A)),
            (name: 'Investasi', icon: Icons.trending_up_rounded, color: const Color(0xFF2563EB)),
            (name: 'Bonus', icon: Icons.card_giftcard_rounded, color: const Color(0xFF1E40AF)),
          ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 1. Large Raised Tactile Squircle Tile (104x104)
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
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
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1A004AC6),
                      blurRadius: 24,
                      offset: Offset(0, 12),
                    ),
                    BoxShadow(
                      color: Color(0x0A131B2E),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  // Inner glow well (56x56)
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: innerWellColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        Icons.account_balance_wallet_rounded,
                        size: 32,
                        color: iconColor,
                      ),
                    ),
                  ),
                ),
              ),

              // Floating Trend Indicator Badge
              Positioned(
                top: -6,
                right: -6,
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
                  onTap: () => onAddQuickCategory(item.name, item.icon, item.color),
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
                        Icon(
                          item.icon,
                          size: 16,
                          color: item.color,
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
