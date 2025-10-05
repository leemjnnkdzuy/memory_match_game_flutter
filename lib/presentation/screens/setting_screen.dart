import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../widgets/custom/custom_container.dart';
import '../widgets/custom/custom_icon.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setting')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSettingOption(
                context,
                icon: CustomIcons.user,
                title: 'Change Username',
                subtitle: 'Update your username',
                onTap: () {
                  AppRoutes.navigateToChangeUsername(context);
                },
              ),
              const SizedBox(height: 16),

              _buildSettingOption(
                context,
                icon: CustomIcons.user,
                title: 'Change Password',
                subtitle: 'Update your password',
                onTap: () {
                  AppRoutes.navigateToChangePassword(context);
                },
              ),
              const SizedBox(height: 16),

              _buildSettingOption(
                context,
                icon: CustomIcons.user,
                title: 'Change Email',
                subtitle: 'Update your email address',
                onTap: () {
                  AppRoutes.navigateToChangeEmail(context);
                },
              ),
            ],
          ),
        ),
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
