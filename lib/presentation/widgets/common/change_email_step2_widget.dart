import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import '../custom/custom_button.dart';
import '../custom/custom_container.dart';
import 'info_container_widget.dart';
import 'email_field_widget.dart';
import 'custom_loading_button.dart';
import 'error_container_widget.dart';

class ChangeEmailStep2 extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final bool isLoading;
  final String? errorMessage;
  final String? Function(String?)? emailValidator;
  final VoidCallback onSubmitNewEmail;
  final VoidCallback onResetFlow;

  const ChangeEmailStep2({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.isLoading,
    required this.errorMessage,
    required this.emailValidator,
    required this.onSubmitNewEmail,
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
            backgroundColor: Colors.green[50],
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Email hiện tại đã được xác minh!',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          EmailField(
            controller: emailController,
            enabled: !isLoading,
            label: 'Địa chỉ email mới',
            hint: 'Nhập email mới của bạn',
            validator: emailValidator,
          ),
          const SizedBox(height: 20),
          InfoContainer(
            icon: Pixel.infobox,
            title: 'Yêu cầu',
            items: [
              'Phải là định dạng email hợp lệ',
              'Phải khác với email hiện tại',
              'Không được trùng với tài khoản khác',
            ],
          ),
          const SizedBox(height: 30),
          isLoading
              ? const CustomLoadingButton()
              : CustomButton(
                  type: CustomButtonType.primary,
                  onPressed: onSubmitNewEmail,
                  child: const Text(
                    'Gửi mã PIN đến email mới',
                    textAlign: TextAlign.center,
                  ),
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
