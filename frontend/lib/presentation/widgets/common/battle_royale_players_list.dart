import 'package:flutter/material.dart';
import 'player_card_widget.dart';
import '../../../data/models/battle_royale_player_model.dart';

class BattleRoyalePlayersList extends StatelessWidget {
  final List<BattleRoyalePlayer> players;
  final String? currentUserId;
  final bool isHost;
  final Future<void> Function(String) onKick;

  const BattleRoyalePlayersList({
    super.key,
    required this.players,
    required this.currentUserId,
    required this.isHost,
    required this.onKick,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'NGƯỜI CHƠI',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: players.isEmpty
                  ? const Center(
                      child: Text(
                        'Đang tải...',
                        style: TextStyle(color: Colors.white70),
                      ),
                    )
                  : ListView.builder(
                      itemCount: players.length,
                      itemBuilder: (context, index) {
                        final player = players[index];
                        return PlayerCardWidget(
                          player: player,
                          isCurrentUser: player.id == currentUserId,
                          onKick: isHost && player.id != currentUserId
                              ? () => onKick(player.id)
                              : null,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
