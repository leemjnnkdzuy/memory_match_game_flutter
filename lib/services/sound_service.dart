import 'package:audioplayers/audioplayers.dart';

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
      await _audioPlayer.play(AssetSource('sounds/card_click_sound.WAV'));
    } catch (e) {
      print('Error playing card flip sound: $e');
    }
  }

  Future<void> stopAll() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      print('Error stopping sounds: $e');
    }
  }

  Future<void> dispose() async {
    try {
      await _audioPlayer.dispose();
    } catch (e) {
      print('Error disposing audio player: $e');
    }
  }
}
