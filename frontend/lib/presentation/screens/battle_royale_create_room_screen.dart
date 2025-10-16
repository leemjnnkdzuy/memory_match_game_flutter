import 'package:flutter/material.dart';
import '../widgets/custom/custom_button.dart';
import '../widgets/custom/custom_text_input.dart';
import '../widgets/common/battle_royale_create_room_header.dart';
import '../widgets/common/battle_royale_form_label.dart';
import '../widgets/common/battle_royale_form_slider.dart';
import '../widgets/common/battle_royale_form_checkbox.dart';
import '../../services/battle_royale_service.dart';
import '../../services/auth_service.dart';
import 'battle_royale_lobby_screen.dart';

class BattleRoyaleCreateRoomScreen extends StatefulWidget {
  const BattleRoyaleCreateRoomScreen({super.key});

  @override
  State<BattleRoyaleCreateRoomScreen> createState() =>
      _BattleRoyaleCreateRoomScreenState();
}

class _BattleRoyaleCreateRoomScreenState
    extends State<BattleRoyaleCreateRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _seedController = TextEditingController();

  int _maxPlayers = 8;
  int _softCapTime = 120;
  bool _hasPassword = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text =
        'Phòng của ${AuthService.instance.currentUser?.username ?? "Player"}';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _seedController.dispose();
    super.dispose();
  }

  Future<void> _createRoom() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final room = await BattleRoyaleService.instance.createRoom(
        name: _nameController.text,
        password: _hasPassword ? _passwordController.text : null,
        maxPlayers: _maxPlayers,
        pairCount: 8,
        softCapTime: _softCapTime,
        seed: _seedController.text.isEmpty ? null : _seedController.text,
      );

      if (!mounted) return;

      if (room != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => BattleRoyaleLobbyScreen(room: room),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể tạo phòng. Vui lòng thử lại!'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
              const BattleRoyaleCreateRoomHeader(),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const BattleRoyaleFormLabel(text: 'Tên Phòng'),
                        CustomTextInput(
                          controller: _nameController,
                          hintText: 'Nhập tên phòng',
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập tên phòng';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Max Players
                        const BattleRoyaleFormLabel(text: 'SỐ NGƯỜI TỐI ĐA'),
                        BattleRoyaleFormSlider(
                          value: _maxPlayers.toDouble(),
                          min: 2,
                          max: 8,
                          divisions: 6,
                          label: '$_maxPlayers người',
                          onChanged: (value) =>
                              setState(() => _maxPlayers = value.toInt()),
                        ),
                        const SizedBox(height: 16),

                        // Soft Cap Time
                        const BattleRoyaleFormLabel(
                          text: 'THỜI GIAN GỢI Ý (giây)',
                        ),
                        BattleRoyaleFormSlider(
                          value: _softCapTime.toDouble(),
                          min: 60,
                          max: 180,
                          divisions: 12,
                          label: '$_softCapTime giây',
                          onChanged: (value) =>
                              setState(() => _softCapTime = value.toInt()),
                        ),
                        const SizedBox(height: 16),

                        // Password Toggle
                        BattleRoyaleFormCheckbox(
                          value: _hasPassword,
                          label: 'ĐẶT MẬT KHẨU',
                          onChanged: (value) =>
                              setState(() => _hasPassword = value ?? false),
                        ),

                        if (_hasPassword) ...[
                          const SizedBox(height: 8),
                          CustomTextInput(
                            controller: _passwordController,
                            hintText: 'Nhập mật khẩu',
                            obscureText: true,
                            validator: (value) {
                              if (_hasPassword &&
                                  (value == null || value.isEmpty)) {
                                return 'Vui lòng nhập mật khẩu';
                              }
                              return null;
                            },
                          ),
                        ],
                        const SizedBox(height: 16),

                        // Seed (Optional)
                        const BattleRoyaleFormLabel(text: 'SEED (Tùy chọn)'),
                        CustomTextInput(
                          controller: _seedController,
                          hintText: 'Để trống để random',
                        ),
                        const SizedBox(height: 32),

                        // Create Button
                        CustomButton(
                          type: CustomButtonType.primary,
                          onPressed: _isLoading ? null : _createRoom,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('TẠO PHÒNG'),
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
