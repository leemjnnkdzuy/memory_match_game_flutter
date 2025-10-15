import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../data/models/battle_royale_room_model.dart';
import '../data/models/battle_royale_player_model.dart';
import '../core/utils/http_client_utils.dart';
import '../data/implements/http_client_impl.dart';
import 'token_storage_service.dart';

class BattleRoyaleService {
  static final BattleRoyaleService _instance = BattleRoyaleService._internal();
  factory BattleRoyaleService() => _instance;
  BattleRoyaleService._internal();

  static BattleRoyaleService get instance => _instance;

  final HttpClient _httpClient = HttpClientImpl();
  final TokenStorage _tokenStorage = TokenStorageImpl();

  IO.Socket? _socket;
  String? _currentRoomId;

  final _roomUpdateController = StreamController<BattleRoyaleRoom>.broadcast();
  final _playerUpdateController =
      StreamController<List<BattleRoyalePlayer>>.broadcast();
  final _matchStartController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _scoreUpdateController =
      StreamController<BattleRoyalePlayer>.broadcast();
  final _matchFinishController =
      StreamController<List<BattleRoyalePlayer>>.broadcast();
  final _connectionController = StreamController<bool>.broadcast();
  final _roomClosedController = StreamController<String>.broadcast();
  final _kickedController = StreamController<String>.broadcast();

  Stream<BattleRoyaleRoom> get roomUpdates => _roomUpdateController.stream;
  Stream<List<BattleRoyalePlayer>> get playerUpdates =>
      _playerUpdateController.stream;
  Stream<Map<String, dynamic>> get matchStarts => _matchStartController.stream;
  Stream<BattleRoyalePlayer> get scoreUpdates => _scoreUpdateController.stream;
  Stream<List<BattleRoyalePlayer>> get matchFinishes =>
      _matchFinishController.stream;
  Stream<bool> get connectionStatus => _connectionController.stream;
  Stream<String> get roomClosed => _roomClosedController.stream;
  Stream<String> get kicked => _kickedController.stream;

