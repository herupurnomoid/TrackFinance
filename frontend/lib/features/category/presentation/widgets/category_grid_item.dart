import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/widgets/animations.dart';
import '../../data/category_model.dart';
import 'category_3d_icon.dart';

/// Item Kategori Grid 4-Kolom Modern Tactile Finance
/// Ikon 3D tampil bebas tanpa kontainer/div pembatas dan tanpa background color.
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
    return PressableScale(
      onTap: onTap,
      scaleFactor: 0.92,
      translateY: 2.0,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Konten Utama: 3D Icon Bebas Batasan + Nama
          SizedBox(
            width: double.infinity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // 3D Category Icon (Ukuran Besar 56x56)
                Category3DIcon(
                  category: category,
                  size: 56,
                ),

                const SizedBox(height: 6),

                // Nama Kategori (Max 2 baris)
                Text(
                  category.name,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF131B2E),
                    height: 1.18,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Lock Badge jika kategori bawaan terkunci ('Lainnya')
          if (category.isLocked)
            Positioned(
              top: 0,
              right: 6,
              child: Container(
                width: 18,
                height: 18,
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
                    size: 10,
                    color: Color(0xFF434655),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
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
      scaleFactor: 0.92,
      translateY: 2.0,
      child: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Tactile 3D Plus Button (56x56) - Bebas tanpa kontainer pembatas kotak
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFFEFF6FF),
                    Color(0xFFDBEAFE),
                  ],
                ),
                border: Border.all(
                  color: const Color(0xFF93C5FD),
                  width: 1.5,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x202563EB),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.add_rounded,
                  size: 30,
                  color: Color(0xFF004AC6),
                ),
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'Tambah',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF004AC6),
                height: 1.18,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
