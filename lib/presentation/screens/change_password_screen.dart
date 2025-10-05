import 'package:flutter/material.dart';
import 'package:nes_ui/nes_ui.dart';
import 'package:pixelarticons/pixel.dart';
import '../../core/theme/app_theme.dart';
import '../../services/request_service.dart';

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
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateCurrentPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your current password';
    }
    return null;
  }

  String? _validateNewPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a new password';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long';
    }
    if (value == _currentPasswordController.text) {
      return 'New password must be different from current password';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please confirm your new password';
    }
    if (value != _newPasswordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  void _togglePasswordVisibility(int field) {
    if (_isChanging) return;

    setState(() {
      switch (field) {
        case 0:
          _obscureCurrentPassword = !_obscureCurrentPassword;
          break;
        case 1:
          _obscureNewPassword = !_obscureNewPassword;
          break;
        case 2:
          _obscureConfirmPassword = !_obscureConfirmPassword;
          break;
      }
    });
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Confirm Password Change',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        content: Text(
          'Are you sure you want to change your password?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
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
              content: const Text('Password changed successfully!'),
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
            _errorMessage = result.error ?? 'An error occurred';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'An error occurred. Please try again';
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
    required String? Function(String?) validator,
    ValueChanged<String>? onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: TextFormField(
        controller: controller,
        enabled: !_isChanging,
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(fontSize: 10, color: AppTheme.primaryColor),
          hintStyle: TextStyle(
            fontSize: 10,
            color: AppTheme.primaryColor.withOpacity(0.5),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
          prefixIcon: Icon(Pixel.lock, color: AppTheme.primaryColor, size: 20),
          suffixIcon: GestureDetector(
            onTap: onToggleVisibility,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Icon(
                obscureText ? Pixel.eyeclosed : Pixel.eye,
                color: AppTheme.primaryColor,
                size: 20,
              ),
            ),
          ),
        ),
        style: const TextStyle(fontSize: 12),
        validator: validator,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        onChanged: onChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Change Password'),
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
                  _buildPasswordField(
                    controller: _currentPasswordController,
                    label: 'Current Password',
                    hint: 'Enter your current password',
                    obscureText: _obscureCurrentPassword,
                    onToggleVisibility: () => _togglePasswordVisibility(0),
                    validator: _validateCurrentPassword,
                  ),

                  const SizedBox(height: 20),

                  _buildPasswordField(
                    controller: _newPasswordController,
                    label: 'New Password',
                    hint: 'Enter your new password',
                    obscureText: _obscureNewPassword,
                    onToggleVisibility: () => _togglePasswordVisibility(1),
                    validator: _validateNewPassword,
                    onChanged: (value) {
                      if (_confirmPasswordController.text.isNotEmpty) {
                        _formKey.currentState?.validate();
                      }
                    },
                  ),

                  const SizedBox(height: 20),

                  _buildPasswordField(
                    controller: _confirmPasswordController,
                    label: 'Confirm New Password',
                    hint: 'Confirm your new password',
                    obscureText: _obscureConfirmPassword,
                    onToggleVisibility: () => _togglePasswordVisibility(2),
                    validator: _validateConfirmPassword,
                  ),

                  const SizedBox(height: 30),

                  NesContainer(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Pixel.infobox,
                              size: 16,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Password Requirements',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildRequirement('At least 6 characters long'),
                        const SizedBox(height: 4),
                        _buildRequirement(
                          'Must be different from current password',
                        ),
                        const SizedBox(height: 4),
                        _buildRequirement(
                          'Use letters, numbers, and symbols for better security',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  _isChanging
                      ? NesContainer(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'Changing Password...',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        )
                      : NesButton(
                          type: NesButtonType.primary,
                          onPressed: _changePassword,
                          child: const Text(
                            'Change Password',
                            textAlign: TextAlign.center,
                          ),
                        ),

                  if (_errorMessage != null) ...[
                    const SizedBox(height: 20),
                    NesContainer(
                      padding: const EdgeInsets.all(12),
                      backgroundColor: AppTheme.errorColor.withOpacity(0.1),
                      child: Row(
                        children: [
                          Icon(
                            Pixel.close,
                            color: AppTheme.errorColor,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppTheme.errorColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequirement(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Icon(
            Pixel.check,
            size: 12,
            color: AppTheme.primaryColor.withOpacity(0.7),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.primaryColor.withOpacity(0.8),
            ),
          ),
        ),
      ],
    );
  }
}
