import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import '../custom/custom_text_input.dart';

class PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final String label;
  final String hint;
  final bool obscureText;
  final VoidCallback onToggleVisibility;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;

  const PasswordField({
    super.key,
    required this.controller,
    required this.enabled,
    required this.label,
    required this.hint,
    required this.obscureText,
    required this.onToggleVisibility,
    this.validator,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextInput(
      controller: controller,
      enabled: enabled,
      obscureText: obscureText,
      labelText: label,
      hintText: hint,
      borderWidth: 2,
      fontSize: 12,
      prefixIcon: Icon(Pixel.lock, size: 20),
      suffixIcon: GestureDetector(
        onTap: onToggleVisibility,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Icon(obscureText ? Pixel.eyeclosed : Pixel.eye, size: 20),
        ),
      ),
      validator: validator,
      onChanged: onChanged,
    );
  }
}
