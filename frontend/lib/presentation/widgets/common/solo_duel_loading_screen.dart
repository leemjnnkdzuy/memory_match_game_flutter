import 'package:flutter/material.dart';

class SoloDuelLoadingScreen extends StatelessWidget {
  final String message;

  const SoloDuelLoadingScreen({super.key, this.message = 'Loading match...'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(message),
          ],
        ),
      ),
    );
  }
}
