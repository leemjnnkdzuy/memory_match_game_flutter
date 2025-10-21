import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../core/theme/app_theme.dart';
import 'account_screen.dart';
import 'game_match_screen.dart';
import 'history_screen.dart';
import 'store_screen.dart';
import '../widgets/common/avatar_widget.dart';
import '../../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _videoController;
  late AnimationController _rotationController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _rotationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.asset(
      'assets/videos/background_video.mp4',
    );
    await _videoController.initialize();
    _videoController
      ..setLooping(true)
      ..setVolume(0)
      ..play();
    if (!mounted) {
      return;
    }
    setState(() {
      _isVideoInitialized = true;
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  void _navigateToScreen(Widget screen, {bool requiresLogin = false}) async {
    if (requiresLogin && !AuthService.instance.isRealUser) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const GameMatchScreen()),
      );
      return;
    }
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
    if (result == true) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          if (_isVideoInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _videoController.value.size.width,
                  height: _videoController.value.size.height,
                  child: VideoPlayer(_videoController),
                ),
              ),
            ),
          Container(color: Colors.black.withOpacity(0.4)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const Spacer(),
                  _buildPlayNowButton(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final user = AuthService.instance.currentUser;
    final rawName =
        '${(user?.firstName ?? '').trim()} ${(user?.lastName ?? '').trim()}'
            .trim();
    final displayName = rawName.isNotEmpty ? rawName : 'Trainer';
    final rawUsername = (user?.username ?? '').trim();
    final username = rawUsername.isNotEmpty ? rawUsername : 'guest';

    void openAccount() {
      _navigateToScreen(const AccountScreen(), requiresLogin: true);
    }

    const double avatarSize = 110.0;
    const double nameHeight = 44;
    const double usernameHeight = 32;
    const double borderWidth = 3;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Stack(
              alignment: Alignment.centerLeft,
              clipBehavior: Clip.none,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: openAccount,
                      child: IntrinsicWidth(
                        child: Container(
                          height: nameHeight,
                          padding: EdgeInsets.only(
                            left: avatarSize / 2,
                            right: 20,
                          ),
                          margin: const EdgeInsets.only(left: avatarSize / 2),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(nameHeight / 2),
                            ),
                            border: Border.all(
                              color: Colors.black,
                              width: borderWidth,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset(6, 6),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Text(
                            displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'AlanSans',
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.8,
                              shadows: [
                                Shadow(
                                  blurRadius: 12,
                                  color: Colors.black54,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: openAccount,
                      child: IntrinsicWidth(
                        child: Container(
                          height: usernameHeight,
                          padding: EdgeInsets.only(
                            left: avatarSize / 2,
                            right: 16,
                          ),
                          margin: const EdgeInsets.only(left: avatarSize / 2),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor.withOpacity(0.85),
                            borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(usernameHeight / 2),
                            ),
                            border: Border.all(color: Colors.black, width: 2.5),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black,
                                offset: Offset(4, 4),
                                blurRadius: 0,
                              ),
                            ],
                          ),
                          child: Text(
                            '@${username.toLowerCase()}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'AlanSans',
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Positioned(
                  left: 0,
                  child: InkWell(
                    onTap: openAccount,
                    borderRadius: BorderRadius.circular(avatarSize / 2),
                    child: AvatarWidget(
                      size: avatarSize,
                      borderWidth: 3,
                      avatarData: user?.avatar,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIconButton(
              icon: Icons.history,
              onTap: () =>
                  _navigateToScreen(const HistoryScreen(), requiresLogin: true),
            ),
            const SizedBox(height: 12),
            _buildIconButton(
              icon: Icons.storefront,
              onTap: () =>
                  _navigateToScreen(const StoreScreen(), requiresLogin: true),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: [
            BoxShadow(color: Colors.black, offset: Offset(6, 6), blurRadius: 0),
          ],
        ),
        child: Icon(icon, color: const Color.fromARGB(255, 255, 255, 255)),
      ),
    );
  }

  Widget _buildPlayNowButton() {
    const double pokeballSize = 140;
    final double labelHeight = pokeballSize * 0.4;

    return InkWell(
      onTap: () => _navigateToScreen(const GameMatchScreen()),
      borderRadius: BorderRadius.circular(48),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Stack(
          alignment: Alignment.centerRight,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: Container(
                    height: labelHeight,
                    padding: const EdgeInsets.only(left: 28),
                    margin: EdgeInsets.only(right: pokeballSize * 0.6),
                    alignment: Alignment.centerLeft,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      border: Border.all(color: Colors.black, width: 3),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(6, 6),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: const Text(
                      'Đấu Ngay',
                      style: TextStyle(
                        fontFamily: 'AlanSans',
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            _buildPokeballIcon(size: pokeballSize),
          ],
        ),
      ),
    );
  }

  Widget _buildPokeballIcon({double size = 96}) {
    final borderWidth = size * 0.042;
    final beltHeight = size * 0.1;
    final innerRingSize = size * 0.38;
    final coreSize = size * 0.16;

    return RotationTransition(
      turns: _rotationController,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          border: Border.all(color: Colors.black, width: borderWidth),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            ClipOval(
              child: Column(
                children: [
                  Expanded(child: Container(color: const Color(0xFFFF4B4B))),
                  Container(height: beltHeight, color: Colors.black),
                  Expanded(child: Container(color: Colors.white)),
                ],
              ),
            ),
            Container(
              width: innerRingSize,
              height: innerRingSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: Colors.black, width: borderWidth),
              ),
            ),
            Container(
              width: coreSize,
              height: coreSize,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
