import 'package:shared_preferences/shared_preferences.dart';

abstract class TokenStorage {
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<String?> getAccessTokenExpiresAt();
  Future<String?> getRefreshTokenExpiresAt();

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String accessTokenExpiresAt,
    required String refreshTokenExpiresAt,
  });

  Future<void> clearTokens();
  Future<bool> isAccessTokenExpired();
}

class TokenStorageImpl implements TokenStorage {
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _accessTokenExpiresKey = 'access_token_expires_at';
  static const String _refreshTokenExpiresKey = 'refresh_token_expires_at';

  @override
  Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  @override
  Future<String?> getRefreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenKey);
  }

  @override
  Future<String?> getAccessTokenExpiresAt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenExpiresKey);
  }

  @override
  Future<String?> getRefreshTokenExpiresAt() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_refreshTokenExpiresKey);
  }

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String accessTokenExpiresAt,
    required String refreshTokenExpiresAt,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await Future.wait([
      prefs.setString(_accessTokenKey, accessToken),
      prefs.setString(_refreshTokenKey, refreshToken),
      prefs.setString(_accessTokenExpiresKey, accessTokenExpiresAt),
      prefs.setString(_refreshTokenExpiresKey, refreshTokenExpiresAt),
    ]);
  }

  @override
  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();

    await Future.wait([
      prefs.remove(_accessTokenKey),
      prefs.remove(_refreshTokenKey),
      prefs.remove(_accessTokenExpiresKey),
      prefs.remove(_refreshTokenExpiresKey),
    ]);
  }

  @override
  Future<bool> isAccessTokenExpired() async {
    final expiresAtStr = await getAccessTokenExpiresAt();

    if (expiresAtStr == null) return true;

    final expiresAt = DateTime.parse(expiresAtStr);
    return DateTime.now().isAfter(expiresAt);
  }
}
