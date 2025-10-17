import 'package:flutter/material.dart';

class CustomTextInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final double fontSize;
  final int maxLines;
  final int? maxLength;
  final TextAlign textAlign;
  final double letterSpacing;
  final Color? borderColor;
  final double borderWidth;

  const CustomTextInput({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.fontSize = 14,
    this.maxLines = 1,
    this.maxLength,
    this.textAlign = TextAlign.start,
    this.letterSpacing = 0.0,
    this.borderColor,
    this.borderWidth = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 200, minHeight: 40),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: borderColor ?? Colors.black,
          width: borderWidth,
        ),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        onChanged: onChanged,
        validator: validator,
        enabled: enabled,
        maxLines: maxLines,
        maxLength: maxLength,
        textAlign: textAlign,
        enableIMEPersonalizedLearning: false,
        enableInteractiveSelection: true,
        style: TextStyle(
          fontFamily: 'Roboto',
          fontSize: fontSize,
          color: Colors.black87,
          letterSpacing: letterSpacing,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
          border: InputBorder.none,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          contentPadding: const EdgeInsets.all(12),
          counterText: maxLength != null ? '' : null,
        ),
      ),
    );
  }
}
