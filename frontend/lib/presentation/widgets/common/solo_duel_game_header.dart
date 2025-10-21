import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../../../domain/entities/solo_duel_match_entity.dart';
import './player_avatar_card_widget.dart';
import './solo_duel_dialog_widgets.dart';

class SoloDuelGameHeader extends StatelessWidget {
  final PlayerEntity me;
  final PlayerEntity opponent;
  final bool isMyTurn;
  final bool isGameStarted;
  final Uint8List? myAvatarBytes;
  final Uint8List? opponentAvatarBytes;
  final VoidCallback onPause;
  final VoidCallback onSurrender;

  const SoloDuelGameHeader({
    super.key,
    required this.me,
    required this.opponent,
    required this.isMyTurn,
    required this.isGameStarted,
    this.myAvatarBytes,
    this.opponentAvatarBytes,
    required this.onPause,
    required this.onSurrender,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: PlayerAvatarCardWidget(
              username: me.username,
              score: me.score,
              matchedCards: me.matchedCards,
              avatarBytes: myAvatarBytes,
              isMe: true,
              isActive: isMyTurn && isGameStarted,
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: IconButton(
              icon: const Icon(Icons.pause_circle_filled, size: 48),
              color: Colors.white,
              onPressed: () {
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
              },
            ),
          ),

          Expanded(
            child: PlayerAvatarCardWidget(
              username: opponent.username,
              score: opponent.score,
              matchedCards: opponent.matchedCards,
              avatarBytes: opponentAvatarBytes,
              isMe: false,
              isActive: !isMyTurn && isGameStarted,
            ),
          ),
        ],
      ),
    );
  }
}
