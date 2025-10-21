import 'package:flutter/material.dart';
import '../../services/solo_duel_game_service.dart';
import '../../services/auth_service.dart';
import '../../domain/entities/solo_duel_match_entity.dart';
import '../widgets/custom/custom_button.dart';
import '../widgets/common/solo_duel_dialog_widgets.dart';
import '../widgets/common/player_info_card_widget.dart';
import '../widgets/common/game_rules_card_widget.dart';
import './game_solo_duel_match_screen.dart';

class SoloDuelScreen extends StatefulWidget {
  final bool autoJoin;

  const SoloDuelScreen({super.key, this.autoJoin = false});

  @override
  State<SoloDuelScreen> createState() => _SoloDuelScreenState();
}

class _SoloDuelScreenState extends State<SoloDuelScreen> {
  final _gameService = SoloDuelGameService.instance;
  final _authService = AuthService.instance;
  bool _isSearching = false;
  bool _isRejoining = false;

  @override
  void initState() {
    super.initState();
    _setupListeners();
    _initializeAndCheckMatch();
    if (widget.autoJoin) {
      Future.microtask(() => _startMatchmaking());
    }
  }

  Future<void> _initializeAndCheckMatch() async {
    await _gameService.waitForInitialization();
    _checkForActiveMatch();
  }

  Future<void> _checkForActiveMatch() async {
    final currentMatch = _gameService.currentMatch;
    if (currentMatch != null &&
        (currentMatch.status == MatchStatus.playing ||
            currentMatch.status == MatchStatus.ready)) {
      if (mounted) {
        _showRejoinDialog(currentMatch.matchId);
      }
    }
  }

  void _showRejoinDialog(String matchId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: SoloDuelRejoinDialog(
          onSurrender: () {
            Navigator.pop(context);
            _gameService.surrender(matchId);
            _gameService.resetMatch();
          },
          onRejoin: () {
            Navigator.pop(context);
            _handleRejoin(matchId);
          },
        ),
      ),
    );
  }

  void _handleRejoin(String matchId) {
    if (_isRejoining) return;
    _isRejoining = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: const SoloDuelLoadingDialog(message: 'Đang kết nối lại...'),
      ),
    );

    void matchStateListener() {
      final matchState = _gameService.matchState.value;
      if (matchState != null &&
          matchState['matchId'] == matchId &&
          _isRejoining) {
        _gameService.matchState.removeListener(matchStateListener);
        _isRejoining = false;

        if (mounted) {
          Navigator.pop(context);

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SoloDuelMatchScreen(matchId: matchId),
            ),
          );
        }
      }
    }

    _gameService.matchState.addListener(matchStateListener);

    _gameService.rejoinMatch(matchId).catchError((error) {
      if (_isRejoining && mounted) {
        _gameService.matchState.removeListener(matchStateListener);
        _isRejoining = false;

        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi kết nối: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    Future.delayed(const Duration(seconds: 10), () {
      if (_isRejoining && mounted) {
        _gameService.matchState.removeListener(matchStateListener);
        _isRejoining = false;

        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể kết nối lại. Vui lòng thử lại.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
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
          builder: (context) =>
              SoloDuelMatchScreen(matchId: matchData['matchId']),
        ),
      );
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
            content: Text('Lỗi kết nối: $e'),
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
                PlayerInfoCardWidget(
                  username: user?.username,
                  avatar: user?.avatar,
                ),

                const SizedBox(height: 20),

                GameRulesCardWidget(
                  rules: const [
                    '12 cặp thẻ Pokemon ngẫu nhiên',
                    'Lượt chơi xen kẽ giữa 2 người',
                    'Match được = 100 điểm',
                    'Người có điểm cao hơn thắng',
                  ],
                ),

                const SizedBox(height: 40),

                if (!_isSearching)
                  Column(
                    children: [
                      SizedBox(
                        width: 250,
                        child: CustomButton(
                          type: CustomButtonType.primary,
                          onPressed: _startMatchmaking,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.flash_on, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Tìm đối thủ',
                                style: TextStyle(fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 250,
                        child: CustomButton(
                          type: CustomButtonType.warning,
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text(
                            'Quay về trang chủ',
                            style: TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
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
                          child: const Text('Hủy', textAlign: TextAlign.center),
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
}
