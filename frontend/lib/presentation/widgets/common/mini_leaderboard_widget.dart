import 'package:flutter/material.dart';
import '../../../data/models/battle_royale_player_model.dart';

class MiniLeaderboardWidget extends StatelessWidget {
  final List<BattleRoyalePlayer> players;
  final String? currentUserId;

  const MiniLeaderboardWidget({
    super.key,
    required this.players,
    this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    // Sort by score descending
    final sortedPlayers = List<BattleRoyalePlayer>.from(players)
      ..sort((a, b) {
        if (a.score != b.score) return b.score.compareTo(a.score);
        if (a.completionTime != b.completionTime)
          return a.completionTime.compareTo(b.completionTime);
        return a.flipCount.compareTo(b.flipCount);
      });

    return Container(
      width: 200,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'BẢNG XẾP HẠNG',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...sortedPlayers.take(5).map((player) {
            final rank = sortedPlayers.indexOf(player) + 1;
            final isCurrentUser = player.id == currentUserId;

            return Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: isCurrentUser
                    ? Colors.blue.withOpacity(0.5)
                    : Colors.transparent,
                border: Border.all(
                  color: isCurrentUser
                      ? Colors.blue
                      : Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Rank
                  SizedBox(
                    width: 16,
                    child: Text(
                      '#$rank',
                      style: TextStyle(
                        color: rank <= 3 ? Colors.yellow : Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),

                  // Name
                  Expanded(
                    child: Text(
                      player.username,
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Score or Status
                  Text(
                    player.isFinished
                        ? '${player.score.toInt()}'
                        : '${player.pairsFound}/8',
                    style: TextStyle(
                      color: player.isFinished
                          ? Colors.greenAccent
                          : Colors.grey,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
