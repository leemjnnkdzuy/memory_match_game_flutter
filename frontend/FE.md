# Frontend Implementation - Solo Duel Mode

## Tổng quan

Tính năng Solo Duel cho phép người chơi đấu 1v1 real-time với người chơi khác. Hệ thống sử dụng **WebSocket** để đảm bảo đồng bộ trạng thái game giữa hai người chơi.

---

## Kiến trúc Frontend

### Cấu trúc thư mục

```
lib/
├── config/
│   └── websocket_config.dart         # Cấu hình WebSocket (MỚI)
├── core/
│   ├── constants/
│   │   └── app_constants.dart
│   ├── error/
│   │   └── exceptions.dart
│   ├── theme/
│   │   └── app_theme.dart
│   └── utils/
│       └── http_client_utils.dart
├── data/
│   ├── datasources/
│   │   ├── auth_remote_data_source.dart
│   │   ├── offline_history_remote_data_source.dart
│   │   └── solo_duel_remote_data_source.dart    # Remote data source (MỚI)
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── offline_history_model.dart
│   │   ├── pokemon_model.dart
│   │   ├── solo_duel_match_model.dart           # Model trận đấu (MỚI)
│   │   └── solo_duel_history_model.dart         # Model lịch sử (MỚI)
│   └── repositories/
│       ├── auth_repository_impl.dart
│       ├── offline_history_repository_impl.dart
│       ├── pokemon_repository_impl.dart
│       └── solo_duel_repository_impl.dart       # Repository impl (MỚI)
├── domain/
│   ├── entities/
│   │   ├── offline_game_entity.dart
│   │   ├── pokemon_entity.dart
│   │   ├── solo_duel_match_entity.dart          # Entity trận đấu (MỚI)
│   │   └── solo_duel_history_entity.dart        # Entity lịch sử (MỚI)
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   ├── offline_history_repository.dart
│   │   └── solo_duel_repository.dart            # Repository interface (MỚI)
│   └── usecases/
│       ├── get_solo_duel_histories_use_case.dart
│       └── get_solo_duel_history_use_case.dart
├── presentation/
│   ├── screens/
│   │   ├── game_match_screen.dart
│   │   ├── ganme_solo_duel_screen.dart          # Screen trước khi tìm trận (MỚI)
│   │   └── ganme_solo_duel_match_screen.dart    # Screen gameplay (MỚI)
│   └── widgets/
│       ├── common/
│       │   ├── game_board_widget.dart
│       │   ├── game_card_widget.dart
│       │   └── solo_duel_card_widget.dart       # Card cho Solo Duel (MỚI)
│       └── custom/
│           └── custom_button.dart
└── services/
    ├── auth_service.dart
    ├── request_service.dart
    ├── websocket_service.dart                   # WebSocket service (MỚI)
    └── solo_duel_game_service.dart              # Game state service (MỚI)
```

---

## 1. Entities

### File: `lib/domain/entities/solo_duel_match_entity.dart`

