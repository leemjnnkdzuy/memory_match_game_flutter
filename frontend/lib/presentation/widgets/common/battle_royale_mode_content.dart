import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import '../../../data/models/user_model.dart';
import '../custom/custom_button.dart';
import 'player_info_card_widget.dart';

class BattleRoyaleModeContent extends StatelessWidget {
  final VoidCallback onCreateRoom;
  final VoidCallback onJoinRoom;
  final User? user;

  const BattleRoyaleModeContent({
    super.key,
    required this.onCreateRoom,
    required this.onJoinRoom,
    this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PlayerInfoCardWidget(
                username: user?.username,
                avatar: user?.avatar,
                textColor: Colors.white,
              ),
              const SizedBox(height: 40),

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

              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  type: CustomButtonType.primary,
                  onPressed: onCreateRoom,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Pixel.plus, size: 16, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Tạo Phòng'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  type: CustomButtonType.normal,
                  onPressed: onJoinRoom,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Pixel.login, size: 16, color: Colors.black87),
                      SizedBox(width: 8),
                      Text('Tham Gia Phòng'),
                    ],
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
