import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Pixel.trophy, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Bảng xếp hạng sắp ra mắt',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
