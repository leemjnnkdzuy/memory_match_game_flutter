import 'package:flutter/material.dart';
import '../widgets/common/battle_royale_join_room_header.dart';
import '../widgets/common/battle_royale_join_room_tabs.dart';
import '../widgets/common/battle_royale_public_rooms_list.dart';
import '../widgets/common/battle_royale_enter_code_form.dart';
import '../widgets/custom/custom_game_dialog_widgets.dart';
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

  Future<void> _joinByCode() async {
    if (_codeController.text.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final room = await BattleRoyaleService.instance.getRoomByCode(
        _codeController.text.toUpperCase(),
      );

      if (!mounted) return;

      if (room != null) {
        if (room.hasPassword) {
          _showPasswordDialog(room);
        } else {
          await _joinRoom(room.id);
        }
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Mã phòng không hợp lệ!')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Không thể tìm phòng!')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showPasswordDialog(BattleRoyaleRoom room) async {
    await showDialog(
      context: context,
      builder: (context) => EnterPasswordDialogWidget(
        roomName: room.name,
        onConfirm: (password) async {
          Navigator.pop(context);
          await _joinRoom(room.id, password: password);
        },
        onCancel: () {
          Navigator.pop(context);
        },
      ),
    );
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
              BattleRoyaleJoinRoomHeader(
                onBack: () => Navigator.pop(context),
                onRefresh: _loadPublicRooms,
              ),

              BattleRoyaleJoinRoomTabs(
                selectedTab: _selectedTab,
                onTabChanged: (index) => setState(() => _selectedTab = index),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: _selectedTab == 0
                    ? BattleRoyalePublicRoomsList(
                        rooms: _rooms,
                        isLoading: _isLoading,
                        onJoinRoom: (roomId) => _joinRoom(roomId),
                      )
                    : BattleRoyaleEnterCodeForm(
                        codeController: _codeController,
                        isLoading: _isLoading,
                        onJoin: _joinByCode,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
