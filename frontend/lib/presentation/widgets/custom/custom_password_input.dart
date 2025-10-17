import 'package:flutter/material.dart';
import 'custom_text_input.dart';

class CustomPasswordInput extends StatefulWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool enabled;
  final double fontSize;
  final Color? borderColor;
  final double borderWidth;
  final TextAlign textAlign;
  final int? maxLength;
  final TextInputType keyboardType;

  const CustomPasswordInput({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.fontSize = 14,
    this.borderColor,
    this.borderWidth = 3,
    this.textAlign = TextAlign.start,
    this.maxLength,
    this.keyboardType = TextInputType.text,
  });

  @override
  State<CustomPasswordInput> createState() => _CustomPasswordInputState();
}

class _CustomPasswordInputState extends State<CustomPasswordInput> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return CustomTextInput(
      controller: widget.controller,
      hintText: widget.hintText,
      labelText: widget.labelText,
      obscureText: _obscureText,
      onChanged: widget.onChanged,
      validator: widget.validator,
      enabled: widget.enabled,
      fontSize: widget.fontSize,
      borderColor: widget.borderColor,
      borderWidth: widget.borderWidth,
      textAlign: widget.textAlign,
      maxLength: widget.maxLength,
      keyboardType: widget.keyboardType,
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility_off : Icons.visibility,
          size: 20,
        ),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      ),
    );
  }
}
