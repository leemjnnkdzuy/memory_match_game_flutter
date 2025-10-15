import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import '../widgets/custom/custom_button.dart';
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
        '${AuthService.instance.currentUser?.username ?? "Player"}\'s Room';
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
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'TẠO PHÒNG',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Room Name
                        _buildLabel('TÊN PHÒNG'),
                        _buildTextField(
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
                        _buildLabel('SỐ NGƯỜI TỐI ĐA'),
                        _buildSlider(
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
                        _buildLabel('THỜI GIAN GỢI Ý (giây)'),
                        _buildSlider(
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
                        _buildCheckbox(
                          value: _hasPassword,
                          label: 'ĐẶT MẬT KHẨU',
                          onChanged: (value) =>
                              setState(() => _hasPassword = value ?? false),
                        ),

                        if (_hasPassword) ...[
                          const SizedBox(height: 8),
                          _buildTextField(
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
                        _buildLabel('SEED (Tùy chọn)'),
                        _buildTextField(
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        decoration: InputDecoration(
          hintText: hintText,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(12),
        ),
      ),
    );
  }

  Widget _buildSlider({
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String label,
    required ValueChanged<double> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckbox({
    required bool value,
    required String label,
    required ValueChanged<bool?> onChanged,
  }) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: value ? const Color(0xFFE91E63) : Colors.white,
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: value
                  ? const Icon(Pixel.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
