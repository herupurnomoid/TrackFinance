import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/animations.dart';
import '../../data/category_model.dart';

/// 4-Column Skeuomorphic Tile Item Kategori
/// Sesuai referensi HTML 1 Modern Tactile Finance
class CategoryGridItem extends StatelessWidget {
  final CategoryItem category;
  final VoidCallback onTap;

  const CategoryGridItem({
    super.key,
    required this.category,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Tentukan warna container tint dan warna icon
    final iconColor = category.color;
    final containerBg = _getTintBackground(iconColor);

    return PressableScale(
      onTap: onTap,
      scaleFactor: 0.94,
      translateY: 2.0,
      child: Container(
        height: 94,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
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
                color: Color(0x122563EB),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
              BoxShadow(
                color: Color(0x080F172A),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Lock Badge jika kategori bawaan terkunci ('Lainnya')
              if (category.isLocked)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFFDAE2FD),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 1.5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x150F172A),
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.lock_rounded,
                        size: 11,
                        color: Color(0xFF434655),
                      ),
                    ),
                  ),
                ),

              // Konten Utama: Icon + Nama
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon Well 40x40 rounded-14
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: containerBg,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: iconColor.withValues(alpha: 0.18),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        category.icon,
                        size: 20,
                        color: iconColor,
                      ),
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Nama Kategori (Max 2 baris)
                  Expanded(
                    child: Center(
                      child: Text(
                        category.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF131B2E),
                          height: 1.15,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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

  Color _getTintBackground(Color color) {
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

/// Tile Khusus "+ Tambah" di akhir grid kategori
class CategoryAddTile extends StatelessWidget {
  final VoidCallback onTap;

  const CategoryAddTile({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PressableScale(
      onTap: onTap,
      scaleFactor: 0.94,
      translateY: 2.0,
      child: Container(
        height: 94,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: const Color(0xFFDBE1FF).withValues(alpha: 0.4),
          border: Border.all(
            color: const Color(0xFF2563EB).withValues(alpha: 0.25),
            width: 1.0,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A2563EB),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Icon Well Tambah
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x262563EB),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.add_rounded,
                  size: 22,
                  color: Color(0xFF004AC6),
                ),
              ),
            ),

            const SizedBox(height: 6),

            Expanded(
              child: Center(
                child: Text(
                  'Tambah',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF004AC6),
                    height: 1.15,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
