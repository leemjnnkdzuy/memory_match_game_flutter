import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import '../widgets/custom/custom_button.dart';
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
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Pixel.arrowbarleft, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'SINH TỬ CHIẾN',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // Balance the back button
                  ],
                ),
              ),

              // Content
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black,
                                offset: const Offset(6, 6),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Pixel.users,
                            size: 80,
                            color: Color(0xFFE91E63),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Description
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black, width: 3),
                          ),
                          child: const Text(
                            'Cạnh tranh với 2-8 người chơi!\n'
                            'Ai hoàn thành nhanh nhất với ít lỗi nhất sẽ chiến thắng!',
                            style: TextStyle(fontSize: 14, height: 1.5),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 40),

                        // Create Room Button
                        SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            type: CustomButtonType.primary,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const BattleRoyaleCreateRoomScreen(),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Pixel.plus, size: 16, color: Colors.white),
                                SizedBox(width: 8),
                                Text('TẠO PHÒNG'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Join Room Button
                        SizedBox(
                          width: double.infinity,
                          child: CustomButton(
                            type: CustomButtonType.normal,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const BattleRoyaleJoinRoomScreen(),
                                ),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Pixel.login,
                                  size: 16,
                                  color: Colors.black87,
                                ),
                                SizedBox(width: 8),
                                Text('THAM GIA PHÒNG'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
