import 'package:flutter/material.dart';
import 'dart:math';
import '../../../domain/entities/battle_royale_history_entity.dart';
import '../../../core/theme/app_theme.dart';

class BattleRoyaleHistoryCard extends StatefulWidget {
  final BattleRoyaleHistoryEntity history;
  final VoidCallback? onTap;

  const BattleRoyaleHistoryCard({super.key, required this.history, this.onTap});

  @override
  State<BattleRoyaleHistoryCard> createState() =>
      _BattleRoyaleHistoryCardState();
}

class _BattleRoyaleHistoryCardState extends State<BattleRoyaleHistoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    widget.onTap?.call();
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year;
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  IconData _getIcon() {
    if (widget.history.rank == 1) return Icons.emoji_events;
    if (widget.history.rank <= 3) return Icons.military_tech;
    return Icons.groups;
  }

  Color _getColor() {
    if (widget.history.rank == 1) return Colors.amber.shade600;
    if (widget.history.rank == 2) return Colors.grey.shade600;
    if (widget.history.rank == 3) return Colors.orange.shade600;
    return const Color(0xFFE91E63);
  }

  String _getRankEmoji() {
    switch (widget.history.rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '#${widget.history.rank}';
    }
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes;
    final secs = duration.inSeconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shakeAnimation,
      builder: (context, child) {
        final offset = sin(_shakeAnimation.value * 3.14159 * 8) * 3;
        return Transform.translate(
          offset: Offset(offset, 0),
          child: GestureDetector(
            onTap: _handleTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _getColor(),
                border: Border.all(color: Colors.black, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    offset: const Offset(4, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Icon phần bên trái
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: Center(
                          child: Icon(_getIcon(), size: 32, color: _getColor()),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Nội dung chính
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tiêu đề - Battle Royale
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 2,
                                    ),
                                  ),
                                  child: Text(
                                    'BATTLE ROYALE',
                                    style: AppTheme.labelLarge.copyWith(
                                      color: _getColor(),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black.withValues(
                                        alpha: 0.3,
                                      ),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.5,
                                        ),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text(
                                      _getRankEmoji(),
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Thông tin người chơi
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.2),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                '${widget.history.totalPlayers} người chơi • Điểm: ${widget.history.score}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Thống kê
                            Wrap(
                              spacing: 8,
                              runSpacing: 4,
                              children: [
                                Text(
                                  'Cặp: ${widget.history.pairsFound}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white70,
                                  ),
                                ),
                                Text(
                                  'Lật: ${widget.history.flipCount}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white70,
                                  ),
                                ),
                                Text(
                                  'TG: ${_formatDuration(widget.history.completionTime)}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(widget.history.datePlayed),
                              style: const TextStyle(
                                fontSize: 10,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Expanded leaderboard
                  if (_isExpanded && widget.history.players != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.black, width: 2),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'BẢNG XẾP HẠNG',
                            style: AppTheme.labelLarge.copyWith(
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...widget.history.players!.map((player) {
                            final isCurrentUser =
                                player.userId == widget.history.userId;
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isCurrentUser
                                    ? Colors.amber[50]
                                    : Colors.grey[100],
                                border: Border.all(
                                  color: Colors.black,
                                  width: isCurrentUser ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: _getRankColorForPlayer(
                                        player.rank,
                                      ),
                                      border: Border.all(
                                        color: Colors.black,
                                        width: 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        player.rank <= 3
                                            ? _getRankEmojiForRank(player.rank)
                                            : '#${player.rank}',
                                        style: TextStyle(
                                          fontSize: player.rank <= 3 ? 16 : 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          player.username,
                                          style: AppTheme.bodyMedium.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: isCurrentUser ? 13 : 12,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'Điểm: ${player.score} • Cặp: ${player.pairsFound}',
                                          style: AppTheme.bodyMedium.copyWith(
                                            fontSize: 10,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (isCurrentUser)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.amber,
                                        border: Border.all(
                                          color: Colors.black,
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        'BẠN',
                                        style: AppTheme.labelLarge.copyWith(
                                          fontSize: 8,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _getRankColorForPlayer(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber[300]!;
      case 2:
        return Colors.grey[300]!;
      case 3:
        return Colors.orange[300]!;
      default:
        return AppTheme.primaryColor.withValues(alpha: 0.3);
    }
  }

  String _getRankEmojiForRank(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '#$rank';
    }
  }
}
