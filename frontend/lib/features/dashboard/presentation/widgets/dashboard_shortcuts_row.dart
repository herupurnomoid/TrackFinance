import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

/// 4 Tombol Pintasan Navigasi Menu Dashboard (Tambah, Kategori, Ekspor/Impor, Laporan)
/// Menggunakan Ikon Visual 3D Tactile buatan sendiri tanpa kontainer (no container, no background color).
/// Bebas ticker animasi idle kontinu agar 0% pemakaian CPU/GPU saat layar diam di perangkat low-end.
class DashboardShortcutsRow extends StatelessWidget {
  final VoidCallback onAdd;
  final VoidCallback onCategory;
  final VoidCallback onExportImport;
  final VoidCallback onReports;

  const DashboardShortcutsRow({
    super.key,
    required this.onAdd,
    required this.onCategory,
    required this.onExportImport,
    required this.onReports,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Tambah Transaksi
          Expanded(
            child: _TactileShortcutItem(
              assetPath: 'assets/icons/3d/nav_add.webp',
              label: 'Tambah',
              onTap: onAdd,
            ),
          ),

          // 2. Manajemen Kategori
          Expanded(
            child: _TactileShortcutItem(
              assetPath: 'assets/icons/3d/nav_category.webp',
              label: 'Kategori',
              onTap: onCategory,
            ),
          ),

          // 3. Ekspor/Impor
          Expanded(
            child: _TactileShortcutItem(
              assetPath: 'assets/icons/3d/nav_export.webp',
              label: 'Ekspor/Impor',
              onTap: onExportImport,
            ),
          ),

          // 4. Laporan
          Expanded(
            child: _TactileShortcutItem(
              assetPath: 'assets/icons/3d/nav_report.webp',
              label: 'Laporan',
              onTap: onReports,
            ),
          ),
        ],
      ),
    );
  }
}

/// Item tombol navigasi 3D lepas tanpa pembatas kontainer dan tanpa background color
class _TactileShortcutItem extends StatefulWidget {
  final String assetPath;
  final String label;
  final VoidCallback onTap;

  const _TactileShortcutItem({
    required this.assetPath,
    required this.label,
    required this.onTap,
  });

  @override
  State<_TactileShortcutItem> createState() => _TactileShortcutItemState();
}

class _TactileShortcutItemState extends State<_TactileShortcutItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        setState(() => _isPressed = true);
      },
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      child: AnimatedSlide(
        offset: _isPressed ? const Offset(0, 0.035) : Offset.zero,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOutCubic,
        child: AnimatedScale(
          scale: _isPressed ? 0.90 : 1.0,
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOutCubic,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  widget.assetPath,
                  width: 52,
                  height: 52,
                  fit: BoxFit.contain,
                  cacheWidth: 156,
                  cacheHeight: 156,
                  filterQuality: FilterQuality.low,
                ),
                const SizedBox(height: 6),
                Text(
                  widget.label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: _isPressed
                        ? const Color(0xFF1D4ED8)
                        : const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
