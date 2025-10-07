import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import '../../../core/theme/app_theme.dart';
import '../custom/custom_text_input.dart';

class PinField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final String label;
  final String hint;
  final String? Function(String?)? validator;

  const PinField({
    super.key,
    required this.controller,
    required this.enabled,
    required this.label,
    required this.hint,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextInput(
      controller: controller,
      enabled: enabled,
      keyboardType: TextInputType.number,
      maxLength: 6,
      labelText: label,
      hintText: hint,
      borderColor: AppTheme.primaryColor.withValues(alpha: 0.5),
      borderWidth: 2,
      fontSize: 12,
      letterSpacing: 4,
      textAlign: TextAlign.center,
      prefixIcon: Icon(Pixel.lock, color: AppTheme.primaryColor, size: 20),
      validator: validator,
    );
  }
}
