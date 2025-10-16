import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../domain/entities/solo_duel_match_entity.dart';
import './websocket_service.dart';
import './auth_service.dart';
import './token_storage_service.dart';
import './request_service.dart';

class SoloDuelGameService {
  static SoloDuelGameService? _instance;
  static const String _activeMatchKey = 'active_solo_duel_match';

  final WebSocketService _webSocketService = WebSocketService.instance;
  final AuthService _authService = AuthService.instance;

  final _matchFoundController = ValueNotifier<Map<String, dynamic>?>(null);
  final _gameStartedController = ValueNotifier<bool>(false);
  final _cardFlippedController = ValueNotifier<Map<String, dynamic>?>(null);
  final _matchResultController = ValueNotifier<Map<String, dynamic>?>(null);
  final _gameOverController = ValueNotifier<Map<String, dynamic>?>(null);
  final _errorController = ValueNotifier<String?>(null);
  final _queueStatusController = ValueNotifier<Map<String, dynamic>?>(null);
  final _playerReadyController = ValueNotifier<String?>(null);
  final _playerDisconnectedController = ValueNotifier<Map<String, dynamic>?>(
    null,
  );
  final _playerReconnectedController = ValueNotifier<Map<String, dynamic>?>(
    null,
  );
  final _matchStateController = ValueNotifier<Map<String, dynamic>?>(null);
  final _currentMatchController = ValueNotifier<SoloDuelMatchEntity?>(null);

  SoloDuelMatchEntity? _currentMatch;
  bool _isInitialized = false;

  static SoloDuelGameService get instance {
    _instance ??= SoloDuelGameService._internal();
    return _instance!;
  }

  SoloDuelGameService._internal() {
    _setupWebSocketListeners();
    _initializeService();
  }

  Future<void> _initializeService() async {
    await _loadActiveMatch();
    _isInitialized = true;
  }

  Future<void> waitForInitialization() async {
    while (!_isInitialized) {
      await Future.delayed(const Duration(milliseconds: 10));
    }
  }

