import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/models/user_profile.dart';
import '../../../../core/services/auth_service_provider.dart';
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
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar with Circular Back Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 6.0),
              child: Row(
                children: [
                  _ProfileBackButton(
                    onTap: () => Navigator.of(context).maybePop(),
                  ),
                ],
              ),
            ),

            // Centered Profile Information and Bottom Action
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 20.0),
                          child: Column(
                            children: [
                              const Spacer(flex: 4),

                              // Avatar, Display Name & Email
                              ProfileAvatarCard(
                                name: displayName,
                                email: email,
                                avatarUrl: user?.photoUrl,
                              ),

                              const Spacer(flex: 5),

                              // Keluar (Logout) Action Button
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
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileBackButton extends StatefulWidget {
  final VoidCallback onTap;

  const _ProfileBackButton({required this.onTap});

  @override
  State<_ProfileBackButton> createState() => _ProfileBackButtonState();
}

class _ProfileBackButtonState extends State<_ProfileBackButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _isPressed ? 0.95 : 1.0,
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
            color: AppColors.surfaceContainerLowest,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0D2C3A).withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.95),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 20,
              color: AppColors.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}
