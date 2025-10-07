import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';
import '../../services/solo_duel_game_service.dart';
import '../../services/auth_service.dart';
import '../widgets/custom/custom_button.dart';
import './game_solo_duel_match_screen.dart';

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
      appBar: AppBar(title: const Text('Đấu đơn'), centerTitle: true),
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
                      Icon(Pixel.user, size: 64, color: Colors.orange.shade700),
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
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange.shade700,
                          ),
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

  Widget _buildRuleItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(fontSize: 16)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
