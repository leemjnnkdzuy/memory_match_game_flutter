import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isSoundEnabled = true;

  bool get isSoundEnabled => _isSoundEnabled;

  void setSoundEnabled(bool enabled) {
    _isSoundEnabled = enabled;
  }

  Future<void> playCardFlipSound() async {
    if (!_isSoundEnabled) return;

    try {
      await _audioPlayer.setAsset('assets/sounds/card_click_sound.WAV');
      await _audioPlayer.play();
      await _audioPlayer.seek(Duration.zero);
    } catch (e) {
      debugPrint('Error playing card flip sound: $e');
    }
  }

  Future<void> stopAll() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      debugPrint('Error stopping sounds: $e');
    }
  }

  Future<void> dispose() async {
    try {
      await _audioPlayer.dispose();
    } catch (e) {
      debugPrint('Error disposing audio player: $e');
    }
  }
}
