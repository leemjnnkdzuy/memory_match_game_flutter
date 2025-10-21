import 'dart:convert';
import 'dart:typed_data';

class SoloDuelAvatarProcessor {
  static final Map<String, Uint8List?> _avatarCache = {};

  static Uint8List? processAvatarData(String? avatarData) {
    if (avatarData == null || avatarData.isEmpty) {
      return null;
    }

    if (_avatarCache.containsKey(avatarData)) {
      return _avatarCache[avatarData];
    }

    try {
      String base64String = avatarData.trim();

      if (base64String.startsWith('data:')) {
        final commaIndex = base64String.indexOf(',');
        if (commaIndex != -1) {
          base64String = base64String.substring(commaIndex + 1);
        }
      }

      base64String = base64String.trim().replaceAll(RegExp(r'\s+'), '');

      if (base64String.length % 4 != 0) {
        final padding = (4 - (base64String.length % 4)) % 4;
        base64String += '=' * padding;
      }

      final bytes = base64Decode(base64String);
      _avatarCache[avatarData] = bytes;
      return bytes;
    } catch (e) {
      _avatarCache[avatarData] = null;
      return null;
    }
  }

  static void clearCache() {
    _avatarCache.clear();
  }
}
