import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';

class BattleRoyaleJoinRoomHeader extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onRefresh;

  const BattleRoyaleJoinRoomHeader({
    super.key,
    required this.onBack,
    required this.onRefresh,
  });

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
              'THAM GIA PHÒNG',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Pixel.reload, color: Colors.white),
            onPressed: onRefresh,
          ),
        ],
      ),
    );
  }
}
