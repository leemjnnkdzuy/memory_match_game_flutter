import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

enum CustomButtonType { primary, normal, warning, error, success }

class CustomButton extends StatelessWidget {
  final CustomButtonType type;
  final VoidCallback? onPressed;
  final Widget child;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.type,
    required this.onPressed,
    required this.child,
    this.isLoading = false,
  });

  bool get _hasAction => onPressed != null;
  bool get _isEnabled => _hasAction && !isLoading;

  Color get _backgroundColor {
    switch (type) {
      case CustomButtonType.primary:
        return AppTheme.primaryColor;
      case CustomButtonType.normal:
        return Colors.grey[300]!;
      case CustomButtonType.warning:
        return Colors.orange;
      case CustomButtonType.error:
        return AppTheme.errorColor;
      case CustomButtonType.success:
        return Colors.green;
    }
  }

  Color get _textColor {
    switch (type) {
      case CustomButtonType.primary:
      case CustomButtonType.warning:
      case CustomButtonType.error:
      case CustomButtonType.success:
        return Colors.white;
      case CustomButtonType.normal:
        return Colors.black87;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showActiveStyle = (_isEnabled || (isLoading && _hasAction));
    final Color backgroundColor =
        showActiveStyle ? _backgroundColor : Colors.grey[400]!;
    final Color textColor = showActiveStyle ? _textColor : Colors.grey[600]!;

    return Container(
      constraints: const BoxConstraints(minWidth: 80, minHeight: 40),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black, width: 3),
        boxShadow: showActiveStyle
            ? [
                BoxShadow(
                  color: Colors.black,
                  offset: const Offset(4, 4),
                  blurRadius: 0,
                ),
              ]
            : null,
      ),
      child: Material(
        color: backgroundColor,
        child: InkWell(
          onTap: _isEnabled ? onPressed : null,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Center(
              child: DefaultTextStyle(
                style: TextStyle(
                  fontFamily: 'AlanSans',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                textAlign: TextAlign.center,
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
