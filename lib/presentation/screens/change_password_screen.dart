import 'package:flutter/material.dart';
import '../widgets/custom/custom_button.dart';
import '../widgets/custom/custom_password_input.dart';
import 'package:pixelarticons/pixel.dart';
import '../../core/theme/app_theme.dart';
import '../../services/request_service.dart';
import '../widgets/custom/custom_app_bar.dart';
import '../widgets/common/password_requirements_widget.dart';
import '../widgets/common/password_loading_button_widget.dart';
import '../widgets/common/password_error_container_widget.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isChanging = false;
  String? _errorMessage;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateCurrentPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu hiện tại';
    }
    return null;
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu mới';
    }
    if (value.length < 6) {
      return 'Mật khẩu phải có ít nhất 6 ký tự';
    }
    if (value == _currentPasswordController.text) {
      return 'Mật khẩu mới phải khác với mật khẩu hiện tại';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu mới';
    }
    if (value != _newPasswordController.text) {
      return 'Mật khẩu không khớp';
    }
    return null;
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Xác nhận đổi mật khẩu',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        content: Text(
          'Bạn có chắc chắn muốn đổi mật khẩu?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() {
      _isChanging = true;
      _errorMessage = null;
    });

    try {
      final requestService = RequestService.instance;
      final result = await requestService.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
        confirmNewPassword: _confirmPasswordController.text,
      );

      if (mounted) {
        if (result.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Mật khẩu đã được đổi thành công!'),
              backgroundColor: AppTheme.secondaryColor,
              duration: const Duration(seconds: 3),
            ),
          );

          await Future.delayed(const Duration(seconds: 1));
          if (mounted) {
            Navigator.pop(context, true);
          }
        } else {
          setState(() {
            _errorMessage = result.error ?? 'Đã xảy ra lỗi';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Đã xảy ra lỗi. Vui lòng thử lại';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isChanging = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: CustomAppBar(
        title: 'Đổi mật khẩu',
        leading: IconButton(
          icon: const Icon(Pixel.arrowleft),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomPasswordInput(
                    controller: _currentPasswordController,
                    labelText: 'Mật khẩu hiện tại',
                    hintText: 'Nhập mật khẩu hiện tại',
                    enabled: !_isChanging,
                    validator: _validateCurrentPassword,
                  ),

                  const SizedBox(height: 20),

                  CustomPasswordInput(
                    controller: _newPasswordController,
                    labelText: 'Mật khẩu mới',
                    hintText: 'Nhập mật khẩu mới',
                    enabled: !_isChanging,
                    validator: _validateNewPassword,
                    onChanged: (value) {
                      if (_confirmPasswordController.text.isNotEmpty) {
                        _formKey.currentState?.validate();
                      }
                    },
                  ),

                  const SizedBox(height: 20),

                  CustomPasswordInput(
                    controller: _confirmPasswordController,
                    labelText: 'Xác nhận mật khẩu mới',
                    hintText: 'Xác nhận mật khẩu mới',
                    enabled: !_isChanging,
                    validator: _validateConfirmPassword,
                  ),

                  const SizedBox(height: 30),

                  const PasswordRequirements(),

                  const SizedBox(height: 30),

                  _isChanging
                      ? const PasswordLoadingButton()
                      : CustomButton(
                          type: CustomButtonType.primary,
                          onPressed: _changePassword,
                          child: const Text(
                            'Đổi mật khẩu',
                            textAlign: TextAlign.center,
                          ),
                        ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 20),
                    PasswordErrorContainer(message: _errorMessage!),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
