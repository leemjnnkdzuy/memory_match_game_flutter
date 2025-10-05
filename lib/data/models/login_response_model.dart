import 'user_model.dart';

/// Login response data model
class LoginResponseModel {
  final String accessToken;
  final String refreshToken;
  final String accessTokenExpiresAt;
  final String refreshTokenExpiresAt;
  final UserModel user;

  LoginResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiresAt,
    required this.refreshTokenExpiresAt,
    required this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      accessTokenExpiresAt: json['accessTokenExpiresAt'] ?? '',
      refreshTokenExpiresAt: json['refreshTokenExpiresAt'] ?? '',
      user: UserModel.fromJson(json['user'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'accessTokenExpiresAt': accessTokenExpiresAt,
      'refreshTokenExpiresAt': refreshTokenExpiresAt,
      'user': user.toJson(),
    };
  }
}
