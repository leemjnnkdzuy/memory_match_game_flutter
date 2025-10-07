import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import '../../../core/theme/app_theme.dart';
import '../custom/custom_container.dart';
import 'requirement_item_widget.dart';

class PasswordRequirements extends StatelessWidget {
  const PasswordRequirements({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Pixel.infobox, size: 16, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                'Yêu cầu mật khẩu',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const RequirementItem(text: 'Ít nhất 6 ký tự'),
          const SizedBox(height: 4),
          const RequirementItem(text: 'Phải khác với mật khẩu hiện tại'),
          const SizedBox(height: 4),
          const RequirementItem(
            text: 'Sử dụng chữ cái, số và ký hiệu để bảo mật tốt hơn',
          ),
        ],
      ),
    );
  }
}
