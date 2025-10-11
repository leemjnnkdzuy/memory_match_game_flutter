import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import '../../../domain/entities/solo_duel_match_entity.dart';
import '../custom/custom_button.dart';

class SoloDuelReadyScreenWidget extends StatelessWidget {
  final List<PlayerEntity> players;
  final String currentUserId;
  final int countdown;
  final bool isReady;
  final VoidCallback onSetReady;

  const SoloDuelReadyScreenWidget({
    super.key,
    required this.players,
    required this.currentUserId,
    required this.countdown,
    required this.isReady,
    required this.onSetReady,
  });

  @override
  Widget build(BuildContext context) {
    final allReady = players.every((p) => p.isReady);

    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
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
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Pixel.zap, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              'Sẵn sàng chiến đấu?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Thời gian còn lại: $countdown giây',
              style: const TextStyle(fontSize: 16, color: Colors.red),
            ),
            const SizedBox(height: 16),
            ...players.map((player) {
              final isMe = player.userId == currentUserId;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      player.isReady ? Pixel.check : Pixel.close,
                      color: player.isReady ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isMe ? 'Bạn' : player.username,
                      style: TextStyle(
                        fontWeight: player.isReady
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 24),
            if (!isReady)
              CustomButton(
                type: CustomButtonType.primary,
                onPressed: onSetReady,
                child: const Text('Sẵn sàng!'),
              )
            else if (!allReady)
              const Text(
                'Đang chờ đối thủ...',
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
          ],
        ),
      ),
    );
  }
}
