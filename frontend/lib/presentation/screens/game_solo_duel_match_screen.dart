import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:typed_data';
import '../../services/solo_duel_game_service.dart';
import '../../services/auth_service.dart';
import '../../services/sound_service.dart';
import '../../domain/entities/solo_duel_match_entity.dart';
import '../widgets/common/animated_not_your_turn_overlay.dart';
import '../widgets/common/solo_duel_ready_screen_widget.dart';
import '../widgets/common/solo_duel_game_header.dart';
import '../widgets/common/solo_duel_game_board.dart';
import '../widgets/common/solo_duel_avatar_processor.dart';
import '../widgets/common/solo_duel_match_state_manager.dart';
import '../widgets/common/solo_duel_loading_screen.dart';
import '../widgets/common/solo_duel_dialog_manager.dart';
import '../routes/app_routes.dart';
import './game_solo_duel_screen.dart';

class SoloDuelMatchScreen extends StatefulWidget {
  final String matchId;

  const SoloDuelMatchScreen({super.key, required this.matchId});

  @override
  State<SoloDuelMatchScreen> createState() => _SoloDuelMatchScreenState();
}

class _SoloDuelMatchScreenState extends State<SoloDuelMatchScreen>
    with TickerProviderStateMixin {
  final _gameService = SoloDuelGameService.instance;
  final _authService = AuthService.instance;
  final _matchStateManager = SoloDuelMatchStateManager();

  bool _isReady = false;
  Timer? _turnTimer;
  Timer? _readyTimer;
  int _countdown = 60;
  bool _isDisconnectDialogShowing = false;

  @override
  void initState() {
    super.initState();
    _matchStateManager.reset();
    SoundService().preload();
    _setupListeners();
    _startReadyTimer();
  }

  @override
  void dispose() {
    _turnTimer?.cancel();
    _readyTimer?.cancel();
    _gameService.gameStarted.removeListener(_onGameStarted);
    _gameService.cardFlipped.removeListener(_onCardFlipped);
    _gameService.currentMatchNotifier.removeListener(_onMatchUpdated);
    _gameService.gameOver.removeListener(_onGameOver);
    _gameService.error.removeListener(_onError);
    _gameService.playerReady.removeListener(_onPlayerReady);
    _gameService.playerDisconnected.removeListener(_onPlayerDisconnected);
    _gameService.playerReconnected.removeListener(_onPlayerReconnected);
    _gameService.matchState.removeListener(_onMatchStateReceived);
    super.dispose();
  }

  void _setupListeners() {
    _gameService.gameStarted.addListener(_onGameStarted);
    _gameService.cardFlipped.addListener(_onCardFlipped);
    _gameService.currentMatchNotifier.addListener(_onMatchUpdated);
    _gameService.gameOver.addListener(_onGameOver);
    _gameService.error.addListener(_onError);
    _gameService.playerReady.addListener(_onPlayerReady);
    _gameService.playerDisconnected.addListener(_onPlayerDisconnected);
    _gameService.playerReconnected.addListener(_onPlayerReconnected);
    _gameService.matchState.addListener(_onMatchStateReceived);
  }

  void _onGameStarted() {
    if (_gameService.gameStarted.value && mounted) {
      _matchStateManager.reset();
      _readyTimer?.cancel();
      setState(() {});
    }
  }

  void _onCardFlipped() {
    final data = _gameService.cardFlipped.value;
    if (data != null && mounted) {
      final flippedBy = data['flippedBy'];
      final myUserId = _authService.currentUser?.id;
      if (flippedBy != null && flippedBy != myUserId) {
        SoundService().playCardFlipSound();
      }
      setState(() {});
    }
  }

  void _onMatchUpdated() {
    if (mounted) {
      final match = _gameService.currentMatch;
      if (match == null) {
        debugPrint('WARNING: Match became null in _onMatchUpdated');
      }
      _updateMatchedCardSnapshot();
      setState(() {});
    }
  }

  void _onGameOver() {
    final data = _gameService.gameOver.value;
    if (data != null && mounted) {
      debugPrint('Game over event received');
      _matchStateManager.reset();
      if (_isDisconnectDialogShowing) {
        _isDisconnectDialogShowing = false;
        Navigator.pop(context);
      }

      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _showGameOverDialog(data);
        }
      });
    }
  }

  void _onError() {
    final error = _gameService.error.value;
    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
  }

  void _onPlayerReady() {
    final readyUserId = _gameService.playerReady.value;
    if (readyUserId != null && mounted) {
      final myUserId = _authService.currentUser?.id ?? '';
      if (readyUserId == myUserId) {
        setState(() {
          _isReady = true;
        });
      }
    }
  }

  void _onPlayerDisconnected() {
    final data = _gameService.playerDisconnected.value;
    if (data != null && mounted) {
      final myUserId = _authService.currentUser?.id ?? '';
      final disconnectedUserId = data['userId'];

      if (disconnectedUserId != myUserId) {
        _showOpponentDisconnectedDialog(data);
      }
      setState(() {});
    }
  }

  void _onPlayerReconnected() {
    final data = _gameService.playerReconnected.value;
    if (data != null && mounted) {
      if (_isDisconnectDialogShowing) {
        _isDisconnectDialogShowing = false;
        Navigator.pop(context);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${data['username']} đã kết nối lại!'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {});
    }
  }

  void _onMatchStateReceived() {
    final data = _gameService.matchState.value;
    if (data != null && mounted) {
      final match = _gameService.currentMatch;
      if (match != null) {
        _matchStateManager.updateMatchedCardSnapshot(match.cards);
      }
      setState(() {});
    }
  }

  void _updateMatchedCardSnapshot() {
    final match = _gameService.currentMatch;
    if (match != null) {
      _matchStateManager.updateMatchedCardSnapshot(match.cards);
    }
  }

  void _startReadyTimer() {
    _readyTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _countdown--;
        });
      }
      if (_countdown <= 0) {
        _onReadyTimeout();
        timer.cancel();
      }
    });
  }

  void _onReadyTimeout() {
    final match = _gameService.currentMatch;
    if (match == null || !mounted) return;

    final myUserId = _authService.currentUser?.id ?? '';
    final me = match.players.firstWhere((p) => p.userId == myUserId);
    final opponent = match.players.firstWhere((p) => p.userId != myUserId);

    _gameService.resetMatch();
    _matchStateManager.reset();

    if (me.isReady && opponent.isReady) {
      return;
    } else if (me.isReady && !opponent.isReady) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const SoloDuelScreen(autoJoin: true),
        ),
      );
    } else if (!me.isReady && opponent.isReady) {
      AppRoutes.navigateBackToHome(context);
    } else {
      AppRoutes.navigateBackToHome(context);
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
      _showNotYourTurnOverlay();
      return;
    }

    final card = match.cards[index];

    if (card.isMatched || card.isFlipped) {
      return;
    }

    if (match.flippedCards.length >= 2) {
      return;
    }

    SoundService().playCardFlipSound();
    _gameService.flipCard(widget.matchId, index);
  }

  void _showNotYourTurnOverlay() {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => AnimatedNotYourTurnOverlay(
        onDismiss: () {
          overlayEntry.remove();
        },
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 2), () {
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    });
  }

  void _showSurrenderConfirmationDialog() {
    SoloDuelDialogManager.showSurrenderConfirmation(
      context,
      onConfirm: () => _gameService.surrender(widget.matchId),
    );
  }

  void _showOpponentDisconnectedDialog(Map<String, dynamic> data) {
    final opponentUsername = data['username'] ?? 'Đối thủ';
    final waitTime = data['waitTimeSeconds'] ?? 30;

    _isDisconnectDialogShowing = true;

    SoloDuelDialogManager.showOpponentDisconnected(
      context,
      opponentUsername: opponentUsername,
      waitTimeSeconds: waitTime,
      onClose: () => _isDisconnectDialogShowing = false,
    );
  }

  void _showGameOverDialog(Map<String, dynamic> data) {
    final myUserId = _authService.currentUser?.id ?? '';
    final winnerId = data['winner']['userId'];
    final isWinner = winnerId == myUserId;

    final winner = data['winner'];
    final loser = data['loser'];

    SoloDuelDialogManager.showGameOver(
      context,
      isWinner: isWinner,
      winnerUsername: winner['username'],
      winnerScore: winner['score'],
      winnerMatchedCards: winner['matchedCards'],
      loserUsername: loser['username'],
      loserScore: loser['score'],
      loserMatchedCards: loser['matchedCards'],
      onBackToHome: () {
        _gameService.resetMatch();
        AppRoutes.navigateBackToHome(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final match = _gameService.currentMatch;

    if (match == null) {
      debugPrint('Match is null in build, returning to previous screen');
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
      return const SoloDuelLoadingScreen();
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
              if (isGameStarted)
                SoloDuelGameHeader(
                  me: me,
                  opponent: opponent,
                  isMyTurn: isMyTurn,
                  isGameStarted: isGameStarted,
                  myAvatarBytes: _processAvatarData(me.avatar),
                  opponentAvatarBytes: _processAvatarData(opponent.avatar),
                  onPause: () {},
                  onSurrender: _showSurrenderConfirmationDialog,
                ),

              if (isGameStarted) const SizedBox(height: 8),

              Expanded(
                child: !isGameStarted
                    ? SoloDuelReadyScreenWidget(
                        players: match.players,
                        currentUserId: myUserId,
                        countdown: _countdown,
                        isReady: _isReady,
                        onSetReady: _setReady,
                      )
                    : _buildGameBoard(match),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Uint8List? _processAvatarData(String? avatarData) {
    return SoloDuelAvatarProcessor.processAvatarData(avatarData);
  }

  Widget _buildGameBoard(SoloDuelMatchEntity match) {
    final myUserId = _authService.currentUser?.id ?? '';
    return SoloDuelGameBoard(
      match: match,
      myUserId: myUserId,
      onCardTap: _onCardTap,
    );
  }
}
