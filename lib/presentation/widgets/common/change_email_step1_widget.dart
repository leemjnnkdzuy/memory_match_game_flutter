import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import '../../../core/theme/app_theme.dart';
import '../custom/custom_button.dart';
import '../custom/custom_container.dart';
import 'info_container_widget.dart';
import 'pin_field_widget.dart';
import 'custom_loading_button.dart';
import 'error_container_widget.dart';

class ChangeEmailStep1 extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController pinController;
  final String? currentEmail;
  final bool isLoading;
  final String? errorMessage;
  final String? Function(String?)? pinValidator;
  final VoidCallback onConfirmCurrentEmail;
  final VoidCallback onRequestChangeEmail;
  final VoidCallback onResetFlow;

  const ChangeEmailStep1({
    super.key,
    required this.formKey,
    required this.pinController,
    required this.currentEmail,
    required this.isLoading,
    required this.errorMessage,
    required this.pinValidator,
    required this.onConfirmCurrentEmail,
    required this.onRequestChangeEmail,
    required this.onResetFlow,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CustomContainer(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Pixel.mail, color: AppTheme.primaryColor, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Đã gửi mã PIN đến:',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.primaryColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  currentEmail ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          PinField(
            controller: pinController,
            enabled: !isLoading,
            label: 'Mã PIN',
            hint: 'Nhập 6 chữ số',
            validator: pinValidator,
          ),
          const SizedBox(height: 20),
          InfoContainer(
            icon: Pixel.infobox,
            title: 'Hướng dẫn',
            items: [
              'Kiểm tra hộp thư đến của email hiện tại',
              'Nhập mã PIN gồm 6 chữ số',
              'Mã PIN sẽ hết hạn sau 10 phút',
            ],
          ),
          const SizedBox(height: 30),
          isLoading
              ? const CustomLoadingButton()
              : CustomButton(
                  type: CustomButtonType.success,
                  onPressed: onConfirmCurrentEmail,
                  child: const Text(
                    'Xác minh email hiện tại',
                    textAlign: TextAlign.center,
                  ),
                ),
          const SizedBox(height: 12),
          CustomButton(
            type: CustomButtonType.normal,
            onPressed: isLoading ? null : onRequestChangeEmail,
            child: const Text('Gửi lại mã PIN', textAlign: TextAlign.center),
          ),
          const SizedBox(height: 12),
          CustomButton(
            type: CustomButtonType.error,
            onPressed: isLoading ? null : onResetFlow,
            child: const Text('Hủy', textAlign: TextAlign.center),
          ),
          if (errorMessage != null) ...[
            const SizedBox(height: 20),
            ErrorContainer(message: errorMessage!),
          ],
        ],
      ),
    );
  }
}
