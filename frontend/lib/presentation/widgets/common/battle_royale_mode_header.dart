import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';

class BattleRoyaleModeHeader extends StatelessWidget {
  final VoidCallback onBack;

  const BattleRoyaleModeHeader({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Pixel.arrowbarleft, color: Colors.white),
            onPressed: onBack,
          ),
          const Expanded(
            child: Text(
              'SINH TỬ CHIẾN',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
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
