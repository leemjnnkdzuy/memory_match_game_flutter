import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../data/models/battle_royale_room_model.dart';
import '../data/models/battle_royale_player_model.dart';
import '../core/utils/http_client_utils.dart';
import '../data/implements/http_client_impl.dart';
import 'token_storage_service.dart';
import '../core/constants/app_constants.dart';

class BattleRoyaleService {
  static final BattleRoyaleService _instance = BattleRoyaleService._internal();
  factory BattleRoyaleService() => _instance;
  BattleRoyaleService._internal();

  static BattleRoyaleService get instance => _instance;

  final HttpClient _httpClient = HttpClientImpl();
  final TokenStorage _tokenStorage = TokenStorageImpl();

  IO.Socket? _socket;
  String? _currentRoomId;
  List<BattleRoyalePlayer> _latestPlayers = [];

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
  List<BattleRoyalePlayer> get latestPlayers =>
      List.unmodifiable(_latestPlayers);

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
      return [];
    }
  }

  Future<BattleRoyaleRoom?> getRoomByCode(String code) async {
    try {
      final token = await _tokenStorage.getAccessToken();
      final response = await _httpClient.get(
        '/battle-royale/rooms/code/$code',
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );

      if (response.success && response.data != null) {
        return BattleRoyaleRoom.fromJson(response.data);
      }
      return null;
    } catch (e) {
      return null;
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
      if (_socket?.connected == true) {
        _socket?.emit('br:kick_player', {
          'roomId': roomId,
          'playerId': playerId,
        });
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> startMatch(String roomId) async {
    try {
      if (_socket?.connected == true) {
        _socket?.emit('br:start_match', {'roomId': roomId});
        return true;
      } else {
        throw Exception('Socket not connected');
      }
    } catch (e) {
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
      return false;
    }
  }

  Future<void> connectToRoom(String roomId) async {
    try {
      _currentRoomId = roomId;
      final token = await _tokenStorage.getAccessToken();

      _socket = IO.io(
        AppConstants.apiBaseUrl.replaceFirst(RegExp(r'/$'), ''),
        <String, dynamic>{
          'transports': ['websocket'],
          'autoConnect': false,
          'auth': {'token': token},
          'query': {'roomId': roomId},
        },
      );

      _setupSocketListeners();
      _socket!.connect();
    } catch (e) {
      _connectionController.add(false);
    }
  }

  Future<void> leaveRoom([String? roomId]) async {
    final targetRoomId = roomId ?? _currentRoomId;
    if (targetRoomId == null) {
      return;
    }

    if (_socket == null) {
      _currentRoomId = null;
      return;
    }

    try {
      if (_socket!.connected) {
        _socket!.emit('br:leave_room', {'roomId': targetRoomId});
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
    } catch (e) {
      throw Exception('Error emitting br:leave_room: $e');
    } finally {
      _currentRoomId = null;
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
      _connectionController.add(false);
    });

    _socket?.on('connect_error', (error) {
      _connectionController.add(false);
    });

    _socket?.on('br:room_state', (data) {
      try {
        final room = BattleRoyaleRoom.fromJson(data['room']);
        _latestPlayers = room.players;
        _roomUpdateController.add(room);
      } catch (e) {
        throw Exception('Error parsing br:room_state: $e');
      }
    });

    _socket?.on('room:update', (data) {
      try {
        final room = BattleRoyaleRoom.fromJson(data);
        _latestPlayers = room.players;
        _roomUpdateController.add(room);
      } catch (e) {
        throw Exception('Error parsing room:update: $e');
      }
    });

    _socket?.on('br:player_joined', (data) {
      _handlePlayerUpdate(data);
    });

    _socket?.on('br:player_ready', (data) {
      _handlePlayerUpdate(data);
    });

    _socket?.on('br:player_left', (data) {
      _handlePlayerUpdate(data);
    });

    _socket?.on('br:player_disconnected', (data) {
      _handlePlayerUpdate(data);
    });

    _socket?.on('br:leaderboard_update', (data) {
      try {
        _handleLeaderboardSnapshot(data);
      } catch (e) {
        throw Exception('Error parsing br:leaderboard_update: $e');
      }
    });

    _socket?.on('br:match_countdown', (data) {
    });

    _socket?.on('br:match_start', (data) {
      _matchStartController.add(data);
    });

    _socket?.on('match:start', (data) {
      _matchStartController.add(data);
    });

    _socket?.on('br:player_finished', (data) {
      try {
        final player = BattleRoyalePlayer.fromJson(
          Map<String, dynamic>.from(data),
        );
        final updatedPlayer = _mergeScoreData(player);
        _scoreUpdateController.add(updatedPlayer);
      } catch (e) {
        throw Exception('Error parsing br:player_finished: $e');
      }
    });

    _socket?.on('br:match_finished', (data) {
      try {
        final leaderboard = ((data as Map)['leaderboard'] as List)
            .map(
              (p) => BattleRoyalePlayer.fromJson(Map<String, dynamic>.from(p)),
            )
            .toList();
        _latestPlayers = leaderboard;
        _matchFinishController.add(leaderboard);
      } catch (e) {
        throw Exception('Error parsing br:match_finished: $e');
      }
    });

    _socket?.on('score:update', (data) {
      try {
        final player = BattleRoyalePlayer.fromJson(data);
        final updatedPlayer = _mergeScoreData(player);
        _scoreUpdateController.add(updatedPlayer);
      } catch (e) {
        throw Exception('Error parsing score:update: $e');
      }
    });

    _socket?.on('match:finish', (data) {
      try {
        final leaderboard = (data['leaderboard'] as List)
            .map(
              (p) => BattleRoyalePlayer.fromJson(Map<String, dynamic>.from(p)),
            )
            .toList();
        _latestPlayers = leaderboard;
        _matchFinishController.add(leaderboard);
      } catch (e) {
        throw Exception('Error parsing match:finish: $e');
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
      final message = data['message'] ?? 'Unknown error';
      throw Exception('Error message: $message');
    });
  }

  void _handlePlayerUpdate(dynamic data) {
    try {
      final incomingPlayers = (data['players'] as List)
          .map((p) => BattleRoyalePlayer.fromJson(Map<String, dynamic>.from(p)))
          .toList();
      final previousPlayers = List<BattleRoyalePlayer>.from(_latestPlayers);
      final updatedPlayers = incomingPlayers
          .map((player) => _mergeMetaData(player, previousPlayers))
          .toList();
      _latestPlayers = updatedPlayers;
      _playerUpdateController.add(updatedPlayers);
    } catch (e) {
      throw Exception('Error parsing player update: $e');
    }
  }

  void _handleLeaderboardSnapshot(dynamic data) {
    Map<String, dynamic> payload;
    if (data is Map<String, dynamic>) {
      payload = data;
    } else if (data is Map) {
      payload = Map<String, dynamic>.from(data);
    } else {
      throw Exception('Invalid leaderboard payload: $data');
    }

    final players = (payload['players'] as List? ?? [])
        .map((p) => BattleRoyalePlayer.fromJson(Map<String, dynamic>.from(p)))
        .toList();
    _latestPlayers = players;
    _playerUpdateController.add(List<BattleRoyalePlayer>.from(players));
  }

  void sendFlipRequest({required String matchId, required int cardIndex}) {
    _socket?.emit('br:flip_card', {'matchId': matchId, 'cardIndex': cardIndex});
  }

  void sendScoreUpdate({
    required String matchId,
    required int pairsFound,
    required int flipCount,
    required int completionTime,
  }) {
    _socket?.emit('br:update_progress', {
      'matchId': matchId,
      'pairsFound': pairsFound,
      'flipCount': flipCount,
      'completionTime': completionTime,
    });
  }

  void sendMatchFinish({
    required String matchId,
    required int pairsFound,
    required int flipCount,
    required int completionTime,
    required double score,
  }) {
    _socket?.emit('br:player_finished', {
      'matchId': matchId,
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
    _latestPlayers = [];
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

  BattleRoyalePlayer _mergeMetaData(
    BattleRoyalePlayer incoming,
    List<BattleRoyalePlayer> previous,
  ) {
    final existingIndex = previous.indexWhere((p) => p.id == incoming.id);
    if (existingIndex == -1) {
      return incoming;
    }
    final existing = previous[existingIndex];
    return existing.copyWith(
      username: incoming.username,
      avatarUrl: incoming.avatarUrl ?? existing.avatarUrl,
      borderColor: incoming.borderColor.isNotEmpty
          ? incoming.borderColor
          : existing.borderColor,
      isReady: incoming.isReady,
      isHost: incoming.isHost,
      ping: incoming.ping ?? existing.ping,
      isConnected: incoming.isConnected,
    );
  }

  BattleRoyalePlayer _mergeScoreData(BattleRoyalePlayer incoming) {
    final existingIndex = _latestPlayers.indexWhere(
      (player) => player.id == incoming.id,
    );
    if (existingIndex == -1) {
      _latestPlayers.add(incoming);
      return incoming;
    }
    final existing = _latestPlayers[existingIndex];
    final merged = existing.copyWith(
      username: incoming.username,
      avatarUrl: incoming.avatarUrl ?? existing.avatarUrl,
      borderColor: incoming.borderColor.isNotEmpty
          ? incoming.borderColor
          : existing.borderColor,
      pairsFound: incoming.pairsFound,
      flipCount: incoming.flipCount,
      completionTime: incoming.completionTime,
      score: incoming.score,
      isFinished: incoming.isFinished,
      isReady: incoming.isReady,
      isConnected: incoming.isConnected,
      ping: incoming.ping ?? existing.ping,
      isHost: incoming.isHost,
    );
    _latestPlayers[existingIndex] = merged;
    return merged;
  }
}
