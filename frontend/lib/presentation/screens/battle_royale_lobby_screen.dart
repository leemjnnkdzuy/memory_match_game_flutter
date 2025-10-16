import 'package:flutter/material.dart';
import 'dart:async';
import '../widgets/common/game_dialog_widgets.dart';
import '../widgets/common/battle_royale_lobby_header.dart';
import '../widgets/common/battle_royale_room_info.dart';
import '../widgets/common/battle_royale_players_list.dart';
import '../widgets/common/battle_royale_host_actions.dart';
import '../widgets/common/battle_royale_player_actions.dart';
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
    _syncReadyState(_players);
    _connectToRoom();
    _setupListeners();
  }

  void _syncReadyState(List<BattleRoyalePlayer> players) {
    if (_isHost) return;
    final currentUserId = AuthService.instance.currentUser?.id;
    if (currentUserId == null) return;
    for (final player in players) {
      if (player.id == currentUserId) {
        _isReady = player.isReady;
        break;
      }
    }
  }

  Future<bool> _confirmLeaveRoom() async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (context) => LeaveRoomConfirmDialogWidget(
        onConfirm: () => Navigator.pop(context, true),
        onCancel: () => Navigator.pop(context, false),
      ),
    );

    if (shouldLeave == true) {
      await BattleRoyaleService.instance.leaveRoom(_currentRoom.id);
      return true;
    }

    return false;
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
        _checkIfHost();
        _syncReadyState(room.players);
      });
    });

    _playerUpdateSub = BattleRoyaleService.instance.playerUpdates.listen((
      players,
    ) {
      setState(() {
        _players = players;
        _currentRoom = _currentRoom.copyWith(
          players: players,
          currentPlayers: players.where((player) => player.isConnected).length,
        );
        _checkIfHost();
        _syncReadyState(players);
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
          content: Text('Tất cả người chơi phải sẵn sàng để bắt đầu!'),
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
    final player = _players.firstWhere(
      (p) => p.id == playerId,
      orElse: () => _players.first,
    );

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => KickPlayerConfirmDialogWidget(
        playerName: player.username,
        onConfirm: () => Navigator.pop(context, true),
        onCancel: () => Navigator.pop(context, false),
      ),
    );

    if (confirm == true) {
      final success = await BattleRoyaleService.instance.kickPlayer(
        _currentRoom.id,
        playerId,
      );

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể kick người chơi!'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
      BattleRoyaleService.instance.requestCloseRoom(_currentRoom.id);

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
      onWillPop: () => _confirmLeaveRoom(),
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
                BattleRoyaleLobbyHeader(
                  room: _currentRoom,
                  onBack: () async {
                    final shouldLeave = await _confirmLeaveRoom();
                    if (shouldLeave && mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),

                BattleRoyaleRoomInfo(
                  room: _currentRoom,
                  playerCount: _players.length,
                ),
                const SizedBox(height: 16),

                BattleRoyalePlayersList(
                  players: _players,
                  currentUserId: currentUserId,
                  isHost: _isHost,
                  onKick: _kickPlayer,
                ),
                const SizedBox(height: 16),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: _isHost
                      ? BattleRoyaleHostActions(
                          canStart: _currentRoom.canStart,
                          onStartMatch: _startMatch,
                          onSettings: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Cài đặt sắp ra mắt!'),
                              ),
                            );
                          },
                          onCloseRoom: _closeRoom,
                        )
                      : BattleRoyalePlayerActions(
                          isReady: _isReady,
                          onToggleReady: _toggleReady,
                          onLeaveRoom: () async {
                            final shouldLeave = await _confirmLeaveRoom();
                            if (shouldLeave && mounted) {
                              Navigator.pop(context);
                            }
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
