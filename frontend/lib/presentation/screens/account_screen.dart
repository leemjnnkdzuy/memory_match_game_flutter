import 'package:flutter/material.dart';
import 'package:memory_match_game/services/auth_service.dart';
import 'package:memory_match_game/presentation/widgets/common/profile_header_widget.dart';
import 'package:memory_match_game/presentation/widgets/common/social_links_widget.dart';
import 'package:memory_match_game/presentation/widgets/common/account_info_widget.dart';
import 'package:memory_match_game/presentation/widgets/common/actions_widget.dart';
import 'package:memory_match_game/presentation/widgets/common/guest_account_widget.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {});
    });
  }

  void _onSocialLinkTap(String label, String url) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đang mở $label - Tính năng sắp ra mắt!')),
    );
  }

  void _onEditProfile() {
    Navigator.pushNamed(context, '/edit-profile').then((result) {
      if (result == true) {
        setState(() {});
      }
    });
  }

  void _onSettings() {
    Navigator.pushNamed(context, '/settings');
  }

  Future<void> _onLogout() async {
    await AuthService.instance.logout();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthService.instance.isRealUser) {
      return const GuestAccountWidget();
    }

    final user = AuthService.instance.currentUser;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF64B5F6), Color(0xFF1976D2)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ProfileHeaderWidget(
                  fullName: user?.fullName,
                  username: user?.username,
                  isVerified: user?.isVerified ?? false,
                  userId: user?.id,
                  avatarData: user?.avatar,
                ),

                SizedBox(height: 16),

                SocialLinksWidget(
                  githubUrl: user?.githubUrl,
                  linkedinUrl: user?.linkedinUrl,
                  websiteUrl: user?.websiteUrl,
                  youtubeUrl: user?.youtubeUrl,
                  facebookUrl: user?.facebookUrl,
                  instagramUrl: user?.instagramUrl,
                  onLinkTap: _onSocialLinkTap,
                ),

                if ((user?.githubUrl?.isNotEmpty == true) ||
                    (user?.linkedinUrl?.isNotEmpty == true) ||
                    (user?.websiteUrl?.isNotEmpty == true) ||
                    (user?.youtubeUrl?.isNotEmpty == true) ||
                    (user?.facebookUrl?.isNotEmpty == true) ||
                    (user?.instagramUrl?.isNotEmpty == true))
                  SizedBox(height: 16),

                AccountInfoWidget(
                  id: user?.id,
                  email: user?.email,
                  language: user?.language,
                  bio: user?.bio,
                ),

                SizedBox(height: 16),

                ActionsWidget(
                  onEditProfile: _onEditProfile,
                  onSettings: _onSettings,
                  onLogout: _onLogout,
                ),

                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
