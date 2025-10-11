import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import 'dart:typed_data';

class PlayerAvatarCardWidget extends StatelessWidget {
  final String username;
  final int score;
  final int matchedCards;
  final Uint8List? avatarBytes;
  final bool isMe;
  final bool isActive;

  const PlayerAvatarCardWidget({
    super.key,
    required this.username,
    required this.score,
    required this.matchedCards,
    this.avatarBytes,
    required this.isMe,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: isActive ? (isMe ? Colors.blue : Colors.orange) : Colors.black,
          width: isActive ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            offset: const Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar Image
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isActive
                    ? (isMe ? Colors.blue : Colors.orange)
                    : Colors.grey,
                width: 3,
              ),
            ),
            child: ClipOval(
              child: avatarBytes != null
                  ? Image.memory(
                      avatarBytes!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Pixel.user,
                          size: 48,
                          color: isActive
                              ? (isMe ? Colors.blue : Colors.orange)
                              : Colors.grey,
                        );
                      },
                    )
                  : Icon(
                      Pixel.user,
                      size: 48,
                      color: isActive
                          ? (isMe ? Colors.blue : Colors.orange)
                          : Colors.grey,
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isMe ? 'Bạn' : username,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          const SizedBox(height: 4),
          Text(
            '$score điểm',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          Text(
            '$matchedCards cặp',
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
