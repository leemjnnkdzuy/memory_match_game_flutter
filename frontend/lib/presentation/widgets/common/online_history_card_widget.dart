import 'package:flutter/material.dart';
import 'dart:math';
import '../../../domain/entities/history_entity.dart';

class OnlineHistoryCard extends StatefulWidget {
  final HistoryEntity history;
  final String? currentUserId;
  final VoidCallback? onTap;

  const OnlineHistoryCard({
    super.key,
    required this.history,
    this.currentUserId,
    this.onTap,
  });

  @override
  State<OnlineHistoryCard> createState() => _OnlineHistoryCardState();
}

class _OnlineHistoryCardState extends State<OnlineHistoryCard>
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

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year;
    final hour = local.hour.toString().padLeft(2, '0');
    final minute = local.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }

  bool _isWinner() {
    // Dùng isWin từ history entity trực tiếp
    return widget.history.isWin ?? false;
  }

  IconData _getIcon() {
    return _isWinner() ? Icons.emoji_events : Icons.group;
  }

  Color _getColor() {
    return _isWinner() ? Colors.amber.shade600 : Colors.red;
  }

  String _getOpponentName() {
    return widget.history.user?.username ?? 'Người chơi';
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes;
    final secs = duration.inSeconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isWinner = _isWinner();

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
                        // Tiêu đề - Online match
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
                                isWinner ? 'THẮNG' : 'THUA',
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
                            'Điểm: ${widget.history.score ?? 0}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Thời gian
                        if (widget.history.timeElapsed != null)
                          Text(
                            'Thời gian: ${_formatDuration(widget.history.timeElapsed!)}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white70,
                            ),
                          ),
                        const SizedBox(height: 4),
                        if (widget.history.datePlayed != null)
                          Text(
                            _formatDate(widget.history.datePlayed!),
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
