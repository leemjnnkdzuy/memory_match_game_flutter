import 'package:flutter/material.dart';
import '../../../data/models/battle_royale_room_model.dart';
import 'package:pixelarticons/pixel.dart';

class RoomCardWidget extends StatelessWidget {
  final BattleRoyaleRoom room;
  final VoidCallback onTap;

  const RoomCardWidget({super.key, required this.room, required this.onTap});

  Color _getStatusColor() {
    switch (room.status) {
      case RoomStatus.waiting:
        return Colors.green;
      case RoomStatus.starting:
        return Colors.orange;
      case RoomStatus.inProgress:
        return Colors.blue;
      case RoomStatus.finished:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (room.status) {
      case RoomStatus.waiting:
        return 'Đang chờ';
      case RoomStatus.starting:
        return 'Chuẩn bị';
      case RoomStatus.inProgress:
        return 'Đang chơi';
      case RoomStatus.finished:
        return 'Đã kết thúc';
    }
  }

  @override
  Widget build(BuildContext context) {
    final canJoin = room.status == RoomStatus.waiting && !room.isFull;

    return GestureDetector(
      onTap: canJoin ? onTap : null,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: canJoin ? Colors.white : Colors.grey[200],
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: canJoin
              ? [
                  BoxShadow(
                    color: Colors.black,
                    offset: const Offset(4, 4),
                    blurRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      room.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: canJoin ? Colors.black : Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (room.hasPassword)
                    Icon(
                      Pixel.lock,
                      size: 16,
                      color: canJoin ? Colors.orange : Colors.grey[600],
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Room Code
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  border: Border.all(color: Colors.grey[600]!, width: 1),
                ),
                child: Text(
                  'Mã: ${room.code}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Room Info
              Row(
                children: [
                  // Players
                  _buildInfoChip(
                    Pixel.users,
                    '${room.currentPlayers}/${room.maxPlayers}',
                    room.isFull ? Colors.red : Colors.blue,
                  ),
                  const SizedBox(width: 8),

                  // Pairs
                  _buildInfoChip(
                    Pixel.grid,
                    '${room.pairCount} cặp',
                    Colors.purple,
                  ),
                  const SizedBox(width: 8),

                  // Time
                  _buildInfoChip(
                    Pixel.clock,
                    '${room.softCapTime}s',
                    Colors.orange,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Status
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getStatusColor(),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black, width: 2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getStatusText(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(),
                    ),
                  ),
                  const Spacer(),
                  if (!canJoin)
                    Text(
                      room.isFull ? 'ĐẦY' : 'KHÔNG THỂ THAM GIA',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
