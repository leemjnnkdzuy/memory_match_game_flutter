import 'package:flutter/material.dart';
import './difficulty_selection_screen.dart';
import './login_screen.dart';
import 'game_solo_duel_screen.dart';
import 'battle_royale_mode_screen.dart';
import '../widgets/common/game_mode_card_widget.dart';
import '../../services/auth_service.dart';
import 'package:pixelarticons/pixel.dart';
import '../widgets/custom/custom_button.dart';

class GameMatchScreen extends StatefulWidget {
  const GameMatchScreen({super.key});

  @override
  State<GameMatchScreen> createState() => _GameMatchScreenState();
}

class _GameMatchScreenState extends State<GameMatchScreen> {
  bool get _isLoggedIn => AuthService.instance.isRealUser;

  Future<void> _handleLockedCardTap(String featureName) async {
    if (_isLoggedIn) {
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _buildLoginPromptDialog(featureName),
    );

    if (result == true) {
      if (!mounted) return;
      final loginResult = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );

      if (loginResult == true) {
        if (!mounted) return;
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Đăng nhập thành công! Tính năng premium đã được mở khóa!',
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildLoginPromptDialog(String featureName) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.all(20),
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Pixel.lock, size: 48, color: Colors.red.shade700),
            const SizedBox(height: 16),
            Text(
              'TÍNH NĂNG PREMIUM',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Bạn cần đăng nhập để truy cập tính năng này.',
              style: const TextStyle(fontSize: 10),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    type: CustomButtonType.primary,
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Đăng nhập', textAlign: TextAlign.center),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: CustomButton(
                    type: CustomButtonType.normal,
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Hủy', textAlign: TextAlign.center),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF64B5F6), Color(0xFF1976D2)],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GameModeCard(
                  icon: Pixel.clock,
                  title: 'Thách thức thời gian',
                  subtitle: 'Đua với thời gian!',
                  color: const Color(0xFF4CAF50),
                  isEnabled: true,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DifficultySelectionScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GameModeCard(
                  icon: Pixel.zap,
                  title: 'Đấu đơn',
                  subtitle: 'Thách đấu với người chơi khác',
                  color: const Color(0xFFFF9800),
                  isEnabled: _isLoggedIn,
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
                ),
                const SizedBox(height: 20),
                GameModeCard(
                  icon: Pixel.users,
                  title: 'Sinh Tử Chiến',
                  subtitle: 'Cạnh tranh với nhiều người chơi',
                  color: const Color(0xFFE91E63),
                  isEnabled: _isLoggedIn,
                  onTap: _isLoggedIn
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const BattleRoyaleModeScreen(),
                            ),
                          );
                        }
                      : () => _handleLockedCardTap('Sinh Tử Chiến'),
                ),                
              ],
            ),
          ),
        ),
      ),
    );
  }
}
