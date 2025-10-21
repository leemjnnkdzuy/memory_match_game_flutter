import 'package:flutter/material.dart';
import './solo_duel_dialog_widgets.dart';

class SoloDuelDialogManager {
  static void showSurrenderConfirmation(
    BuildContext context, {
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SoloDuelSurrenderConfirmationDialog(
        onCancel: () => Navigator.pop(context),
        onConfirm: () {
          Navigator.pop(context);
          onConfirm();
        },
      ),
    );
  }

  static void showOpponentDisconnected(
    BuildContext context, {
    required String opponentUsername,
    required int waitTimeSeconds,
    required VoidCallback onClose,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: SoloDuelOpponentDisconnectedDialog(
          opponentUsername: opponentUsername,
          waitTimeSeconds: waitTimeSeconds,
          onClose: () {
            Navigator.pop(context);
            onClose();
          },
        ),
      ),
    );
  }

  static void showGameOver(
    BuildContext context, {
    required bool isWinner,
    required String winnerUsername,
    required int winnerScore,
    required int winnerMatchedCards,
    required String loserUsername,
    required int loserScore,
    required int loserMatchedCards,
    required VoidCallback onBackToHome,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => SoloDuelGameOverDialog(
        isWinner: isWinner,
        winnerUsername: winnerUsername,
        winnerScore: winnerScore,
        winnerMatchedCards: winnerMatchedCards,
        loserUsername: loserUsername,
        loserScore: loserScore,
        loserMatchedCards: loserMatchedCards,
        onBackToHome: () {
          Navigator.pop(context);
          onBackToHome();
        },
      ),
    );
  }

  static void showPause(
    BuildContext context, {
    required VoidCallback onSurrender,
  }) {
    showDialog(
      context: context,
      builder: (context) => SoloDuelPauseDialog(
        onResume: () => Navigator.pop(context),
        onSurrender: () {
          Navigator.pop(context);
          onSurrender();
        },
      ),
    );
  }
}