  Future<BattleRoyaleRoom?> createRoom({
    required String name,
    String? password,
    int maxPlayers = 8,
    int pairCount = 8,
    int softCapTime = 120,
    int? hardCapTime,
    String? seed,
    String region = 'auto',
  }) async {
    try {
      final token = await _tokenStorage.getAccessToken();
      final response = await _httpClient.post(
        '/battle-royale/rooms',
        body: {
          'name': name,
          'password': password,
          'maxPlayers': maxPlayers,
          'pairCount': pairCount,
          'softCapTime': softCapTime,
          'hardCapTime': hardCapTime,
          'seed': seed,
          'region': region,
        },
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );

      if (response.success && response.data != null) {
        return BattleRoyaleRoom.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Error creating room: $e');
      return null;
    }
  }

  Future<List<BattleRoyaleRoom>> getPublicRooms({
    int? minPlayers,
    int? maxPlayers,
    int? maxPing,
  }) async {
    try {
      final token = await _tokenStorage.getAccessToken();
      // TODO: Add query parameters support when backend is ready
      final response = await _httpClient.get(
        '/battle-royale/rooms?public=1',
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );

      if (response.success && response.data != null) {
        final roomsData = response.data is Map
            ? response.data['rooms']
            : response.data;
        if (roomsData is List) {
          return roomsData
              .map((room) => BattleRoyaleRoom.fromJson(room))
              .toList();
        }
      }
      return [];
    } catch (e) {
      debugPrint('Error getting rooms: $e');
      return [];
    }
  }

  Future<BattleRoyaleRoom?> joinRoom(String roomId, {String? password}) async {
    try {
      final token = await _tokenStorage.getAccessToken();
      final response = await _httpClient.post(
        '/battle-royale/rooms/$roomId/join',
        body: {'password': password},
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );

      if (response.success && response.data != null) {
        return BattleRoyaleRoom.fromJson(response.data);
      }
      return null;
    } catch (e) {
      debugPrint('Error joining room: $e');
      return null;
    }
  }

  Future<bool> setReady(String roomId, bool ready) async {
    try {
      if (_socket?.connected == true) {
        _socket?.emit('br:toggle_ready', {'roomId': roomId});
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> kickPlayer(String roomId, String playerId) async {
    try {
      debugPrint('Attempting to kick player: $playerId from room: $roomId');
      debugPrint('Socket connected: ${_socket?.connected}');

      if (_socket?.connected == true) {
        _socket?.emit('br:kick_player', {
          'roomId': roomId,
          'playerId': playerId,
        });
        debugPrint('Kick player event emitted successfully');
        return true;
      }

      debugPrint('Socket not connected, cannot kick player');
      return false;
    } catch (e) {
      debugPrint('Error kicking player: $e');
      return false;
    }
  }

  Future<bool> startMatch(String roomId) async {
    try {
      debugPrint('=== START MATCH ===');
      debugPrint('Room ID: $roomId');
      debugPrint('Socket connected: ${_socket?.connected}');

      if (_socket?.connected == true) {
        debugPrint('Emitting br:start_match event...');
        _socket?.emit('br:start_match', {'roomId': roomId});
        debugPrint('Event emitted successfully');
        return true;
      } else {
        debugPrint('Socket not connected!');
      }
      return false;
    } catch (e) {
      debugPrint('Error starting match: $e');
      return false;
    }
  }

  Future<bool> closeRoom(String roomId) async {
    try {
      final token = await _tokenStorage.getAccessToken();
      final response = await _httpClient.delete(
        '/battle-royale/rooms/$roomId',
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );

      return response.success;
    } catch (e) {
      debugPrint('Error closing room: $e');
      return false;
    }
  }

  Future<void> connectToRoom(String roomId) async {
    try {
      _currentRoomId = roomId;
      final token = await _tokenStorage.getAccessToken();

      _socket = IO.io('http://localhost:3001', <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
        'auth': {'token': token},
        'query': {'roomId': roomId},
      });

      _setupSocketListeners();
      _socket!.connect();
    } catch (e) {
      _connectionController.add(false);
    }
  }

  void _setupSocketListeners() {
    _socket?.on('connect', (_) {
      _connectionController.add(true);

      if (_currentRoomId != null) {
        _socket?.emit('br:join_room', {'roomId': _currentRoomId});
      }
    });

    _socket?.on('disconnect', (_) {
      debugPrint('Socket disconnected');
      _connectionController.add(false);
    });

    _socket?.on('connect_error', (error) {
      debugPrint('Socket connection error: $error');
      _connectionController.add(false);
    });

    _socket?.on('br:room_state', (data) {
      try {
        final room = BattleRoyaleRoom.fromJson(data['room']);
        _roomUpdateController.add(room);
      } catch (e) {
        debugPrint('Error parsing br:room_state: $e');
      }
    });

    _socket?.on('room:update', (data) {
      try {
        final room = BattleRoyaleRoom.fromJson(data);
        _roomUpdateController.add(room);
      } catch (e) {
        debugPrint('Error parsing room:update: $e');
      }
    });

    _socket?.on('br:player_joined', (data) {
      _handlePlayerUpdate(data);
    });

    _socket?.on('br:player_ready', (data) {
      debugPrint('Received br:player_ready event');
      _handlePlayerUpdate(data);
    });

    _socket?.on('br:player_left', (data) {
      debugPrint('Received br:player_left event');
      _handlePlayerUpdate(data);
    });

    _socket?.on('br:player_disconnected', (data) {
      debugPrint('Received br:player_disconnected event');
      _handlePlayerUpdate(data);
    });

    _socket?.on('br:match_countdown', (data) {
      debugPrint('Match countdown received: $data');
      // TODO: Show countdown UI
    });

    _socket?.on('br:match_start', (data) {
      debugPrint('Match start received: $data');
      _matchStartController.add(data);
    });

    _socket?.on('match:start', (data) {
      _matchStartController.add(data);
    });

    _socket?.on('score:update', (data) {
      try {
        final player = BattleRoyalePlayer.fromJson(data);
        _scoreUpdateController.add(player);
      } catch (e) {
        debugPrint('Error parsing score:update: $e');
      }
    });

    _socket?.on('match:finish', (data) {
      try {
        final leaderboard = (data['leaderboard'] as List)
            .map((p) => BattleRoyalePlayer.fromJson(p))
            .toList();
        _matchFinishController.add(leaderboard);
      } catch (e) {
        debugPrint('Error parsing match:finish: $e');
      }
    });

    _socket?.on('br:room_closed', (data) {
      _roomClosedController.add(data['message'] ?? 'Room has been closed');
      disconnect();
    });

    _socket?.on('br:kicked', (data) {
      _kickedController.add(
        data['message'] ?? 'You have been kicked from the room',
      );
      disconnect();
    });

    _socket?.on('br:error', (data) {
      debugPrint('WebSocket error received: $data');
      final message = data['message'] ?? 'Unknown error';
      debugPrint('Error message: $message');
      // TODO: Show error to user
    });
  }

  void _handlePlayerUpdate(dynamic data) {
    try {
      debugPrint('Received player update: $data');
      final players = (data['players'] as List)
          .map((p) => BattleRoyalePlayer.fromJson(p))
          .toList();
      debugPrint('Parsed ${players.length} players');
      _playerUpdateController.add(players);
    } catch (e) {
      debugPrint('Error parsing player update: $e');
      debugPrint('Data was: $data');
    }
  }

  void sendFlipRequest(int cardIndex) {
    _socket?.emit('flip:request', {'index': cardIndex});
  }

  void sendScoreUpdate({
    required int pairsFound,
    required int flipCount,
    required int completionTime,
  }) {
    _socket?.emit('score:update', {
      'pairsFound': pairsFound,
      'flipCount': flipCount,
      'completionTime': completionTime,
    });
  }

  void sendMatchFinish({
    required int pairsFound,
    required int flipCount,
    required int completionTime,
    required double score,
  }) {
    _socket?.emit('match:finish', {
      'pairsFound': pairsFound,
      'flipCount': flipCount,
      'completionTime': completionTime,
      'score': score,
    });
  }

  void requestCloseRoom(String roomId) {
    _socket?.emit('br:close_room', {'roomId': roomId});
  }

  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    _currentRoomId = null;
    _connectionController.add(false);
  }

  void dispose() {
    disconnect();
    _roomUpdateController.close();
    _playerUpdateController.close();
    _matchStartController.close();
    _scoreUpdateController.close();
    _matchFinishController.close();
    _connectionController.close();
    _roomClosedController.close();
    _kickedController.close();
  }
}