```dart
class SoloDuelMatchEntity {
  final String matchId;
  final MatchStatus status;
  final List<PlayerEntity> players;
  final List<SoloDuelCardEntity> cards;
  final String? currentTurn;
  final List<FlippedCardEntity> flippedCards;
  final String? winnerId;
  final DateTime? startedAt;
  final DateTime? finishedAt;

  const SoloDuelMatchEntity({
    required this.matchId,
    required this.status,
    required this.players,
    required this.cards,
    this.currentTurn,
    required this.flippedCards,
    this.winnerId,
    this.startedAt,
    this.finishedAt,
  });

  SoloDuelMatchEntity copyWith({
    String? matchId,
    MatchStatus? status,
    List<PlayerEntity>? players,
    List<SoloDuelCardEntity>? cards,
    String? currentTurn,
    List<FlippedCardEntity>? flippedCards,
    String? winnerId,
    DateTime? startedAt,
    DateTime? finishedAt,
  }) {
    return SoloDuelMatchEntity(
      matchId: matchId ?? this.matchId,
      status: status ?? this.status,
      players: players ?? this.players,
      cards: cards ?? this.cards,
      currentTurn: currentTurn ?? this.currentTurn,
      flippedCards: flippedCards ?? this.flippedCards,
      winnerId: winnerId ?? this.winnerId,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
    );
  }
}

class PlayerEntity {
  final String userId;
  final String username;
  final int score;
  final int matchedCards;
  final bool isReady;

  const PlayerEntity({
    required this.userId,
    required this.username,
    required this.score,
    required this.matchedCards,
    required this.isReady,
  });

  PlayerEntity copyWith({
    String? userId,
    String? username,
    int? score,
    int? matchedCards,
    bool? isReady,
  }) {
    return PlayerEntity(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      score: score ?? this.score,
      matchedCards: matchedCards ?? this.matchedCards,
      isReady: isReady ?? this.isReady,
    );
  }
}

class SoloDuelCardEntity {
  final int pokemonId;
  final String pokemonName;
  final bool isFlipped;
  final bool isMatched;
  final String? matchedBy;
  final String? flippedBy;
  final int position;

  const SoloDuelCardEntity({
    required this.pokemonId,
    required this.pokemonName,
    required this.isFlipped,
    required this.isMatched,
    this.matchedBy,
    this.flippedBy,
    required this.position,
  });

  SoloDuelCardEntity copyWith({
    int? pokemonId,
    String? pokemonName,
    bool? isFlipped,
    bool? isMatched,
    String? matchedBy,
    String? flippedBy,
    int? position,
  }) {
    return SoloDuelCardEntity(
      pokemonId: pokemonId ?? this.pokemonId,
      pokemonName: pokemonName ?? this.pokemonName,
      isFlipped: isFlipped ?? this.isFlipped,
      isMatched: isMatched ?? this.isMatched,
      matchedBy: matchedBy ?? this.matchedBy,
      flippedBy: flippedBy ?? this.flippedBy,
      position: position ?? this.position,
    );
  }
}

class FlippedCardEntity {
  final int cardIndex;
  final String flippedBy;
  final DateTime flippedAt;

  const FlippedCardEntity({
    required this.cardIndex,
    required this.flippedBy,
    required this.flippedAt,
  });
}

enum MatchStatus {
  waiting,
  ready,
  playing,
  completed,
  cancelled,
}
```

### File: `lib/domain/entities/solo_duel_history_entity.dart`

```dart
import '../../data/models/user_model.dart';

class SoloDuelHistoryEntity {
  final String id;
  final String matchId;
  final String userId;
  final String opponentId;
  final int score;
  final int opponentScore;
  final int matchedCards;
  final bool isWin;
  final int gameTime;
  final DateTime datePlayed;
  final User? opponent;

  const SoloDuelHistoryEntity({
    required this.id,
    required this.matchId,
    required this.userId,
    required this.opponentId,
    required this.score,
    required this.opponentScore,
    required this.matchedCards,
    required this.isWin,
    required this.gameTime,
    required this.datePlayed,
    this.opponent,
  });
}

class SoloDuelHistoriesResponse {
  final List<SoloDuelHistoryEntity> histories;
  final PaginationEntity pagination;

  const SoloDuelHistoriesResponse({
    required this.histories,
    required this.pagination,
  });
}

class PaginationEntity {
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;

  const PaginationEntity({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
  });
}
```

---

## 2. Services

### File: `lib/services/websocket_service.dart`

```dart
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter/foundation.dart';
import './token_storage_service.dart';

class WebSocketService {
  static WebSocketService? _instance;
  IO.Socket? _socket;

  final String _baseUrl = 'http://localhost:3001';
  final _connectionStatusController = ValueNotifier<bool>(false);

  static WebSocketService get instance {
    _instance ??= WebSocketService._internal();
    return _instance!;
  }

  WebSocketService._internal();

  ValueNotifier<bool> get connectionStatus => _connectionStatusController;

  Future<void> connect() async {
    if (_socket != null && _socket!.connected) {
      debugPrint('WebSocket already connected');
      return;
    }

    try {
      final tokenStorage = TokenStorageImpl();
      final accessToken = await tokenStorage.getAccessToken();

      if (accessToken == null) {
        throw Exception('No access token found');
      }

      _socket = IO.io(_baseUrl, <String, dynamic>{
        'transports': ['websocket', 'polling'],
        'autoConnect': false,
        'auth': {
          'token': accessToken,
        },
      });

      _socket!.onConnect((_) {
        debugPrint('WebSocket connected');
        _connectionStatusController.value = true;
      });

      _socket!.onDisconnect((_) {
        debugPrint('WebSocket disconnected');
        _connectionStatusController.value = false;
      });

      _socket!.onConnectError((error) {
        debugPrint('WebSocket connection error: $error');
        _connectionStatusController.value = false;
      });

      _socket!.onError((error) {
        debugPrint('WebSocket error: $error');
      });

      _socket!.connect();
    } catch (e) {
      debugPrint('Error connecting to WebSocket: $e');
      rethrow;
    }
  }

  void disconnect() {
    if (_socket != null) {
      _socket!.disconnect();
      _socket = null;
      _connectionStatusController.value = false;
    }
  }

  void emit(String event, dynamic data) {
    if (_socket == null || !_socket!.connected) {
      debugPrint('Cannot emit - socket not connected');
      return;
    }
    _socket!.emit(event, data);
  }

  void on(String event, Function(dynamic) callback) {
    if (_socket == null) {
      debugPrint('Cannot listen - socket not initialized');
      return;
    }
    _socket!.on(event, callback);
  }

  void off(String event) {
    if (_socket == null) {
      return;
    }
    _socket!.off(event);
  }

  bool get isConnected => _socket != null && _socket!.connected;

  void dispose() {
    disconnect();
    _connectionStatusController.dispose();
  }
}
```

