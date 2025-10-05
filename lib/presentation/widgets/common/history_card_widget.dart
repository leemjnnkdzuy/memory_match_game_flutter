import 'package:flutter/material.dart';
import 'dart:math';

class HistoryCard extends StatefulWidget {
  final String difficulty;
  final bool isWin;
  final int score;
  final int moves;
  final int timeElapsed;
  final DateTime datePlayed;
  final VoidCallback? onTap;

  const HistoryCard({
    super.key,
    required this.difficulty,
    required this.isWin,
    required this.score,
    required this.moves,
    required this.timeElapsed,
    required this.datePlayed,
    this.onTap,
  });

  @override
  State<HistoryCard> createState() => _HistoryCardState();
}

class _HistoryCardState extends State<HistoryCard>
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

  String _getDifficultyText(String difficulty) {
    const map = {
      'veryEasy': 'Very Easy',
      'easy': 'Easy',
      'normal': 'Normal',
      'medium': 'Medium',
      'hard': 'Hard',
      'superHard': 'Very Hard',
      'insane': 'Insane',
      'expert': 'Expert',
    };
    return map[difficulty] ?? difficulty;
  }

  String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes;
    final secs = duration.inSeconds % 60;
    return '${minutes}:${secs.toString().padLeft(2, '0')}';
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
    if (widget.isWin) {
      return Icons.check_circle;
    } else {
      return Icons.cancel;
    }
  }

  Color _getColor() {
    return widget.isWin ? Colors.green : Colors.red;
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
                  Icon(
                    _getIcon(),
                    size: 60,
                    color: const Color.fromARGB(255, 255, 255, 255),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getDifficultyText(widget.difficulty),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Score: ${widget.score} | Moves: ${widget.moves} | Time: ${_formatDuration(widget.timeElapsed)}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white70,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(widget.datePlayed),
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
