import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import '../../../data/models/battle_royale_room_model.dart';

class BattleRoyaleRoomInfo extends StatelessWidget {
  final BattleRoyaleRoom room;
  final int playerCount;

  const BattleRoyaleRoomInfo({
    super.key,
    required this.room,
    required this.playerCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(Pixel.users, '$playerCount/${room.maxPlayers}'),
          _buildInfoItem(Pixel.grid, '${room.pairCount} cặp'),
          _buildInfoItem(Pixel.clock, '${room.softCapTime}s'),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFFE91E63)),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
