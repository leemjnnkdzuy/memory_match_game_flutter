import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import '../../../core/theme/app_theme.dart';
import '../custom/custom_container.dart';

class ErrorContainer extends StatelessWidget {
  final String message;

  const ErrorContainer({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      padding: const EdgeInsets.all(12),
      backgroundColor: AppTheme.errorColor.withValues(alpha: 0.1),
      child: Row(
        children: [
          Icon(Pixel.close, color: AppTheme.errorColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}
