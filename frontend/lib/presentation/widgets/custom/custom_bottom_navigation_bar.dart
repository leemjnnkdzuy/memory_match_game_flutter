import 'package:flutter/material.dart';
import 'package:pixelarticons/pixel.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: onTap,
        selectedItemColor: const Color(0xFF1976D2),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 0,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Pixel.home, size: 36),
            label: 'Trò chơi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Pixel.wallet, size: 36),
            label: 'Lịch sử',
          ),

          BottomNavigationBarItem(
            icon: Icon(Pixel.coin, size: 36),
            label: 'Phần thưởng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Pixel.user, size: 36),
            label: 'Hồ sơ',
          ),
        ],
      ),
    );
  }
}
