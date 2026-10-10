import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

/// SVG 3D Tactile Artwork untuk tombol Tambah Transaksi
const String _svgTambah = '''
<svg viewBox="0 0 72 72">
  <defs>
    <linearGradient id="ts" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#fff"/><stop offset="1" stop-color="#DCE8FF"/></linearGradient>
    <linearGradient id="tb" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#3B82F6"/><stop offset="1" stop-color="#1D4ED8"/></linearGradient>
    <linearGradient id="tg" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#4ADE80"/><stop offset="1" stop-color="#16A34A"/></linearGradient>
  </defs>
  <rect x="13" y="10" width="46" height="48" rx="10" fill="#C7D6FB" transform="rotate(-7 36 34)"/>
  <rect x="11" y="10" width="46" height="50" rx="10" fill="url(#ts)"/>
  <rect x="18" y="18" width="22" height="4.5" rx="2.2" fill="#93B4F5"/>
  <rect x="18" y="26" width="32" height="3.5" rx="1.8" fill="#C7D6FB"/>
  <rect x="18" y="33" width="18" height="3.5" rx="1.8" fill="#E2E8F0"/>
  <circle cx="16" cy="15" r="9" fill="url(#tg)"/>
  <circle cx="16" cy="15" r="3.5" fill="#fff"/>
  <circle cx="48" cy="46" r="16" fill="url(#tb)"/>
  <path d="M48 37v18M39 46h18" stroke="#fff" stroke-width="4.2" stroke-linecap="round" stroke-linejoin="round"/>
</svg>
''';

/// SVG 3D Tactile Artwork untuk tombol Kategori (Sesuai Referensi)
const String _svgKategori = '''
<svg viewBox="0 0 72 72">
  <defs>
    <linearGradient id="kb" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#60A5FA"/><stop offset="1" stop-color="#1D4ED8"/></linearGradient>
    <linearGradient id="kg" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#4ADE80"/><stop offset="1" stop-color="#15803D"/></linearGradient>
    <linearGradient id="kr" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#FB7185"/><stop offset="1" stop-color="#DC2626"/></linearGradient>
    <linearGradient id="ka" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#FDE68A"/><stop offset="1" stop-color="#F59E0B"/></linearGradient>
  </defs>
  <rect x="7" y="7" width="27" height="27" rx="9" fill="url(#kb)"/>
  <rect x="38" y="7" width="27" height="27" rx="9" fill="url(#kg)"/>
  <rect x="7" y="38" width="27" height="27" rx="9" fill="url(#kr)"/>
  <rect x="38" y="38" width="27" height="27" rx="9" fill="url(#ka)"/>
  <path d="M13 17q4-6 11-5" stroke="#fff" stroke-width="2.4" stroke-linecap="round" fill="none" opacity=".55"/>
  <path d="M44 17q4-6 11-5" stroke="#fff" stroke-width="2.4" stroke-linecap="round" fill="none" opacity=".55"/>
  <path d="M13 48q4-6 11-5" stroke="#fff" stroke-width="2.4" stroke-linecap="round" fill="none" opacity=".55"/>
  <path d="M44 48q4-6 11-5" stroke="#fff" stroke-width="2.4" stroke-linecap="round" fill="none" opacity=".7"/>
  <circle cx="20.5" cy="23" r="4" fill="#fff"/>
  <path d="M45 28l5-9 5 9z" fill="#fff"/>
  <rect x="14" y="52" width="13" height="4" rx="2" fill="#fff"/>
  <rect x="14" y="58" width="8" height="3" rx="1.5" fill="#fff" opacity=".7"/>
  <circle cx="51.5" cy="52" r="5" fill="none" stroke="#fff" stroke-width="3"/>
</svg>
''';

/// SVG 3D Tactile Artwork untuk tombol Ekspor/Impor (Sesuai Referensi)
const String _svgEksporImpor = '''
<svg viewBox="0 0 72 72">
  <defs>
    <linearGradient id="es" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#fff"/><stop offset="1" stop-color="#DCE8FF"/></linearGradient>
    <linearGradient id="eg" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#4ADE80"/><stop offset="1" stop-color="#16A34A"/></linearGradient>
    <linearGradient id="eb" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#60A5FA"/><stop offset="1" stop-color="#2563EB"/></linearGradient>
  </defs>
  <rect x="14" y="7" width="38" height="50" rx="9" fill="#C7D6FB" transform="rotate(-8 33 32)"/>
  <rect x="18" y="9" width="38" height="52" rx="9" fill="url(#es)"/>
  <path d="M44 9v10a3 3 0 0 0 3 3h9" fill="#E3EBFF"/>
  <rect x="25" y="28" width="24" height="4" rx="2" fill="#93B4F5"/>
  <rect x="25" y="36" width="18" height="4" rx="2" fill="#B6C9F8"/>
  <rect x="25" y="44" width="21" height="4" rx="2" fill="#B6C9F8"/>
  <circle cx="53" cy="52" r="14" fill="url(#eg)"/>
  <circle cx="16" cy="19" r="12" fill="url(#eb)"/>
  <path d="M53 45v13M47 53l6 6 6-6" stroke="#fff" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
  <path d="M16 25V13M10 19l6-6 6 6" stroke="#fff" stroke-width="4" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
</svg>
''';