### File: `lib/services/solo_duel_game_service.dart`

```dart
import 'package:flutter/foundation.dart';
import '../domain/entities/solo_duel_match_entity.dart';
import './websocket_service.dart';
import './auth_service.dart';

class SoloDuelGameService {
  static SoloDuelGameService? _instance;

  final WebSocketService _webSocketService = WebSocketService.instance;
  final AuthService _authService = AuthService.instance;

  final _matchFoundController = ValueNotifier<Map<String, dynamic>?>(null);
  final _gameStartedController = ValueNotifier<bool>(false);
  final _cardFlippedController = ValueNotifier<Map<String, dynamic>?>(null);
  final _matchResultController = ValueNotifier<Map<String, dynamic>?>(null);
  final _gameOverController = ValueNotifier<Map<String, dynamic>?>(null);
  final _errorController = ValueNotifier<String?>(null);
  final _queueStatusController = ValueNotifier<Map<String, dynamic>?>(null);

  SoloDuelMatchEntity? _currentMatch;

  static SoloDuelGameService get instance {
    _instance ??= SoloDuelGameService._internal();
    return _instance!;
  }

  SoloDuelGameService._internal() {
    _setupWebSocketListeners();
  }

  ValueNotifier<Map<String, dynamic>?> get matchFound => _matchFoundController;
  ValueNotifier<bool> get gameStarted => _gameStartedController;
  ValueNotifier<Map<String, dynamic>?> get cardFlipped => _cardFlippedController;
  ValueNotifier<Map<String, dynamic>?> get matchResult => _matchResultController;
  ValueNotifier<Map<String, dynamic>?> get gameOver => _gameOverController;
  ValueNotifier<String?> get error => _errorController;
  ValueNotifier<Map<String, dynamic>?> get queueStatus => _queueStatusController;

  SoloDuelMatchEntity? get currentMatch => _currentMatch;

  void _setupWebSocketListeners() {
    _webSocketService.on('solo_duel:queue_joined', (data) {
      debugPrint('Queue joined: $data');
      _queueStatusController.value = data;
    });

    _webSocketService.on('solo_duel:match_found', (data) {
      debugPrint('Match found: $data');
      _matchFoundController.value = data;
      _initializeMatch(data);
    });

    _webSocketService.on('solo_duel:player_ready', (data) {
      debugPrint('Player ready: $data');
      _updatePlayerReady(data['userId']);
    });

    _webSocketService.on('solo_duel:game_started', (data) {
      debugPrint('Game started: $data');
      _gameStartedController.value = true;
      if (_currentMatch != null) {
        _currentMatch = _currentMatch!.copyWith(
          status: MatchStatus.playing,
          currentTurn: data['currentTurn'],
          startedAt: DateTime.parse(data['startedAt']),
        );
      }
    });

    _webSocketService.on('solo_duel:card_flipped', (data) {
      debugPrint('Card flipped: $data');
      _cardFlippedController.value = data;
      _updateCardFlipped(data);
    });

    _webSocketService.on('solo_duel:match_result', (data) {
      debugPrint('Match result: $data');
      _matchResultController.value = data;
      _updateMatchResult(data);
    });

    _webSocketService.on('solo_duel:game_over', (data) {
      debugPrint('Game over: $data');
      _gameOverController.value = data;
    });

    _webSocketService.on('solo_duel:player_disconnected', (data) {
      debugPrint('Player disconnected: $data');
      _errorController.value = 'Người chơi ${data['username']} đã ngắt kết nối';
    });

    _webSocketService.on('solo_duel:error', (data) {
      debugPrint('Error: $data');
      _errorController.value = data['message'];
    });

    _webSocketService.on('solo_duel:queue_left', (data) {
      debugPrint('Queue left');
      _queueStatusController.value = null;
    });
  }

  void _initializeMatch(Map<String, dynamic> data) {
    final myUserId = _authService.currentUser?.id ?? '';
    final opponentData = data['opponent'];
    final pokemonList = List<Map<String, dynamic>>.from(data['pokemon']);

    final cards = <SoloDuelCardEntity>[];
    for (int i = 0; i < pokemonList.length; i++) {
      cards.add(SoloDuelCardEntity(
        pokemonId: pokemonList[i]['pokemonId'],
        pokemonName: pokemonList[i]['pokemonName'],
        isFlipped: false,
        isMatched: false,
        position: i,
      ));
    }

    final players = [
      PlayerEntity(
        userId: myUserId,
        username: _authService.currentUser?.username ?? '',
        score: 0,
        matchedCards: 0,
        isReady: false,
      ),
      PlayerEntity(
        userId: opponentData['userId'],
        username: opponentData['username'],
        score: 0,
        matchedCards: 0,
        isReady: false,
      ),
    ];

    _currentMatch = SoloDuelMatchEntity(
      matchId: data['matchId'],
      status: MatchStatus.ready,
      players: players,
      cards: cards,
      currentTurn: data['isFirstPlayer'] ? myUserId : opponentData['userId'],
      flippedCards: [],
    );
  }

  void _updatePlayerReady(String userId) {
    if (_currentMatch == null) return;

    final updatedPlayers = _currentMatch!.players.map((player) {
      if (player.userId == userId) {
        return player.copyWith(isReady: true);
      }
      return player;
    }).toList();

    _currentMatch = _currentMatch!.copyWith(players: updatedPlayers);
  }

  void _updateCardFlipped(Map<String, dynamic> data) {
    if (_currentMatch == null) return;

    final cardIndex = data['cardIndex'];
    final flippedBy = data['flippedBy'];

    final updatedCards = List<SoloDuelCardEntity>.from(_currentMatch!.cards);
    updatedCards[cardIndex] = updatedCards[cardIndex].copyWith(
      isFlipped: true,
      flippedBy: flippedBy,
    );

    _currentMatch = _currentMatch!.copyWith(cards: updatedCards);
  }

  void _updateMatchResult(Map<String, dynamic> data) {
    if (_currentMatch == null) return;

    final isMatch = data['isMatch'];
    final cardIndices = List<int>.from(data['cardIndices']);
    final matchedBy = data['matchedBy'];
    final nextTurn = data['nextTurn'];
    final playersData = List<Map<String, dynamic>>.from(data['players']);

    final updatedCards = List<SoloDuelCardEntity>.from(_currentMatch!.cards);

    if (isMatch) {
      for (final index in cardIndices) {
        updatedCards[index] = updatedCards[index].copyWith(
          isMatched: true,
          matchedBy: matchedBy,
        );
      }
    } else {
      for (final index in cardIndices) {
        updatedCards[index] = updatedCards[index].copyWith(
          isFlipped: false,
          flippedBy: null,
        );
      }
    }

    final updatedPlayers = _currentMatch!.players.map((player) {
      final playerData = playersData.firstWhere(
        (p) => p['userId'] == player.userId,
        orElse: () => {},
      );
      if (playerData.isNotEmpty) {
        return player.copyWith(
          score: playerData['score'],
          matchedCards: playerData['matchedCards'],
        );
      }
      return player;
    }).toList();

    _currentMatch = _currentMatch!.copyWith(
      cards: updatedCards,
      players: updatedPlayers,
      currentTurn: nextTurn,
    );
  }

  // Actions
  Future<void> joinQueue() async {
    if (!_webSocketService.isConnected) {
      await _webSocketService.connect();
    }
    _webSocketService.emit('solo_duel:join_queue', {});
  }

  void leaveQueue() {
    _webSocketService.emit('solo_duel:leave_queue', {});
  }

  void joinMatch(String matchId) {
    _webSocketService.emit('solo_duel:join_match', {'matchId': matchId});
  }

  void setPlayerReady(String matchId) {
    _webSocketService.emit('solo_duel:player_ready', {'matchId': matchId});
  }

  void flipCard(String matchId, int cardIndex) {
    _webSocketService.emit('solo_duel:flip_card', {
      'matchId': matchId,
      'cardIndex': cardIndex,
    });
  }

  void resetMatch() {
    _currentMatch = null;
    _matchFoundController.value = null;
    _gameStartedController.value = false;
    _cardFlippedController.value = null;
    _matchResultController.value = null;
    _gameOverController.value = null;
    _errorController.value = null;
    _queueStatusController.value = null;
  }

  void dispose() {
    _matchFoundController.dispose();
    _gameStartedController.dispose();
    _cardFlippedController.dispose();
    _matchResultController.dispose();
    _gameOverController.dispose();
    _errorController.dispose();
    _queueStatusController.dispose();
  }
}
```

