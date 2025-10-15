import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:pixelarticons/pixel.dart';
import 'dart:async';
import '../widgets/custom/custom_button.dart';
import '../widgets/common/player_card_widget.dart';
import '../widgets/common/game_dialog_widgets.dart';
import '../../services/battle_royale_service.dart';
import '../../services/auth_service.dart';
import '../../data/models/battle_royale_room_model.dart';
import '../../data/models/battle_royale_player_model.dart';

class BattleRoyaleLobbyScreen extends StatefulWidget {
  final BattleRoyaleRoom room;

  const BattleRoyaleLobbyScreen({super.key, required this.room});

  @override
  State<BattleRoyaleLobbyScreen> createState() =>
      _BattleRoyaleLobbyScreenState();
}

class _BattleRoyaleLobbyScreenState extends State<BattleRoyaleLobbyScreen> {
  late BattleRoyaleRoom _currentRoom;
  List<BattleRoyalePlayer> _players = [];
  bool _isReady = false;
  bool _isHost = false;
  StreamSubscription? _roomUpdateSub;
  StreamSubscription? _playerUpdateSub;
  StreamSubscription? _matchStartSub;
  StreamSubscription? _roomClosedSub;
  StreamSubscription? _kickedSub;

  @override
  void initState() {
    super.initState();
    _currentRoom = widget.room;
    _players = widget.room.players;
    _checkIfHost();
    _connectToRoom();
    _setupListeners();
  }

  @override
  void dispose() {
    _roomUpdateSub?.cancel();
    _playerUpdateSub?.cancel();
    _matchStartSub?.cancel();
    _roomClosedSub?.cancel();
    _kickedSub?.cancel();
    BattleRoyaleService.instance.disconnect();
    super.dispose();
  }

  void _checkIfHost() {
    final currentUserId = AuthService.instance.currentUser?.id;
    _isHost = _currentRoom.hostId == currentUserId;
  }

  Future<void> _connectToRoom() async {
    await BattleRoyaleService.instance.connectToRoom(_currentRoom.id);
  }

  void _setupListeners() {
    _roomUpdateSub = BattleRoyaleService.instance.roomUpdates.listen((room) {
      setState(() {
        _currentRoom = room;
        _players = room.players;
      });
    });

    _playerUpdateSub = BattleRoyaleService.instance.playerUpdates.listen((
      players,
    ) {
      setState(() {
        _players = players;
      });
    });

    _matchStartSub = BattleRoyaleService.instance.matchStarts.listen((data) {
      // TODO: Navigate to game screen
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Trận đấu bắt đầu!')));
      }
    });

    _roomClosedSub = BattleRoyaleService.instance.roomClosed.listen((message) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
        Navigator.pop(context);
      }
    });

    _kickedSub = BattleRoyaleService.instance.kicked.listen((message) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
        Navigator.pop(context);
      }
    });
  }

  Future<void> _toggleReady() async {
    final newReadyState = !_isReady;
    final success = await BattleRoyaleService.instance.setReady(
      _currentRoom.id,
      newReadyState,
    );
    if (success) {
      setState(() => _isReady = newReadyState);
    }
  }

  Future<void> _startMatch() async {
    if (!_currentRoom.canStart) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cần ít nhất 2 người sẵn sàng để bắt đầu!'),
        ),
      );
      return;
    }

    final success = await BattleRoyaleService.instance.startMatch(
      _currentRoom.id,
    );
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể bắt đầu trận đấu!')),
      );
    }
  }

  Future<void> _kickPlayer(String playerId) async {
    // Tìm tên người chơi để hiển thị trong dialog
    final player = _players.firstWhere(
      (p) => p.id == playerId,
      orElse: () => _players.first, // fallback
    );

    debugPrint('Attempting to kick player: ${player.username} (ID: $playerId)');
    debugPrint('Room ID: ${_currentRoom.id}');

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => KickPlayerConfirmDialogWidget(
        playerName: player.username,
        onConfirm: () => Navigator.pop(context, true),
        onCancel: () => Navigator.pop(context, false),
      ),
    );

    if (confirm == true) {
      debugPrint('Kick confirmed, calling service...');
      final success = await BattleRoyaleService.instance.kickPlayer(
        _currentRoom.id,
        playerId,
      );

      debugPrint('Kick result: $success');

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể kick người chơi!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } else {
      debugPrint('Kick cancelled by user');
    }
  }

  Future<void> _closeRoom() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => CloseRoomConfirmDialogWidget(
        playerCount: _players.length,
        onConfirm: () => Navigator.pop(context, true),
        onCancel: () => Navigator.pop(context, false),
      ),
    );

    if (confirm == true) {
      // Gọi WebSocket để thông báo cho tất cả người chơi
      BattleRoyaleService.instance.requestCloseRoom(_currentRoom.id);

      // Gọi REST API để xóa phòng khỏi database
      final success = await BattleRoyaleService.instance.closeRoom(
        _currentRoom.id,
      );

      if (success && mounted) {
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Không thể đóng phòng!')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = AuthService.instance.currentUser?.id;

    return WillPopScope(
      onWillPop: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Rời phòng?'),
            content: const Text('Bạn có chắc muốn rời khỏi phòng?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Ở lại'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Rời đi'),
              ),
            ],
          ),
        );
        return confirm ?? false;
      },
      child: Scaffold(
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
                      Expanded(
                        child: Column(
                          children: [
                            Text(
                              _currentRoom.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                border: Border.all(
                                  color: Colors.white,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'Mã: ${_currentRoom.code}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),

                // Room Info
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoItem(
                        Pixel.users,
                        '${_players.length}/${_currentRoom.maxPlayers}',
                      ),
                      _buildInfoItem(
                        Pixel.grid,
                        '${_currentRoom.pairCount} cặp',
                      ),
                      _buildInfoItem(
                        Pixel.clock,
                        '${_currentRoom.softCapTime}s',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Players List
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'NGƯỜI CHƠI',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: _players.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Đang tải...',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _players.length,
                                  itemBuilder: (context, index) {
                                    final player = _players[index];
                                    return PlayerCardWidget(
                                      player: player,
                                      isCurrentUser: player.id == currentUserId,
                                      onKick:
                                          _isHost && player.id != currentUserId
                                          ? () => _kickPlayer(player.id)
                                          : null,
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Action Buttons
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _isHost
                      ? _buildHostControls()
                      : _buildPlayerControls(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFFE91E63)),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildHostControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomButton(
          type: CustomButtonType.primary,
          onPressed: _currentRoom.canStart ? _startMatch : null,
          child: const Text('BẮT ĐẦU TRẬN ĐẤU'),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                type: CustomButtonType.normal,
                onPressed: () {
                  // TODO: Room settings
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cài đặt sắp ra mắt!')),
                  );
                },
                child: const Text('CÀI ĐẶT', textAlign: TextAlign.center),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CustomButton(
                type: CustomButtonType.error,
                onPressed: _closeRoom,
                child: const Text('ĐÓNG PHÒNG', textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlayerControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CustomButton(
          type: _isReady ? CustomButtonType.warning : CustomButtonType.success,
          onPressed: _toggleReady,
          child: Text(_isReady ? 'HỦY SẴN SÀNG' : 'SẴN SÀNG'),
        ),
        const SizedBox(height: 8),
        CustomButton(
          type: CustomButtonType.error,
          onPressed: () => Navigator.pop(context),
          child: const Text('RỜI PHÒNG'),
        ),
      ],
    );
  }
}
