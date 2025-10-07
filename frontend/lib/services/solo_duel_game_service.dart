import 'package:flutter/foundation.dart';
import '../domain/entities/solo_duel_match_entity.dart';
import './websocket_service.dart';
import './auth_service.dart';
import './token_storage_service.dart';
import './request_service.dart';

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
  ValueNotifier<Map<String, dynamic>?> get cardFlipped =>
      _cardFlippedController;
  ValueNotifier<Map<String, dynamic>?> get matchResult =>
      _matchResultController;
  ValueNotifier<Map<String, dynamic>?> get gameOver => _gameOverController;
  ValueNotifier<String?> get error => _errorController;
  ValueNotifier<Map<String, dynamic>?> get queueStatus =>
      _queueStatusController;

  SoloDuelMatchEntity? get currentMatch => _currentMatch;

  void _setupWebSocketListeners() {
    _webSocketService.on('solo_duel:queue_joined', (data) {
      _queueStatusController.value = data;
    });

    _webSocketService.on('solo_duel:match_found', (data) {
      _matchFoundController.value = data;
      _initializeMatch(data);
    });

    _webSocketService.on('solo_duel:player_ready', (data) {
      _updatePlayerReady(data['userId']);
    });

    _webSocketService.on('solo_duel:game_started', (data) {
      _gameStartedController.value = true;
      if (_currentMatch != null) {
        if (data['players'] != null) {
          final playersData = List<Map<String, dynamic>>.from(data['players']);
          final updatedPlayers = _currentMatch!.players.map((player) {
            final playerData = playersData.firstWhere((p) {
              final userId = p['userId'];
              if (userId is Map) {
                return userId['_id'].toString() == player.userId;
              }
              return userId.toString() == player.userId;
            }, orElse: () => {});
            if (playerData.isNotEmpty) {
              return player.copyWith(
                score: playerData['score'],
                matchedCards: playerData['matchedCards'],
              );
            }
            return player;
          }).toList();

          _currentMatch = _currentMatch!.copyWith(
            status: MatchStatus.playing,
            currentTurn: data['currentTurn'],
            startedAt: DateTime.parse(data['startedAt']),
            players: updatedPlayers,
          );
        } else {
          _currentMatch = _currentMatch!.copyWith(
            status: MatchStatus.playing,
            currentTurn: data['currentTurn'],
            startedAt: DateTime.parse(data['startedAt']),
          );
        }
      }
    });

    _webSocketService.on('solo_duel:card_flipped', (data) {
      _cardFlippedController.value = data;
      _updateCardFlipped(data);
    });

    _webSocketService.on('solo_duel:match_result', (data) {
      _matchResultController.value = data;
      _updateMatchResult(data);
    });

    _webSocketService.on('solo_duel:game_over', (data) {
      _gameOverController.value = data;
    });

    _webSocketService.on('solo_duel:player_disconnected', (data) {
      _errorController.value = 'Người chơi ${data['username']} đã ngắt kết nối';
    });

    _webSocketService.on('solo_duel:error', (data) {
      _errorController.value = data['message'];
    });

    _webSocketService.on('solo_duel:queue_left', (data) {
      _queueStatusController.value = null;
    });
  }

  void _initializeMatch(Map<String, dynamic> data) {
    final myUserId = _authService.currentUser?.id ?? '';
    final opponentData = data['opponent'];
    final pokemonList = List<Map<String, dynamic>>.from(data['pokemon']);

    final cards = <SoloDuelCardEntity>[];
    for (int i = 0; i < pokemonList.length; i++) {
      cards.add(
        SoloDuelCardEntity(
          pokemonId: pokemonList[i]['pokemonId'],
          pokemonName: pokemonList[i]['pokemonName'],
          isFlipped: false,
          isMatched: false,
          position: i,
        ),
      );
    }

    final players = [
      PlayerEntity(
        userId: myUserId,
        username: _authService.currentUser?.username ?? '',
        score: 0,
        matchedCards: 0,
        isReady: false,
        avatar: _authService.currentUser?.avatar,
      ),
      PlayerEntity(
        userId: opponentData['userId'],
        username: opponentData['username'],
        score: 0,
        matchedCards: 0,
        isReady: false,
        avatar: opponentData['avatar'],
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
      final playerData = playersData.firstWhere((p) {
        final userId = p['userId'];
        if (userId is Map) {
          return userId['_id'].toString() == player.userId;
        }
        return userId.toString() == player.userId;
      }, orElse: () => {});
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
    final tokenStorage = TokenStorageImpl();
    if (await tokenStorage.isAccessTokenExpired()) {
      final requestService = RequestService.instance;
      final refreshResult = await requestService.refreshToken();
      if (!refreshResult.isSuccess) {
        _errorController.value = 'Failed to refresh authentication token';
        return;
      }
    }

    if (!_webSocketService.isConnected) {
      await _webSocketService.connect();
    }
    _webSocketService.emit('solo_duel:join_queue', {});
  }

  void leaveQueue() {
    _webSocketService.emit('solo_duel:leave_queue', {});
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

  void pauseMatch(String matchId) {
    _webSocketService.emit('solo_duel:pause', {'matchId': matchId});
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
