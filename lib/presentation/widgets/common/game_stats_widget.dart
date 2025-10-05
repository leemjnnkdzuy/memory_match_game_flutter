import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class GameStatsWidget extends StatelessWidget {
  final Duration timeRemaining;
  final int score;
  final int moves;

  const GameStatsWidget({
    super.key,
    required this.timeRemaining,
    required this.score,
    required this.moves,
  });

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            label: 'THỜI GIAN',
            value: _formatTime(timeRemaining),
            color: Colors.red,
          ),
          _StatItem(
            label: 'ĐIỂM',
            value: score.toString(),
            color: Colors.green,
          ),
          _StatItem(
            label: 'NƯỚC ĐI',
            value: moves.toString(),
            color: Colors.blue,
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTheme.labelLarge.copyWith(
            color: const Color.fromARGB(255, 255, 255, 255),
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: AppTheme.headlineSmall.copyWith(color: color)),
      ],
    );
  }
}
