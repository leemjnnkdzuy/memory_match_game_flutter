import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../widgets/custom/custom_container.dart';
import '../widgets/custom/custom_icon.dart';
import '../widgets/custom/custom_header.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CustomHeader(
            onBack: () => Navigator.pop(context),
            textColor: Colors.black,
            title: 'Đổi mật khẩu',
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSettingOption(
                      context,
                      icon: CustomIcons.user,
                      title: 'Đổi tên người dùng',
                      subtitle: 'Cập nhật tên người dùng của bạn',
                      onTap: () {
                        AppRoutes.navigateToChangeUsername(context);
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildSettingOption(
                      context,
                      icon: CustomIcons.user,
                      title: 'Đổi mật khẩu',
                      subtitle: 'Cập nhật mật khẩu của bạn',
                      onTap: () {
                        AppRoutes.navigateToChangePassword(context);
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildSettingOption(
                      context,
                      icon: CustomIcons.user,
                      title: 'Đổi email',
                      subtitle: 'Cập nhật địa chỉ email của bạn',
                      onTap: () {
                        AppRoutes.navigateToChangeEmail(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingOption(
    BuildContext context, {
    required CustomIconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: CustomContainer(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CustomIcon(iconData: icon, size: const Size(32, 32)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(
                      context,
                    ).textTheme.labelLarge?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 20),
          ],
        ),
      ),
    );
  }
}
