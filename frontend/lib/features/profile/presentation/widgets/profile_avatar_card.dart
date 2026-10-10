import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class ProfileAvatarCard extends StatelessWidget {
  final String name;
  final String email;
  final String? avatarUrl;

  const ProfileAvatarCard({
    super.key,
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  static const String _defaultAvatarUrl =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuAwqWWxEsKbhA_T6-rzz8N8KXbmE7yeNV1wN7wG4Q87Q61Thrz5UXCkk3w8CUVIjNZvRvAaNPtXrvhKi7w1AtcJmyshYcGaap9PBZ9pDKsMuO40gcOVrcONocoTuQSrD2aRDl6NIbRaH1K4baMDCYNX3NhitRyXxbaX2SEPwr6Ltk-6hAcUErMrZVHcjyXRqB9XMgXX898v6K7bEE0vYB-TiZPLq8DE9Ht7BtYgeCGQ';

  @override
  Widget build(BuildContext context) {
    final effectiveUrl = (avatarUrl != null && avatarUrl!.isNotEmpty)
        ? avatarUrl!
        : _defaultAvatarUrl;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 128x128 3D Clay Gradient Avatar Sphere
        Container(
          width: 128,
          height: 128,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFB7EAFF),
                AppColors.primaryContainer,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryContainer.withValues(alpha: 0.45),
                blurRadius: 32,
                spreadRadius: -6,
                offset: const Offset(0, 18),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.85),
                blurRadius: 8,
                offset: const Offset(0, -3),
              ),
              BoxShadow(
                color: const Color(0xFF006780).withValues(alpha: 0.22),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.surfaceContainerLowest,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.network(
                effectiveUrl,
                width: 120,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: AppColors.primaryFixed,
                    child: const Icon(
                      Icons.person_rounded,
                      size: 64,
                      color: AppColors.primary,
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: AppColors.surfaceContainerLow,
                    child: const Center(
                      child: SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        const SizedBox(height: 24),

        // User Display Name
        Text(
          name,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 22,
            height: 28 / 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
            color: AppColors.onSurface,
          ),
        ),

        const SizedBox(height: 4),

        // User Email Address
        Text(
          email,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            height: 20 / 14,
            fontWeight: FontWeight.w500,
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }
}
