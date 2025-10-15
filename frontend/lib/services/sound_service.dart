import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _cardFlipPlayer = AudioPlayer();
  final AudioPlayer _matchPlayer = AudioPlayer();
  Future<void>? _preloadFuture;
  bool _isSoundEnabled = true;

  bool get isSoundEnabled => _isSoundEnabled;

  void setSoundEnabled(bool enabled) {
    _isSoundEnabled = enabled;
  }

  Future<void> preload() {
    _preloadFuture ??= _loadSounds();
    return _preloadFuture!;
  }

  Future<void> _loadSounds() async {
    try {
      await Future.wait([
        _cardFlipPlayer.setAsset('assets/sounds/card_click_sound.WAV'),
        _matchPlayer.setAsset('assets/sounds/match_two_card_sound.WAV'),
      ]);
    } catch (e) {
      debugPrint('Error preloading sounds: $e');
    }
  }

  Future<void> playCardFlipSound() async {
    if (!_isSoundEnabled) return;

    await preload();
    try {
      if (_cardFlipPlayer.playing) {
        await _cardFlipPlayer.stop();
      }
      await _cardFlipPlayer.seek(Duration.zero);
      await _cardFlipPlayer.play();
    } catch (e) {
      debugPrint('Error playing card flip sound: $e');
    }
  }

  Future<void> playMatchSound() async {
    if (!_isSoundEnabled) return;

    await preload();
    try {
      if (_matchPlayer.playing) {
        await _matchPlayer.stop();
      }
      await _matchPlayer.seek(Duration.zero);
      await _matchPlayer.play();
    } catch (e) {
      debugPrint('Error playing match sound: $e');
    }
  }

  Future<void> stopAll() async {
    try {
      await Future.wait([
        _cardFlipPlayer.stop(),
        _matchPlayer.stop(),
      ]);
    } catch (e) {
      debugPrint('Error stopping sounds: $e');
    }
  }

  Future<void> dispose() async {
    try {
      await Future.wait([
        _cardFlipPlayer.dispose(),
        _matchPlayer.dispose(),
      ]);
    } catch (e) {
      debugPrint('Error disposing audio players: $e');
    }
  }
}
