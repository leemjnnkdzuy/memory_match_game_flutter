import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import '../../../core/theme/app_theme.dart';
import '../custom/custom_button.dart';
import '../custom/custom_container.dart';
import '../custom/custom_loading_button.dart';
import 'error_container_widget.dart';

class ChangeEmailStep0 extends StatelessWidget {
  final String? currentEmail;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRequestChangeEmail;

  const ChangeEmailStep0({
    super.key,
    required this.currentEmail,
    required this.isLoading,
    required this.errorMessage,
    required this.onRequestChangeEmail,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (currentEmail != null) ...[
          CustomContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Pixel.mail, color: AppTheme.primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Email hiện tại',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.primaryColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  currentEmail!,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
        Text(
          '• Chúng tôi sẽ gửi mã PIN đến email hiện tại của bạn\n'
          '• Xác minh email hiện tại bằng mã PIN\n'
          '• Nhập địa chỉ email mới\n'
          '• Xác minh email mới bằng mã PIN khác',
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 30),
        isLoading
            ? const CustomLoadingButton()
            : CustomButton(
                type: CustomButtonType.primary,
                onPressed: onRequestChangeEmail,
                child: const Text(
                  'Bắt đầu đổi email',
                  textAlign: TextAlign.center,
                ),
              ),
        if (errorMessage != null) ...[
          const SizedBox(height: 20),
          ErrorContainer(message: errorMessage!),
        ],
      ],
    );
  }
}
