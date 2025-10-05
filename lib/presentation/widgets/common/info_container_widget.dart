import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import '../../../core/theme/app_theme.dart';
import '../custom/custom_container.dart';

class InfoContainer extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> items;

  const InfoContainer({
    super.key,
    required this.icon,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Icon(
                      Pixel.check,
                      size: 12,
                      color: AppTheme.primaryColor.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryColor.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