/// SVG 3D Tactile Artwork untuk tombol Laporan (Sesuai Referensi)
const String _svgLaporan = '''
<svg viewBox="0 0 72 72">
  <defs>
    <linearGradient id="ls" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#fff"/><stop offset="1" stop-color="#DCE8FF"/></linearGradient>
    <linearGradient id="lb" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#60A5FA"/><stop offset="1" stop-color="#1D4ED8"/></linearGradient>
    <linearGradient id="lg" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#4ADE80"/><stop offset="1" stop-color="#15803D"/></linearGradient>
    <linearGradient id="lr" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#FB7185"/><stop offset="1" stop-color="#DC2626"/></linearGradient>
  </defs>
  <rect x="8" y="6" width="48" height="60" rx="10" fill="url(#ls)"/>
  <rect x="15" y="14" width="20" height="4.5" rx="2.2" fill="#93B4F5"/>
  <rect x="15" y="22" width="30" height="3.5" rx="1.8" fill="#C7D6FB"/>
  <rect x="15" y="43" width="8" height="15" rx="3" fill="url(#lb)"/>
  <rect x="26" y="35" width="8" height="23" rx="3" fill="url(#lg)"/>
  <rect x="37" y="29" width="8" height="29" rx="3" fill="url(#lr)"/>
  <line x1="14" y1="59.5" x2="48" y2="59.5" stroke="#B6C9F8" stroke-width="2" stroke-linecap="round"/>
  <circle cx="49" cy="48" r="13" fill="#fff" fill-opacity=".85" stroke="#2563EB" stroke-width="5"/>
  <path d="M58.5 57.5l8 8" stroke="#1D4ED8" stroke-width="6" stroke-linecap="round"/>
  <path d="M43 50l4-4 3 3 5-6" stroke="#16A34A" stroke-width="3" stroke-linecap="round" stroke-linejoin="round" fill="none"/>
</svg>
''';

/// 4 Tombol Pintasan Squircle Skeuomorphic (Tambah, Kategori, Ekspor/Impor, Laporan)
/// Menggunakan SVG ilustrasi 3D tactile dan micro-animasi sentuhan presisi.
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
    return Row(
      children: [
        // 1. Tambah Transaksi
        Expanded(
          child: _TactileShortcutCard(
            svgString: _svgTambah,
            label: 'Tambah',
            animationDelayIndex: 0,
            onTap: onAdd,
          ),
        ),
        const SizedBox(width: 8),

        // 2. Kategori
        Expanded(
          child: _TactileShortcutCard(
            svgString: _svgKategori,
            label: 'Kategori',
            animationDelayIndex: 1,
            onTap: onCategory,
          ),
        ),
        const SizedBox(width: 8),

        // 3. Ekspor/Impor
        Expanded(
          child: _TactileShortcutCard(
            svgString: _svgEksporImpor,
            label: 'Ekspor/Impor',
            animationDelayIndex: 2,
            onTap: onExportImport,
          ),
        ),
        const SizedBox(width: 8),

        // 4. Laporan
        Expanded(
          child: _TactileShortcutCard(
            svgString: _svgLaporan,
            label: 'Laporan',
            animationDelayIndex: 3,
            onTap: onReports,
          ),
        ),
      ],
    );
  }
}

class _TactileShortcutCard extends StatefulWidget {
  final String svgString;
  final String label;
  final int animationDelayIndex;
  final VoidCallback onTap;

  const _TactileShortcutCard({
    required this.svgString,
    required this.label,
    required this.animationDelayIndex,
    required this.onTap,
  });

  @override
  State<_TactileShortcutCard> createState() => _TactileShortcutCardState();
}

class _TactileShortcutCardState extends State<_TactileShortcutCard>
    with SingleTickerProviderStateMixin {
  bool _isPressed = false;
  late AnimationController _idleController;

  @override
  void initState() {
    super.initState();
    _idleController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2600 + widget.animationDelayIndex * 400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _idleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: _isPressed ? const Offset(0, 0.035) : Offset.zero,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOutCubic,
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 110),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 110),
          curve: Curves.easeOutCubic,
          height: 88,
          decoration: BoxDecoration(
            color: _isPressed ? const Color(0xFFF1F5F9) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isPressed
                  ? const Color(0xFF2563EB).withValues(alpha: 0.35)
                  : const Color(0xFF94A3B8).withValues(alpha: 0.22),
              width: 1.0,
            ),
            boxShadow: _isPressed
                ? [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1.5),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 3,
                      offset: const Offset(0, 1),
                    ),
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              splashColor: const Color(0xFF2563EB).withValues(alpha: 0.08),
              highlightColor: const Color(0xFF2563EB).withValues(alpha: 0.04),
              onHighlightChanged: (highlighted) {
                if (highlighted) {
                  HapticFeedback.lightImpact();
                }
                setState(() => _isPressed = highlighted);
              },
              onTap: () {
                HapticFeedback.lightImpact();
                widget.onTap();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animasi Floating Levitation SVG Art + 3D pressed response
                    AnimatedBuilder(
                      animation: _idleController,
                      builder: (context, child) {
                        final dy =
                            math.sin(_idleController.value * 2 * math.pi) * 1.8;
                        return Transform.translate(
                          offset: Offset(0, dy),
                          child: AnimatedScale(
                            scale: _isPressed ? 0.90 : 1.0,
                            duration: const Duration(milliseconds: 110),
                            curve: Curves.easeOutCubic,
                            child: child,
                          ),
                        );
                      },
                      child: SvgPicture.string(
                        widget.svgString,
                        width: 44,
                        height: 44,
                        fit: BoxFit.contain,
                      ),
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
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
