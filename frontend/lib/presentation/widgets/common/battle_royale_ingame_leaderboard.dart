import 'package:flutter/material.dart';

import '../../../data/models/battle_royale_player_model.dart';

class BattleRoyaleIngameLeaderboard extends StatelessWidget {
  final List<BattleRoyalePlayer> players;
  final String? currentUserId;
  final int totalPairs;
  final int maxVisible;

  const BattleRoyaleIngameLeaderboard({
    super.key,
    required this.players,
    this.currentUserId,
    required this.totalPairs,
    this.maxVisible = 5,
  });

  @override
  Widget build(BuildContext context) {
    if (players.isEmpty) {
      return _buildEmptyState();
    }

    final sortedPlayers = List<BattleRoyalePlayer>.from(players)
      ..sort(_comparePlayers);
    final finishedCount = sortedPlayers
        .where((player) => player.isFinished)
        .length;
    final visibleCount = sortedPlayers.length > maxVisible
        ? maxVisible
        : sortedPlayers.length;

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 240, maxWidth: 340),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE91E63), Color(0xFF880E4F)],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(finishedCount, sortedPlayers.length),
            const SizedBox(height: 12),
            ...List.generate(visibleCount, (index) {
              final player = sortedPlayers[index];
              final isCurrentUser = player.id == currentUserId;
              final rank = index + 1;
              return _LeaderboardEntry(
                player: player,
                rank: rank,
                totalPairs: totalPairs,
                isCurrentUser: isCurrentUser,
              );
            }),
            if (sortedPlayers.length > visibleCount)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  '+${sortedPlayers.length - maxVisible} more players',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int finishedCount, int totalPlayers) {
    return Row(
      children: [
        const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
        const SizedBox(width: 8),
        const Text(
          'LEADERBOARD',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            letterSpacing: 1.2,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(Icons.flag, color: Colors.white, size: 14),
              const SizedBox(width: 6),
              Text(
                '$finishedCount/$totalPlayers',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 220, maxWidth: 320),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.leaderboard, color: Colors.white.withValues(alpha: 0.6)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Waiting for player stats...',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static int _comparePlayers(BattleRoyalePlayer a, BattleRoyalePlayer b) {
    if (a.isFinished != b.isFinished) {
      return a.isFinished ? -1 : 1;
    }

    if (a.isFinished && b.isFinished) {
      final scoreCompare = b.score.compareTo(a.score);
      if (scoreCompare != 0) return scoreCompare;

      final timeCompare = a.completionTime.compareTo(b.completionTime);
      if (timeCompare != 0) return timeCompare;

      final flipCompare = a.flipCount.compareTo(b.flipCount);
      if (flipCompare != 0) return flipCompare;
    }

    final pairsCompare = b.pairsFound.compareTo(a.pairsFound);
    if (pairsCompare != 0) return pairsCompare;

    final flipCompare = a.flipCount.compareTo(b.flipCount);
    if (flipCompare != 0) return flipCompare;

    return a.username.toLowerCase().compareTo(b.username.toLowerCase());
  }
}

class _LeaderboardEntry extends StatelessWidget {
  final BattleRoyalePlayer player;
  final int rank;
  final int totalPairs;
  final bool isCurrentUser;

  const _LeaderboardEntry({
    required this.player,
    required this.rank,
    required this.totalPairs,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isCurrentUser
              ? [
                  Colors.amber.withValues(alpha: 0.35),
                  Colors.deepOrange.withValues(alpha: 0.25),
                ]
              : [
                  Colors.white.withValues(alpha: 0.12),
                  Colors.white.withValues(alpha: 0.04),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentUser
              ? Colors.amberAccent.withValues(alpha: 0.8)
              : Colors.white.withValues(alpha: 0.25),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildRankBadge(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        player.username,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: isCurrentUser
                              ? FontWeight.w700
                              : FontWeight.w600,
                          fontSize: 14,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrentUser)
                      _buildTagChip(label: 'YOU', color: Colors.amber),
                    if (player.isFinished) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.check_circle,
                        color: Colors.greenAccent,
                        size: 18,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _StatTile(
                      icon: Icons.catching_pokemon,
                      label: '${player.pairsFound}/$totalPairs pairs',
                    ),
                    const SizedBox(width: 10),
                    _StatTile(
                      icon: Icons.refresh,
                      label: '${player.flipCount} flips',
                    ),
                    if (player.isFinished) ...[
                      const SizedBox(width: 10),
                      _StatTile(
                        icon: Icons.timer,
                        label: '${player.completionTime}s',
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _buildScoreBlock(),
        ],
      ),
    );
  }

  Widget _buildRankBadge() {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: _rankColor(rank),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        _rankLabel(rank),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: rank <= 3 ? 20 : 14,
        ),
      ),
    );
  }

  Widget _buildScoreBlock() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'SCORE',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 10,
              letterSpacing: 0.6,
            ),
          ),
          Text(
            player.score.toInt().toString(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTagChip({required String label, required Color color}) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Color _rankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.blueGrey.shade300;
      case 3:
        return Colors.deepOrange.shade300;
      default:
        return Colors.white.withValues(alpha: 0.2);
    }
  }

  String _rankLabel(int rank) {
    switch (rank) {
      case 1:
        return '1ST';
      case 2:
        return '2ND';
      case 3:
        return '3RD';
      default:
        return '#$rank';
    }
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatTile({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.white.withValues(alpha: 0.7)),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.75),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
