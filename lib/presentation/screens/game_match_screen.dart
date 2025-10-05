import 'package:flutter/material.dart';
import './difficulty_selection_screen.dart';
import './login_screen.dart';
import '../widgets/common/game_mode_card_widget.dart';
import '../../services/auth_service.dart';
import 'package:pixelarticons/pixel.dart';
import 'package:nes_ui/nes_ui.dart';

class GameMatchScreen extends StatefulWidget {
  const GameMatchScreen({super.key});

  @override
  State<GameMatchScreen> createState() => _GameMatchScreenState();
}

class _GameMatchScreenState extends State<GameMatchScreen> {
  bool get _isLoggedIn => AuthService.instance.isRealUser;

  Future<void> _handleLockedCardTap(String featureName) async {
    if (_isLoggedIn) {
      return; // User is already logged in, shouldn't reach here
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => _buildLoginPromptDialog(featureName),
    );

    if (result == true) {
      final loginResult = await Navigator.push<bool>(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );

      if (loginResult == true) {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Login successful! Premium features unlocked!'),
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
              'PREMIUM FEATURE',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'You need to log in to access this feature.',
              style: const TextStyle(fontSize: 10),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: NesButton(
                    type: NesButtonType.primary,
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text('Login', textAlign: TextAlign.center),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NesButton(
                    type: NesButtonType.normal,
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel', textAlign: TextAlign.center),
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
                  title: 'Time Challenge',
                  subtitle: 'Race against the clock!',
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
                  title: 'Solo Duel',
                  subtitle: 'Challenge another player',
                  color: const Color(0xFFFF9800),
                  isEnabled: _isLoggedIn,
                  onTap: _isLoggedIn
                      ? () {
                          // TODO: Navigate to Solo Duel screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Solo Duel coming soon!'),
                            ),
                          );
                        }
                      : () => _handleLockedCardTap('Solo Duel'),
                ),
                const SizedBox(height: 20),
                GameModeCard(
                  icon: Pixel.users,
                  title: 'Battle Royale',
                  subtitle: 'Compete with multiple players',
                  color: const Color(0xFFE91E63),
                  isEnabled: _isLoggedIn,
                  onTap: _isLoggedIn
                      ? () {
                          // TODO: Navigate to Battle Royale screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Battle Royale coming soon!'),
                            ),
                          );
                        }
                      : () => _handleLockedCardTap('Battle Royale'),
                ),
                const SizedBox(height: 20),
                GameModeCard(
                  icon: Icons.tune,
                  title: 'Custom Game',
                  subtitle: 'Customize your match!',
                  color: const Color(0xFF9C27B0),
                  isEnabled: _isLoggedIn,
                  onTap: _isLoggedIn
                      ? () {
                          // TODO: Navigate to Custom Game screen
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Custom Game coming soon!'),
                            ),
                          );
                        }
                      : () => _handleLockedCardTap('Custom Game'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
