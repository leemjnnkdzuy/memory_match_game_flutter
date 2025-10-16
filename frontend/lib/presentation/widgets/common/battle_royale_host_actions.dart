import 'package:flutter/material.dart';
import '../custom/custom_button.dart';

class BattleRoyaleHostActions extends StatelessWidget {
  final bool canStart;
  final VoidCallback onStartMatch;
  final VoidCallback onSettings;
  final VoidCallback onCloseRoom;

  const BattleRoyaleHostActions({
    super.key,
    required this.canStart,
    required this.onStartMatch,
    required this.onSettings,
    required this.onCloseRoom,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomButton(
          type: CustomButtonType.primary,
          onPressed: canStart ? onStartMatch : null,
          child: const Text('Bắt Đầu Trận Đấu', textAlign: TextAlign.center),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                type: CustomButtonType.normal,
                onPressed: onSettings,
                child: const Text('Cài Đặt', textAlign: TextAlign.center),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CustomButton(
                type: CustomButtonType.error,
                onPressed: onCloseRoom,
                child: const Text('Đóng Phòng', textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
