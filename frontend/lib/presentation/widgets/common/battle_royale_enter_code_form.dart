import 'package:flutter/material.dart';
import '../custom/custom_button.dart';
import '../custom/custom_text_input.dart';

class BattleRoyaleEnterCodeForm extends StatelessWidget {
  final TextEditingController codeController;
  final bool isLoading;
  final VoidCallback onJoin;

  const BattleRoyaleEnterCodeForm({
    super.key,
    required this.codeController,
    required this.isLoading,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mã Phòng',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                CustomTextInput(
                  controller: codeController,
                  hintText: 'Nhập mã phòng',
                  onChanged: (value) {
                    // Handle onChanged if needed
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CustomButton(
            type: CustomButtonType.primary,
            onPressed: isLoading
                ? null
                : () {
                    if (codeController.text.isNotEmpty) {
                      onJoin();
                    }
                  },
            child: const Text('Tham Gia'),
          ),
        ],
      ),
    );
  }
}
