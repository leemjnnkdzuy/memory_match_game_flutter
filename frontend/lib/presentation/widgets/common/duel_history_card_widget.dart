import 'package:flutter/material.dart';
import 'dart:math';
import '../../../domain/entities/solo_duel_history_entity.dart';

class DuelHistoryCard extends StatefulWidget {
  final SoloDuelHistoryEntity history;
  final VoidCallback? onTap;

  const DuelHistoryCard({super.key, required this.history, this.onTap});

  @override
  State<DuelHistoryCard> createState() => _DuelHistoryCardState();
}

class _DuelHistoryCardState extends State<DuelHistoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

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
    widget.onTap?.call();
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes;
    final secs = duration.inSeconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
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
    if (widget.history.isWin) {
      return Icons.emoji_events;
    } else {
      return Icons.cancel;
    }
  }

  Color _getColor() {
    return widget.history.isWin ? Colors.amber.shade600 : Colors.red;
  }

  String _getOpponentName() {
    return widget.history.opponent?.username ?? 'Người chơi';
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
              constraints: const BoxConstraints(minHeight: 120),
              decoration: BoxDecoration(
                color: _getColor(),
                borderRadius: BorderRadius.circular(0),
                border: Border.all(color: Colors.black, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    offset: const Offset(4, 4),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Row(
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
                        // Tiêu đề - Thắng/Thua
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
                                widget.history.isWin ? 'THẮNG' : 'THUA',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: _getColor(),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'vs ${_getOpponentName()}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Điểm số
                        Row(
                          children: [
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
                                'Điểm: ${widget.history.score}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
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
                                'Đối thủ: ${widget.history.opponentScore}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Thông tin chi tiết
                        Text(
                          'Cặp: ${widget.history.matchedCards} | Thời gian: ${_formatDuration(widget.history.gameTime)}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white70,
                          ),
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
            ),
          ),
        );
      },
    );
  }
}
