import 'package:flutter/material.dart';
import '../widgets/common/battle_royale_mode_header.dart';
import '../widgets/common/battle_royale_mode_content.dart';
import 'battle_royale_create_room_screen.dart';
import 'battle_royale_join_room_screen.dart';

class BattleRoyaleModeScreen extends StatelessWidget {
  const BattleRoyaleModeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE91E63), Color(0xFF880E4F)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              BattleRoyaleModeHeader(onBack: () => Navigator.pop(context)),

              BattleRoyaleModeContent(
                onCreateRoom: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const BattleRoyaleCreateRoomScreen(),
                    ),
                  );
                },
                onJoinRoom: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BattleRoyaleJoinRoomScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
