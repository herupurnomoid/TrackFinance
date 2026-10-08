import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/services/auth_service_provider.dart';
import 'package:track_finance/features/dashboard/presentation/widgets/dashboard_app_bar.dart';
import '../widgets/account_info_card.dart';
import '../widgets/logout_button.dart';
import '../widgets/profile_avatar_card.dart';

class ProfileScreen extends StatelessWidget {
  final UserProfile? user;

  const ProfileScreen({
    super.key,
    this.user,
  });

  @override
  Widget build(BuildContext context) {
    final String displayName = user?.displayName ?? 'Alex Pratama';
    final String email = user?.email ?? 'alex.pratama@email.com';

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: DashboardAppBar(
        onBack: () => Navigator.of(context).maybePop(),
        onProfile: null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            children: [
              // Subtle Tactile Status Pill at Top Center
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(99),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryContainer.withValues(alpha: 0.18),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryContainer,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Profile Avatar & Identity Card
              ProfileAvatarCard(
                name: displayName,
                email: email,
                avatarUrl: user?.photoUrl,
              ),

              const SizedBox(height: 24),

              // Account Details Section ("INFORMASI AKUN")
              AccountInfoCard(
                name: displayName,
                email: email,
              ),

              const SizedBox(height: 32),

              // Logout Action Button
              LogoutButton(
                onLogout: () async {
                  await AuthServiceProvider.instance.signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/login',
                      (route) => false,
                    );
                  }
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