---

## 3. Screens

### File: `lib/presentation/screens/ganme_solo_duel_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import '../../services/solo_duel_game_service.dart';
import '../../services/auth_service.dart';
import '../widgets/custom/custom_button.dart';
import './ganme_solo_duel_match_screen.dart';

class SoloDuelScreen extends StatefulWidget {
  const SoloDuelScreen({super.key});

  @override
  State<SoloDuelScreen> createState() => _SoloDuelScreenState();
}

class _SoloDuelScreenState extends State<SoloDuelScreen> {
  final _gameService = SoloDuelGameService.instance;
  final _authService = AuthService.instance;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _setupListeners();
  }

  void _setupListeners() {
    _gameService.matchFound.addListener(_onMatchFound);
    _gameService.error.addListener(_onError);
  }

  @override
  void dispose() {
    _gameService.matchFound.removeListener(_onMatchFound);
    _gameService.error.removeListener(_onError);
    super.dispose();
  }

  void _onMatchFound() {
    final matchData = _gameService.matchFound.value;
    if (matchData != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SoloDuelMatchScreen(
            matchId: matchData['matchId'],
          ),
        ),
      );
    }
  }

  void _onError() {
    final error = _gameService.error.value;
    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _startMatchmaking() async {
    setState(() {
      _isSearching = true;
    });

    try {
      await _gameService.joinQueue();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isSearching = false;
      });
    }
  }

  void _cancelMatchmaking() {
    _gameService.leaveQueue();
    setState(() {
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đấu đơn'),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFF9800), Color(0xFFE65100)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Player Info Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        offset: const Offset(4, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Pixel.user,
                        size: 64,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        user?.username ?? 'Người chơi',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sẵn sàng chiến đấu!',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Game Rules
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        offset: const Offset(4, 4),
                        blurRadius: 0,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Pixel.info, color: Colors.orange.shade700),
                          const SizedBox(width: 8),
                          const Text(
                            'Luật chơi',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildRuleItem('12 cặp thẻ Pokemon ngẫu nhiên'),
                      _buildRuleItem('Lượt chơi xen kẽ giữa 2 người'),
                      _buildRuleItem('Match được = 100 điểm'),
                      _buildRuleItem('Người có điểm cao hơn thắng'),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Matchmaking Button
                if (!_isSearching)
                  SizedBox(
                    width: 250,
                    child: CustomButton(
                      type: CustomButtonType.primary,
                      onPressed: _startMatchmaking,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Pixel.zap, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Tìm đối thủ',
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Column(
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Đang tìm đối thủ...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 200,
                        child: CustomButton(
                          type: CustomButtonType.warning,
                          onPressed: _cancelMatchmaking,
                          child: const Text(
                            'Hủy',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRuleItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
```

### File: `lib/presentation/screens/ganme_solo_duel_match_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import 'dart:async';
import '../../services/solo_duel_game_service.dart';
import '../../services/auth_service.dart';
import '../../services/image_cache_service.dart';
import '../widgets/custom/custom_button.dart';
import '../widgets/common/solo_duel_card_widget.dart';

class SoloDuelMatchScreen extends StatefulWidget {
  final String matchId;

  const SoloDuelMatchScreen({
    super.key,
    required this.matchId,
  });

  @override
  State<SoloDuelMatchScreen> createState() => _SoloDuelMatchScreenState();
}

class _SoloDuelMatchScreenState extends State<SoloDuelMatchScreen>
    with TickerProviderStateMixin {
  final _gameService = SoloDuelGameService.instance;
  final _authService = AuthService.instance;

  late AnimationController _flipController;
  bool _isReady = false;
  Timer? _turnTimer;
  int _currentTurnFlips = 0;
  List<int> _currentFlippedIndices = [];

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _gameService.joinMatch(widget.matchId);
    _setupListeners();
  }

  @override
  void dispose() {
    _flipController.dispose();
    _turnTimer?.cancel();
    super.dispose();
  }

  void _setupListeners() {
    _gameService.gameStarted.addListener(_onGameStarted);
    _gameService.cardFlipped.addListener(_onCardFlipped);
    _gameService.matchResult.addListener(_onMatchResult);
    _gameService.gameOver.addListener(_onGameOver);
    _gameService.error.addListener(_onError);
  }

  void _onGameStarted() {
    if (_gameService.gameStarted.value && mounted) {
      setState(() {});
    }
  }

  void _onCardFlipped() {
    final data = _gameService.cardFlipped.value;
    if (data != null && mounted) {
      setState(() {});
      _flipController.forward().then((_) => _flipController.reset());
    }
  }

  void _onMatchResult() {
    final data = _gameService.matchResult.value;
    if (data != null && mounted) {
      Timer(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            _currentTurnFlips = 0;
            _currentFlippedIndices.clear();
          });
        }
      });
    }
  }

  void _onGameOver() {
    final data = _gameService.gameOver.value;
    if (data != null && mounted) {
      _showGameOverDialog(data);
    }
  }

  void _onError() {
    final error = _gameService.error.value;
    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _setReady() {
    setState(() {
      _isReady = true;
    });
    _gameService.setPlayerReady(widget.matchId);
  }

  void _onCardTap(int index) {
    final match = _gameService.currentMatch;
    if (match == null) return;

    final myUserId = _authService.currentUser?.id ?? '';

    if (match.currentTurn != myUserId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chưa đến lượt của bạn!'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    final card = match.cards[index];
    if (card.isMatched || card.isFlipped) {
      return;
    }

    if (_currentTurnFlips >= 2) {
      return;
    }

    setState(() {
      _currentTurnFlips++;
      _currentFlippedIndices.add(index);
    });

    _gameService.flipCard(widget.matchId, index);
  }

  void _showGameOverDialog(Map<String, dynamic> data) {
    final myUserId = _authService.currentUser?.id ?? '';
    final isWinner = data['winner'] == myUserId;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          isWinner ? 'Chiến thắng!' : 'Thất bại!',
          style: TextStyle(
            color: isWinner ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isWinner ? Pixel.trophy : Pixel.close,
              size: 64,
              color: isWinner ? Colors.amber : Colors.red,
            ),
            const SizedBox(height: 16),
            ...List.generate(
              (data['players'] as List).length,
              (index) {
                final player = data['players'][index];
                final isMe = player['userId'] == myUserId;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    '${isMe ? "Bạn" : player['username']}: ${player['score']} điểm (${player['matchedCards']} cặp)',
                    style: TextStyle(
                      fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          CustomButton(
            type: CustomButtonType.primary,
            onPressed: () {
              _gameService.resetMatch();
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text('Về trang chủ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final match = _gameService.currentMatch;

    if (match == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final myUserId = _authService.currentUser?.id ?? '';
    final opponent = match.players.firstWhere(
      (p) => p.userId != myUserId,
      orElse: () => match.players.first,
    );
    final me = match.players.firstWhere(
      (p) => p.userId == myUserId,
      orElse: () => match.players.first,
    );

    final isMyTurn = match.currentTurn == myUserId;
    final isGameStarted = match.status == MatchStatus.playing;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đấu đơn'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Pixel.arrowLeft),
          onPressed: () {
            // Show confirmation dialog
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Rời trận?'),
                content: const Text('Bạn có chắc muốn rời trận đấu?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Ở lại'),
                  ),
                  TextButton(
                    onPressed: () {
                      _gameService.resetMatch();
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    child: const Text('Rời trận'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFF9800), Color(0xFFE65100)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Player Stats
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildPlayerCard(me, isMe: true, isActive: isMyTurn && isGameStarted),
                    Icon(
                      Pixel.sword,
                      size: 32,
                      color: Colors.white,
                    ),
                    _buildPlayerCard(opponent, isMe: false, isActive: !isMyTurn && isGameStarted),
                  ],
                ),
              ),

              // Turn Indicator
              if (isGameStarted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: isMyTurn ? Colors.green : Colors.orange,
                    border: Border.all(color: Colors.black, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    isMyTurn ? 'Lượt của bạn!' : 'Lượt đối thủ...',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              // Game Board
              Expanded(
                child: !isGameStarted
                    ? _buildReadyScreen()
                    : _buildGameBoard(match),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayerCard(PlayerEntity player, {required bool isMe, required bool isActive}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: isActive ? (isMe ? Colors.blue : Colors.orange) : Colors.black,
          width: isActive ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            offset: const Offset(2, 2),
            blurRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Pixel.user,
            size: 32,
            color: isActive ? (isMe ? Colors.blue : Colors.orange) : Colors.grey,
          ),
          const SizedBox(height: 4),
          Text(
            isMe ? 'Bạn' : player.username,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '${player.score} điểm',
            style: const TextStyle(fontSize: 10),
          ),
          Text(
            '${player.matchedCards} cặp',
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildReadyScreen() {
    final match = _gameService.currentMatch!;
    final allReady = match.players.every((p) => p.isReady);

    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.black,
              offset: const Offset(4, 4),
              blurRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Pixel.zap, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            const Text(
              'Sẵn sàng chiến đấu?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ...match.players.map((player) {
              final myUserId = _authService.currentUser?.id ?? '';
              final isMe = player.userId == myUserId;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      player.isReady ? Pixel.check : Pixel.close,
                      color: player.isReady ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isMe ? 'Bạn' : player.username,
                      style: TextStyle(
                        fontWeight: player.isReady ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            const SizedBox(height: 24),
            if (!_isReady)
              CustomButton(
                type: CustomButtonType.primary,
                onPressed: _setReady,
                child: const Text('Sẵn sàng!'),
              )
            else if (!allReady)
              const Text(
                'Đang chờ đối thủ...',
                style: TextStyle(
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameBoard(SoloDuelMatchEntity match) {
    final myUserId = _authService.currentUser?.id ?? '';

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.7,
      ),
      itemCount: match.cards.length,
      itemBuilder: (context, index) {
        final card = match.cards[index];
        final pokemon = PokemonEntity(
          id: card.pokemonId,
          name: card.pokemonName,
          imagePath: 'images/${card.pokemonName}.png',
        );

        return SoloDuelCardWidget(
          card: card,
          pokemon: pokemon,
          onTap: () => _onCardTap(index),
          isMyTurn: match.currentTurn == myUserId,
          flipController: _flipController,
        );
      },
    );
  }
}

class PokemonEntity {
  final int id;
  final String name;
  final String imagePath;

  const PokemonEntity({
    required this.id,
    required this.name,
    required this.imagePath,
  });
}
```

---

## 4. Widgets

### File: `lib/presentation/widgets/common/solo_duel_card_widget.dart`

```dart
import 'package:flutter/material.dart';
import '../../../domain/entities/solo_duel_match_entity.dart';
import '../../../services/auth_service.dart';

class SoloDuelCardWidget extends StatelessWidget {
  final SoloDuelCardEntity card;
  final PokemonEntity pokemon;
  final VoidCallback onTap;
  final bool isMyTurn;
  final AnimationController flipController;

  const SoloDuelCardWidget({
    super.key,
    required this.card,
    required this.pokemon,
    required this.onTap,
    required this.isMyTurn,
    required this.flipController,
  });

  @override
  Widget build(BuildContext context) {
    final myUserId = AuthService.instance.currentUser?.id ?? '';
    final isFlippedByMe = card.flippedBy == myUserId;
    final isFlippedByOpponent = card.flippedBy != null && !isFlippedByMe;

    Color? borderColor;
    double borderWidth = 2;

    if (card.isMatched) {
      borderColor = card.matchedBy == myUserId ? Colors.blue : Colors.orange;
      borderWidth = 3;
    } else if (card.isFlipped) {
      if (isFlippedByMe) {
        borderColor = Colors.blue; // Viền xanh cho thẻ của mình
        borderWidth = 3;
      } else if (isFlippedByOpponent) {
        borderColor = Colors.yellow; // Viền vàng cho thẻ đối thủ
        borderWidth = 3;
      }
    }

    return GestureDetector(
      onTap: (card.isMatched || card.isFlipped || !isMyTurn) ? null : onTap,
      child: AnimatedBuilder(
        animation: flipController,
        builder: (context, child) {
          final angle = flipController.value * 3.14159;
          final showFront = angle < 1.5708;

          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: borderColor ?? Colors.black,
                  width: borderWidth,
                ),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: const Offset(2, 2),
                  ),
                ],
              ),
              child: showFront && !card.isFlipped
                  ? _buildCardBack()
                  : _buildCardFront(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCardBack() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.red.shade400, Colors.red.shade700],
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Center(
        child: Icon(
          Icons.catching_pokemon,
          size: 40,
          color: Colors.white.withOpacity(0.5),
        ),
      ),
    );
  }

  Widget _buildCardFront() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/${pokemon.imagePath}',
            fit: BoxFit.cover,
          ),
          if (card.isMatched)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
```

---

## 5. Navigation Integration

### Update `lib/presentation/screens/game_match_screen.dart`

```dart
// In the Solo Duel GameModeCard onTap:
onTap: _isLoggedIn
    ? () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SoloDuelScreen(),
          ),
        );
      }
    : () => _handleLockedCardTap('Solo Duel'),
```

---

## 6. Dependencies

### Update `pubspec.yaml`

```yaml
dependencies:
    flutter:
        sdk: flutter
    pixelarticons: ^0.4.0
    flutter_cube: ^0.1.1
    http: ^1.2.0
    shared_preferences: ^2.2.2
    equatable: ^2.0.5
    path_provider: ^2.1.2
    image_picker: ^1.0.7
    just_audio: ^0.9.36
    socket_io_client: ^2.0.3+1 # MỚI - WebSocket client
```

---

## 7. Request Service Integration

### Update `lib/services/request_service.dart`

```dart
// Thêm imports
import '../data/datasources/solo_duel_remote_data_source.dart';
import '../data/repositories/solo_duel_repository_impl.dart';
import '../domain/repositories/solo_duel_repository.dart';
import '../domain/usecases/get_solo_duel_histories_use_case.dart';
import '../domain/usecases/get_solo_duel_history_use_case.dart';
import '../domain/entities/solo_duel_history_entity.dart';

// Thêm vào class RequestService:
late final SoloDuelRemoteDataSource _soloDuelRemoteDataSource;
late final SoloDuelRepository _soloDuelRepository;
late final GetSoloDuelHistoriesUseCase _getSoloDuelHistoriesUseCase;
late final GetSoloDuelHistoryUseCase _getSoloDuelHistoryUseCase;

// Trong _initialize():
_soloDuelRemoteDataSource = SoloDuelRemoteDataSourceImpl(
  httpClient: _httpClient,
  tokenStorage: _tokenStorage,
);
_soloDuelRepository = SoloDuelRepositoryImpl(
  remoteDataSource: _soloDuelRemoteDataSource,
);
_getSoloDuelHistoriesUseCase = GetSoloDuelHistoriesUseCase(_soloDuelRepository);
_getSoloDuelHistoryUseCase = GetSoloDuelHistoryUseCase(_soloDuelRepository);

// Thêm methods:
Future<Result<SoloDuelHistoriesResponse>> getSoloDuelHistories({
  int page = 1,
  int limit = 10,
  bool? isWin,
  String sortBy = 'datePlayed',
  String order = 'desc',
}) async {
  return await _getSoloDuelHistoriesUseCase(
    page: page,
    limit: limit,
    isWin: isWin,
    sortBy: sortBy,
    order: order,
  );
}

Future<Result<SoloDuelHistoryEntity>> getSoloDuelHistory(String id) async {
  return await _getSoloDuelHistoryUseCase(id);
}
```

---

## Tổng kết

### Luồng hoạt động:

1. **Tìm trận**: User nhấn "Tìm đối thủ" → WebSocket emit `solo_duel:join_queue`
2. **Ghép trận**: Server tìm thấy 2 người → Emit `solo_duel:match_found` với Pokemon list
3. **Sẵn sàng**: Cả 2 người nhấn "Sẵn sàng" → Game bắt đầu
4. **Chơi game**:
    - Người chơi lật thẻ → Emit `solo_duel:flip_card`
    - Server broadcast → Cả 2 người nhìn thấy thẻ được lật
    - Thẻ của mình đang pick: viền xanh
    - Thẻ của đối thủ đang pick: viền vàng
5. **Kết thúc**: Hết thẻ → Server tính điểm → Hiện kết quả → Lưu lịch sử

### Đặc điểm kỹ thuật:

-   **Real-time sync** với WebSocket
-   **Clean Architecture** giống phần Offline
-   **State management** với ValueNotifier
-   **Error handling** đầy đủ
-   **UI responsive** với animation

Tất cả code tuân thủ cấu trúc và pattern của dự án hiện tại!
