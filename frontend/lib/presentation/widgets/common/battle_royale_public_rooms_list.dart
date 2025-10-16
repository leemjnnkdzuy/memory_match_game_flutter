import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import 'room_card_widget.dart';
import '../../../data/models/battle_royale_room_model.dart';

class BattleRoyalePublicRoomsList extends StatelessWidget {
  final List<BattleRoyaleRoom> rooms;
  final bool isLoading;
  final void Function(String) onJoinRoom;

  const BattleRoyalePublicRoomsList({
    super.key,
    required this.rooms,
    required this.isLoading,
    required this.onJoinRoom,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (rooms.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Pixel.users, size: 64, color: Colors.white54),
              const SizedBox(height: 16),
              const Text(
                'Không có phòng nào',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Hãy thử tạo một phòng mới!',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rooms.length,
      itemBuilder: (context, index) {
        final room = rooms[index];
        return RoomCardWidget(room: room, onTap: () => onJoinRoom(room.id));
      },
    );
  }
}
