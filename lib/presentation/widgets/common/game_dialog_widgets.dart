import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/custom/custom_button.dart';

class GameEndDialogWidget extends StatelessWidget {
  final bool isWin;
  final int score;
  final int moves;
  final Duration gameTime;
  final VoidCallback onPlayAgain;
  final VoidCallback onBackToMenu;

  const GameEndDialogWidget({
    super.key,
    required this.isWin,
    required this.score,
    required this.moves,
    required this.gameTime,
    required this.onPlayAgain,
    required this.onBackToMenu,
  });

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        isWin ? 'CONGRATULATIONS!' : 'GAME OVER',
        style: AppTheme.headlineMedium.copyWith(
          color: isWin ? Colors.green : Colors.red,
        ),
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isWin
                ? 'You completed the game!'
                : 'Time\'s up! Better luck next time.',
            style: AppTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Text('Score: $score', style: AppTheme.bodyMedium),
          Text('Moves: $moves', style: AppTheme.bodyMedium),
          Text('Time: ${_formatTime(gameTime)}', style: AppTheme.bodyMedium),
        ],
      ),
      actions: [
        CustomButton(
          type: CustomButtonType.primary,
          onPressed: onPlayAgain,
          child: Text('PLAY AGAIN'),
        ),
        const SizedBox(height: 8),
        CustomButton(
          type: CustomButtonType.normal,
          onPressed: onBackToMenu,
          child: Text('BACK TO MENU'),
        ),
      ],
    );
  }
}

class GamePauseDialogWidget extends StatelessWidget {
  final int score;
  final int moves;
  final Duration timeRemaining;
  final VoidCallback onResume;
  final VoidCallback onQuit;

  const GamePauseDialogWidget({
    super.key,
    required this.score,
    required this.moves,
    required this.timeRemaining,
    required this.onResume,
    required this.onQuit,
  });

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'GAME PAUSED',
        style: AppTheme.headlineMedium,
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Score: $score', style: AppTheme.bodyMedium),
          Text('Moves: $moves', style: AppTheme.bodyMedium),
          Text(
            'Time Remaining: ${_formatTime(timeRemaining)}',
            style: AppTheme.bodyMedium,
          ),
        ],
      ),
      actions: [
        CustomButton(
          type: CustomButtonType.primary,
          onPressed: onResume,
          child: Text('RESUME'),
        ),
        const SizedBox(height: 8),
        CustomButton(
          type: CustomButtonType.error,
          onPressed: onQuit,
          child: Text('QUIT GAME'),
        ),
      ],
    );
  }
}
