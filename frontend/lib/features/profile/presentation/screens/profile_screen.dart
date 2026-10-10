import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/services/auth_service_provider.dart';
import '../../../dashboard/presentation/widgets/tactile_time_header_wrapper.dart';

/// Halaman Profil Sesuai Desain Referensi Modern Tactile Finance
/// Menggunakan Blue Gradient Header dengan Tombol Back Glassmorphic,
/// Kartu Profil Tactile berisikan Avatar, Nama, Email, Tanggal Terdaftar,
/// serta Tombol Keluar (Logout) Tactile dengan Aksen Merah Lembut.
class ProfileScreen extends StatelessWidget {
  final UserProfile? user;

  const ProfileScreen({
    super.key,
    this.user,
  });

  Future<void> _handleLogout(BuildContext context) async {
    HapticFeedback.mediumImpact();
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Keluar dari Akun?',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: const Color(0xFF0F172A),
          ),
        ),
        content: Text(
          'Apakah Anda yakin ingin keluar dari akun ini?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: const Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Batal',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Keluar',
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await AuthServiceProvider.instance.signOut();
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/login',
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeUser = user ?? AuthServiceProvider.instance.currentUser;
    final String displayName = activeUser?.displayName ?? 'Alex Pratama';
    final String email = activeUser?.email ?? 'alex.pratama@email.com';
    final String initial = displayName.isNotEmpty
        ? displayName.trim().substring(0, 1).toUpperCase()
        : 'U';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFFFAF8FF),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF8FF),
        body: Column(
          children: [
            // 1. Header Card dengan Royal Blue Gradient & Glassmorphic Back Button
            _buildProfileHeader(context),

            // 2. Main Content Canvas
            Expanded(
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                  child: Column(
                    children: [
                      // Kartu Informasi Profil Tactile
                      _buildProfileCard(
                        displayName: displayName,
                        email: email,
                        initial: initial,
                        avatarUrl: activeUser?.photoUrl,
                        createdAt: activeUser?.createdAt,
                      ),

                      const SizedBox(height: 18),

                      // Tombol Keluar (Logout) Tactile Merah
                      _buildLogoutButton(context),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context) {
    return TactileTimeHeaderWrapper(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Tombol Kembali Glassmorphic
              _ProfileHeaderBackButton(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).maybePop();
                },
              ),

              // Judul Halaman "Profil"
              Text(
                'Profil',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),

              // Placeholder seimbang di sisi kanan
              const SizedBox(width: 44, height: 44),
            ],
          ),
        ),
      ),
    );
  }

  String _formatJoinDate(DateTime? dateTime) {
    if (dateTime == null) {
      return '10 Oktober 2026';
    }
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final local = dateTime.toLocal();
    final day = local.day;
    final month = months[local.month - 1];
    final year = local.year;
    return '$day $month $year';
  }

  Widget _buildProfileCard({
    required String displayName,
    required String email,
    required String initial,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFEAEDFF),
          width: 1.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D0F172A),
            blurRadius: 20,
            offset: Offset(0, 6),
          ),
          BoxShadow(
            color: Color(0x080F172A),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar Bulat 80x80 dengan Blue Gradient / Photo
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF004AC6),
                  Color(0xFF2563EB),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x33004AC6),
                  blurRadius: 14,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: ClipOval(
              child: (avatarUrl != null && avatarUrl.isNotEmpty)
                  ? Image.network(
                      avatarUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Text(
                          initial,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        initial,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 16),

          // Nama Pengguna
          Text(
            displayName,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF131B2E),
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          // Email Pengguna
          Text(
            email,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF434655),
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 20),

          // Divider Pemisah
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFEAEDFF),
          ),

          const SizedBox(height: 16),

          // Terdaftar Sejak
          Column(
            children: [
              Text(
                'TERDAFTAR SEJAK',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: const Color(0xFF737686),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatJoinDate(createdAt),
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF131B2E),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return _TactileLogoutButton(
      onTap: () => _handleLogout(context),
    );
  }
}

/// Tombol Kembali Glassmorphic pada Header
class _ProfileHeaderBackButton extends StatefulWidget {
  final VoidCallback onTap;

  const _ProfileHeaderBackButton({required this.onTap});

  @override
  State<_ProfileHeaderBackButton> createState() =>
      _ProfileHeaderBackButtonState();
}

class _ProfileHeaderBackButtonState extends State<_ProfileHeaderBackButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: Offset(0, _isPressed ? 0.05 : 0.0),
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOutCubic,
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: GestureDetector(
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: _isPressed ? 0.28 : 0.16),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: _isPressed ? 0.50 : 0.35),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x1A000000),
                  blurRadius: _isPressed ? 2 : 8,
                  offset: Offset(0, _isPressed ? 1 : 2),
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
      ),
    );
  }
}

/// Tombol Keluar (Logout) Tactile dengan Aksen Merah Lembut
class _TactileLogoutButton extends StatefulWidget {
  final VoidCallback onTap;

  const _TactileLogoutButton({required this.onTap});

  @override
  State<_TactileLogoutButton> createState() => _TactileLogoutButtonState();
}

class _TactileLogoutButtonState extends State<_TactileLogoutButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: Offset(0, _isPressed ? 0.035 : 0.0),
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOutCubic,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onHighlightChanged: (highlighted) {
              setState(() => _isPressed = highlighted);
            },
            onTap: () {
              HapticFeedback.lightImpact();
              widget.onTap();
            },
            borderRadius: BorderRadius.circular(14),
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                color: _isPressed ? const Color(0xFFFFF5F5) : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _isPressed ? const Color(0xFFFFB4AB) : const Color(0xFFFFDAD6),
                  width: 1.0,
                ),
                boxShadow: _isPressed
                    ? [
                        BoxShadow(
                          color: const Color(0xFFBA1A1A).withValues(alpha: 0.04),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: const Color(0xFFBA1A1A).withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
              ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.logout_rounded,
                  size: 20,
                  color: Color(0xFFBA1A1A),
                ),
                const SizedBox(width: 8),
                Text(
                  'Keluar',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFBA1A1A),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
}
