import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';
import '../../../data/models/battle_royale_player_model.dart';
import 'package:pixelarticons/pixel.dart';

class PlayerCardWidget extends StatefulWidget {
  final BattleRoyalePlayer player;
  final bool isCurrentUser;
  final VoidCallback? onKick;

  const PlayerCardWidget({
    super.key,
    required this.player,
    this.isCurrentUser = false,
    this.onKick,
  });

  @override
  State<PlayerCardWidget> createState() => _PlayerCardWidgetState();
}

class _PlayerCardWidgetState extends State<PlayerCardWidget> {
  Uint8List? _cachedAvatarBytes;

  @override
  void initState() {
    super.initState();
    _decodeAvatar();
  }

  @override
  void didUpdateWidget(PlayerCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.player.avatarUrl != widget.player.avatarUrl) {
      _decodeAvatar();
    }
  }

  void _decodeAvatar() {
    if (widget.player.avatarUrl == null || widget.player.avatarUrl!.isEmpty) {
      _cachedAvatarBytes = null;
      return;
    }

    try {
      String base64String = widget.player.avatarUrl!;
      if (base64String.contains('base64,')) {
        base64String = base64String.split('base64,').last;
      }

      _cachedAvatarBytes = base64Decode(base64String);
    } catch (e) {
      _cachedAvatarBytes = null;
    }
  }

  Color _getBorderColor() {
    try {
      final colorStr = widget.player.borderColor.replaceAll('#', '');
      return Color(int.parse('FF$colorStr', radix: 16));
    } catch (e) {
      return Colors.green;
    }
  }

  Widget _buildAvatar() {
    if (_cachedAvatarBytes == null) {
      return Icon(Pixel.user, color: _getBorderColor(), size: 24);
    }

    return Image.memory(
      _cachedAvatarBytes!,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Icon(Pixel.user, color: _getBorderColor(), size: 24);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _getBorderColor(), width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getBorderColor().withOpacity(0.2),
                border: Border.all(color: _getBorderColor(), width: 2),
              ),
              child: _buildAvatar(),
            ),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          widget.player.username,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (widget.player.isHost) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.star, color: Colors.orange, size: 16),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (widget.player.ping != null) ...[
                        Icon(
                          Icons.wifi,
                          size: 12,
                          color: widget.player.ping! < 50
                              ? Colors.green
                              : widget.player.ping! < 100
                              ? Colors.orange
                              : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.player.ping}ms',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                      if (!widget.player.isConnected) ...[
                        const SizedBox(width: 8),
                        const Icon(Pixel.close, color: Colors.red, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          'Mất kết nối',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.red[600],
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Ready Status
            if (widget.player.isReady)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: const Icon(Pixel.check, color: Colors.green, size: 16),
              )
            else if (!widget.player.isHost)
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  border: Border.all(color: Colors.grey, width: 2),
                ),
                child: Icon(Pixel.clock, color: Colors.grey[600], size: 16),
              ),

            // Kick Button (for host)
            if (widget.onKick != null && !widget.player.isHost) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: widget.onKick,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    border: Border.all(color: Colors.red, width: 2),
                  ),
                  child: const Icon(Pixel.close, color: Colors.red, size: 16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
