import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import '../../../data/models/battle_royale_room_model.dart';

class BattleRoyaleLobbyHeader extends StatelessWidget {
  final BattleRoyaleRoom room;
  final Future<void> Function() onBack;

  const BattleRoyaleLobbyHeader({
    super.key,
    required this.room,
    required this.onBack,
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
          Expanded(
            child: Column(
              children: [
                Text(
                  room.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                  child: Text(
                    'Mã: ${room.code}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
