import 'package:flutter/material.dart';
import 'package:memory_match_game/core/theme/app_theme.dart';
import 'package:pixelarticons/pixel.dart';
import '../custom/custom_button.dart';

class GuestAccountWidget extends StatelessWidget {
  const GuestAccountWidget({super.key});

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
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primaryColor, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Pixel.user,
                    size: 96,
                    color: AppTheme.primaryColor,
                  ),
                ),
                SizedBox(height: 36),
                CustomButton(
                  type: CustomButtonType.primary,
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: Text('Đăng nhập', textAlign: TextAlign.center),
                ),
                SizedBox(height: 16),
                CustomButton(
                  type: CustomButtonType.normal,
                  onPressed: () =>
                      Navigator.pushNamed(context, '/register-verify'),
                  child: Text('Đăng ký', textAlign: TextAlign.center),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
