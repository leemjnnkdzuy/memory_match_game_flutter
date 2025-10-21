import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';

class CustomHeader extends StatelessWidget {
  final VoidCallback onBack;
  final Color textColor;
  final String title;

  const CustomHeader({
    super.key,
    required this.onBack,
    required this.title,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Pixel.arrowbarleft, color: textColor),
            onPressed: onBack,
          ),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
