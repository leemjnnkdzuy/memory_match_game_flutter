import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import '../widgets/custom/custom_button.dart';
import '../widgets/common/room_card_widget.dart';
import '../../services/battle_royale_service.dart';
import '../../data/models/battle_royale_room_model.dart';
import 'battle_royale_lobby_screen.dart';

class BattleRoyaleJoinRoomScreen extends StatefulWidget {
  const BattleRoyaleJoinRoomScreen({super.key});

  @override
  State<BattleRoyaleJoinRoomScreen> createState() =>
      _BattleRoyaleJoinRoomScreenState();
}

class _BattleRoyaleJoinRoomScreenState
    extends State<BattleRoyaleJoinRoomScreen> {
  final _codeController = TextEditingController();
  List<BattleRoyaleRoom> _rooms = [];
  bool _isLoading = false;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _loadPublicRooms();
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _loadPublicRooms() async {
    setState(() => _isLoading = true);
    try {
      final rooms = await BattleRoyaleService.instance.getPublicRooms();
      setState(() {
        _rooms = rooms;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _joinRoom(String roomId, {String? password}) async {
    setState(() => _isLoading = true);
    try {
      final room = await BattleRoyaleService.instance.joinRoom(
        roomId,
        password: password,
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
          const SnackBar(content: Text('Không thể tham gia phòng!')),
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
                        'THAM GIA PHÒNG',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Pixel.reload, color: Colors.white),
                      onPressed: _loadPublicRooms,
                    ),
                  ],
                ),
              ),

              // Tabs
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.black, width: 2),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTab(0, 'PHÒNG CÔNG KHAI', Pixel.users),
                    ),
                    Container(width: 2, height: 40, color: Colors.black),
                    Expanded(child: _buildTab(1, 'NHẬP MÃ', Pixel.lock)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Content
              Expanded(
                child: _selectedTab == 0
                    ? _buildPublicRoomsList()
                    : _buildEnterCodeForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTab(int index, String label, IconData icon) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        color: isSelected ? const Color(0xFFE91E63) : Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : Colors.black87,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPublicRoomsList() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_rooms.isEmpty) {
      return Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Pixel.users, size: 64, color: Colors.white54),
              const SizedBox(height: 16),
              const Text(
                'Không có phòng nào',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Hãy thử tạo một phòng mới!',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _rooms.length,
      itemBuilder: (context, index) {
        final room = _rooms[index];
        return RoomCardWidget(room: room, onTap: () => _joinRoom(room.id));
      },
    );
  }

  Widget _buildEnterCodeForm() {
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
                  'MÃ PHÒNG',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _codeController,
                  decoration: const InputDecoration(
                    hintText: 'Nhập mã phòng',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.all(12),
                  ),
                  textInputAction: TextInputAction.go,
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      // TODO: Implement join by code
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tính năng đang phát triển!'),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CustomButton(
            type: CustomButtonType.primary,
            onPressed: _isLoading
                ? null
                : () {
                    if (_codeController.text.isNotEmpty) {
                      // TODO: Implement join by code
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Tính năng đang phát triển!'),
                        ),
                      );
                    }
                  },
            child: const Text('THAM GIA'),
          ),
        ],
      ),
    );
  }
}
