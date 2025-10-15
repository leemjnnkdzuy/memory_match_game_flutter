import 'package:flutter/material.dart';
import '../../../data/models/battle_royale_player_model.dart';
import 'package:pixelarticons/pixel.dart';

class PlayerCardWidget extends StatelessWidget {
  final BattleRoyalePlayer player;
  final bool isCurrentUser;
  final VoidCallback? onKick;

  const PlayerCardWidget({
    super.key,
    required this.player,
    this.isCurrentUser = false,
    this.onKick,
  });

  Color _getBorderColor() {
    try {
      final colorStr = player.borderColor.replaceAll('#', '');
      return Color(int.parse('FF$colorStr', radix: 16));
    } catch (e) {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _getBorderColor(), width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getBorderColor().withOpacity(0.2),
                border: Border.all(color: _getBorderColor(), width: 2),
              ),
              child: player.avatarUrl != null
                  ? Image.network(player.avatarUrl!, fit: BoxFit.cover)
                  : Icon(Pixel.user, color: _getBorderColor(), size: 24),
            ),
            const SizedBox(width: 12),

            // Player Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          player.username,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (player.isHost) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.star, color: Colors.orange, size: 16),
                      ],
                      if (isCurrentUser) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            border: Border.all(color: Colors.blue, width: 1),
                          ),
                          child: const Text(
                            'BẠN',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (player.ping != null) ...[
                        Icon(
                          Icons.wifi,
                          size: 12,
                          color: player.ping! < 50
                              ? Colors.green
                              : player.ping! < 100
                              ? Colors.orange
                              : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${player.ping}ms',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                      if (!player.isConnected) ...[
                        const SizedBox(width: 8),
                        const Icon(Pixel.close, color: Colors.red, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          'Mất kết nối',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.red[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Ready Status
            if (player.isReady)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: const Icon(Pixel.check, color: Colors.green, size: 16),
              )
            else if (!player.isHost)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  border: Border.all(color: Colors.grey, width: 2),
                ),
                child: Icon(Pixel.clock, color: Colors.grey[600], size: 16),
              ),

            // Kick Button (for host)
            if (onKick != null && !player.isHost) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onKick,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    border: Border.all(color: Colors.red, width: 2),
                  ),
                  child: const Icon(Pixel.close, color: Colors.red, size: 16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
