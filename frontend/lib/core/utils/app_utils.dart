import 'dart:math';
import 'dart:convert';
import 'dart:io';

class AppUtils {
  AppUtils._();

  static String generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(9999);
    return '$timestamp$random';
  }

  static List<T> shuffleList<T>(List<T> list) {
    final shuffled = List<T>.from(list);
    shuffled.shuffle();
    return shuffled;
  }

  static int calculateScore({
    required int matches,
    required int moves,
    required Duration timeElapsed,
    required int maxScore,
  }) {
    final baseScore = matches * 10;
    final movePenalty = moves * 1;
    final timeBonusSeconds = maxScore ~/ timeElapsed.inSeconds.clamp(1, 600);

    return (baseScore - movePenalty + timeBonusSeconds).clamp(0, maxScore);
  }

  static String formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  static String formatScore(int score) {
    return score.toString().padLeft(6, '0');
  }

  static bool isValidCardCount(int count) {
    return count > 0 && count % 2 == 0;
  }

  static Future<String> imgToBase64(String imgPath) async {
    final bytes = await File(imgPath).readAsBytes();
    return base64Encode(bytes);
  }

  static Future<void> base64ToImg(String base64Str, String outputPath) async {
    final bytes = base64Decode(base64Str);

    bool isValidImage = false;
    if (bytes.length >= 3) {
      if (bytes[0] == 0xFF && bytes[1] == 0xD8 && bytes[2] == 0xFF) {
        isValidImage = true;
      }
      else if (bytes.length >= 8 &&
          bytes[0] == 0x89 &&
          bytes[1] == 0x50 &&
          bytes[2] == 0x4E &&
          bytes[3] == 0x47) {
        isValidImage = true;
      }
    }

    if (!isValidImage) {
      throw FormatException('Invalid image data - not JPEG or PNG');
    }

    final file = File(outputPath);
    await file.writeAsBytes(bytes);
  }
}
