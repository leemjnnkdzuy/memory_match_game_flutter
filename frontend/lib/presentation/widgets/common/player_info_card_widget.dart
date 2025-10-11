import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import 'dart:convert';
import '../../../core/theme/app_theme.dart';

class PlayerInfoCardWidget extends StatelessWidget {
  final String? username;
  final String? avatar;

  const PlayerInfoCardWidget({super.key, this.username, this.avatar});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primaryColor, width: 5),
            ),
            child: avatar != null
                ? ClipOval(
                    child: Image.memory(
                      (() {
                        String base64String = avatar!;
                        if (base64String.startsWith('data:image/')) {
                          base64String = base64String.split(',').last;
                        }
                        return base64Decode(base64String);
                      })(),
                      width: 128,
                      height: 128,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Pixel.user,
                        size: 128,
                        color: Colors.orange.shade700,
                      ),
                    ),
                  )
                : ClipOval(
                    child: Icon(
                      Pixel.user,
                      size: 128,
                      color: Colors.orange.shade700,
                    ),
                  ),
          ),
          const SizedBox(height: 16),
          Text(
            username ?? 'Người chơi',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