  Future<void> _loadActiveMatch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final matchData = prefs.getString(_activeMatchKey);
      if (matchData != null) {
        final data = Map<String, dynamic>.from(jsonDecode(matchData));
        final status = data['status'] as String?;
        if (status == 'ready' || status == 'playing') {
          _updateCurrentMatch(
            SoloDuelMatchEntity(
              matchId: data['matchId'],
              status: _parseMatchStatus(status),
              players: [],
              cards: [],
              currentTurn: data['currentTurn'],
              flippedCards: [],
            ),
          );
        } else {
          await _clearActiveMatch();
        }
      }
    } catch (e) {
      throw Exception('Error loading active match: $e');
    }
  }

  Future<void> _saveActiveMatch() async {
    if (_currentMatch == null) {
      await _clearActiveMatch();
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final matchData = {
        'matchId': _currentMatch!.matchId,
        'status': _currentMatch!.status.toString().split('.').last,
        'currentTurn': _currentMatch!.currentTurn,
      };
      await prefs.setString(_activeMatchKey, jsonEncode(matchData));
    } catch (e) {
      throw Exception('Error saving active match: $e');
    }
  }

  Future<void> _clearActiveMatch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_activeMatchKey);
    } catch (e) {
      throw Exception('Error clearing active match: $e');
    }
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
  ValueNotifier<String?> get playerReady => _playerReadyController;
  ValueNotifier<Map<String, dynamic>?> get playerDisconnected =>
      _playerDisconnectedController;
  ValueNotifier<Map<String, dynamic>?> get playerReconnected =>
      _playerReconnectedController;
  ValueNotifier<Map<String, dynamic>?> get matchState => _matchStateController;

  ValueNotifier<SoloDuelMatchEntity?> get currentMatchNotifier =>
      _currentMatchController;

  SoloDuelMatchEntity? get currentMatch => _currentMatch;

  void _updateCurrentMatch(SoloDuelMatchEntity? match) {
    _currentMatch = match;
    _currentMatchController.value = match;
  }

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
      _playerReadyController.value = data['userId'];
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

          _updateCurrentMatch(
            _currentMatch!.copyWith(
              status: MatchStatus.playing,
              currentTurn: data['currentTurn'],
              startedAt: DateTime.parse(data['startedAt']),
              players: updatedPlayers,
            ),
          );
        } else {
          _updateCurrentMatch(
            _currentMatch!.copyWith(
              status: MatchStatus.playing,
              currentTurn: data['currentTurn'],
              startedAt: DateTime.parse(data['startedAt']),
            ),
          );
        }
        _saveActiveMatch();
      }
    });

    _webSocketService.on('solo_duel:card_flipped', (data) {
      _cardFlippedController.value = data;
      _updateCardFlipped(data);
    });

    _webSocketService.on('solo_duel:match_result', (data) {
      _updateMatchResult(data);
      _matchResultController.value = {
        ...data,
        '_timestamp': DateTime.now().millisecondsSinceEpoch,
      };
    });

    _webSocketService.on('solo_duel:game_over', (data) {
      _gameOverController.value = data;
      _clearActiveMatch();
    });

    _webSocketService.on('solo_duel:player_disconnected', (data) {
      _playerDisconnectedController.value = data;
      if (_currentMatch != null) {
        final disconnectedUserId = data['userId'];
        final updatedPlayers = _currentMatch!.players.map((player) {
          if (player.userId == disconnectedUserId) {
            return player.copyWith(isConnected: false);
          }
          return player;
        }).toList();
        _updateCurrentMatch(_currentMatch!.copyWith(players: updatedPlayers));
      }
    });

    _webSocketService.on('solo_duel:player_reconnected', (data) {
      _playerReconnectedController.value = data;
      if (_currentMatch != null) {
        final reconnectedUserId = data['userId'];
        final updatedPlayers = _currentMatch!.players.map((player) {
          if (player.userId == reconnectedUserId) {
            return player.copyWith(isConnected: true);
          }
          return player;
        }).toList();
        _updateCurrentMatch(_currentMatch!.copyWith(players: updatedPlayers));
      }
    });

    _webSocketService.on('solo_duel:match_state', (data) {
      _matchStateController.value = data;
      _updateMatchState(data);
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

    _updateCurrentMatch(
      SoloDuelMatchEntity(
        matchId: data['matchId'],
        status: MatchStatus.ready,
        players: players,
        cards: cards,
        currentTurn: data['isFirstPlayer'] ? myUserId : opponentData['userId'],
        flippedCards: [],
      ),
    );

    _saveActiveMatch();
  }

  void _updatePlayerReady(String userId) {
    if (_currentMatch == null) return;

    final updatedPlayers = _currentMatch!.players.map((player) {
      if (player.userId == userId) {
        return player.copyWith(isReady: true);
      }
      return player;
    }).toList();

    _updateCurrentMatch(_currentMatch!.copyWith(players: updatedPlayers));
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

    final updatedFlippedCards = List<FlippedCardEntity>.from(
      _currentMatch!.flippedCards,
    );
    updatedFlippedCards.add(
      FlippedCardEntity(
        cardIndex: cardIndex,
        flippedBy: flippedBy,
        flippedAt: DateTime.now(),
      ),
    );

    _updateCurrentMatch(
      _currentMatch!.copyWith(
        cards: updatedCards,
        flippedCards: updatedFlippedCards,
      ),
    );
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
          isFlipped: false,
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
      Map<String, dynamic>? playerData;
      try {
        playerData = playersData.firstWhere((p) {
          final userId = p['userId'];
          String userIdStr = userId.toString();
          return userIdStr == player.userId;
        });
      } catch (e) {
        playerData = null;
      }

      if (playerData != null) {
        final newScore = playerData['score'] as int? ?? player.score;
        final newMatchedCards =
            playerData['matchedCards'] as int? ?? player.matchedCards;

        return player.copyWith(score: newScore, matchedCards: newMatchedCards);
      }
      return player;
    }).toList();

    _updateCurrentMatch(
      _currentMatch!.copyWith(
        cards: updatedCards,
        players: updatedPlayers,
        currentTurn: nextTurn,
        flippedCards: [],
      ),
    );
  }

  void _updateMatchState(Map<String, dynamic> data) {
    if (_currentMatch == null) return;

    final playersData = List<Map<String, dynamic>>.from(data['players'] ?? []);
    final cardsData = List<Map<String, dynamic>>.from(data['cards'] ?? []);
    final myUserId = _authService.currentUser?.id ?? '';

    final updatedPlayers = playersData.map((playerData) {
      final userId = playerData['userId'].toString();
      String? avatar;

      if (playerData['avatar'] != null) {
        avatar = playerData['avatar'];
      } else if (_currentMatch!.players.isNotEmpty) {
        final existingPlayer = _currentMatch!.players.firstWhere(
          (p) => p.userId == userId,
          orElse: () => PlayerEntity(
            userId: '',
            username: '',
            score: 0,
            matchedCards: 0,
            isReady: false,
          ),
        );

        if (existingPlayer.userId.isNotEmpty) {
          avatar = existingPlayer.avatar;
        }
      }

      if (avatar == null && userId == myUserId) {
        avatar = _authService.currentUser?.avatar;
      }

      return PlayerEntity(
        userId: userId,
        username: playerData['username'],
        score: playerData['score'],
        matchedCards: playerData['matchedCards'],
        isReady: true,
        isConnected: playerData['isConnected'] ?? true,
        avatar: avatar,
      );
    }).toList();

    final updatedCards = <SoloDuelCardEntity>[];
    for (int i = 0; i < cardsData.length; i++) {
      final cardData = cardsData[i];
      updatedCards.add(
        SoloDuelCardEntity(
          pokemonId: cardData['pokemonId'],
          pokemonName: cardData['pokemonName'],
          isFlipped: false,
          isMatched: cardData['isMatched'],
          matchedBy: cardData['matchedBy'],
          position: i,
        ),
      );
    }

    _updateCurrentMatch(
      _currentMatch!.copyWith(
        status: _parseMatchStatus(data['status']),
        currentTurn: data['currentTurn'],
        players: updatedPlayers,
        cards: updatedCards,
      ),
    );
  }

  MatchStatus _parseMatchStatus(String? status) {
    switch (status) {
      case 'waiting':
        return MatchStatus.waiting;
      case 'ready':
        return MatchStatus.ready;
      case 'playing':
        return MatchStatus.playing;
      case 'completed':
        return MatchStatus.completed;
      case 'cancelled':
        return MatchStatus.cancelled;
      default:
        return MatchStatus.waiting;
    }
  }

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

  void surrender(String matchId) {
    _webSocketService.emit('solo_duel:surrender', {'matchId': matchId});
  }

  Future<void> rejoinMatch(String matchId) async {
    if (!_webSocketService.isConnected) {
      await _webSocketService.connect();
    }
    _webSocketService.emit('solo_duel:rejoin_match', {'matchId': matchId});
  }

  void pauseMatch(String matchId) {
    _webSocketService.emit('solo_duel:pause', {'matchId': matchId});
  }

  void resetMatch() {
    _updateCurrentMatch(null);
    _matchFoundController.value = null;
    _gameStartedController.value = false;
    _cardFlippedController.value = null;
    _matchResultController.value = null;
    _gameOverController.value = null;
    _errorController.value = null;
    _queueStatusController.value = null;
    _playerReadyController.value = null;
    _clearActiveMatch();
  }

  void dispose() {
    _matchFoundController.dispose();
    _gameStartedController.dispose();
    _cardFlippedController.dispose();
    _matchResultController.dispose();
    _gameOverController.dispose();
    _errorController.dispose();
    _queueStatusController.dispose();
    _playerReadyController.dispose();
    _currentMatchController.dispose();
  }
}
