import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

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
    final effectiveUrl = avatarUrl ?? _defaultAvatarUrl;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.clayShadow.withValues(alpha: 0.25),
            blurRadius: 28,
            spreadRadius: -6,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: const Color(0xFF0D2C3A).withValues(alpha: 0.05),
            blurRadius: 12,
            spreadRadius: -2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Clay Avatar Sphere with Verified Badge Pin
          Stack(
            clipBehavior: Clip.none,
            children: [
              // 3D Avatar Outer Sphere (112x112)
              Container(
                width: 112,
                height: 112,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.primaryFixed,
                      AppColors.primaryContainer,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryContainer.withValues(alpha: 0.45),
                      blurRadius: 28,
                      spreadRadius: -4,
                      offset: const Offset(0, 16),
                    ),
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 10,
                      spreadRadius: -2,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.network(
                    effectiveUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: AppColors.primaryFixed,
                        child: const Icon(
                          Icons.person_rounded,
                          size: 54,
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
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Verified Badge Pin at bottom-right
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryContainer.withValues(alpha: 0.5),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.8),
                        blurRadius: 4,
                        offset: const Offset(0, -1),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // User Name & Email
          Text(
            name,
            style: AppTextStyles.headlineMd.copyWith(
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: AppTextStyles.bodyMd.copyWith(
              color: AppColors.secondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
