import '../../domain/auth/session.dart';

class SessionModel {
  final String id;
  final String deviceInfo;
  final String ipAddress;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isExpired;

  SessionModel({
    required this.id,
    required this.deviceInfo,
    required this.ipAddress,
    required this.createdAt,
    required this.expiresAt,
    required this.isExpired,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] ?? '',
      deviceInfo: json['deviceInfo'] ?? '',
      ipAddress: json['ipAddress'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      expiresAt: DateTime.parse(json['expiresAt']),
      isExpired: json['isExpired'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'deviceInfo': deviceInfo,
      'ipAddress': ipAddress,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt.toIso8601String(),
      'isExpired': isExpired,
    };
  }

  /// Convert to domain entity
  Session toEntity() {
    return Session(
      id: id,
      deviceInfo: deviceInfo,
      ipAddress: ipAddress,
      createdAt: createdAt,
      expiresAt: expiresAt,
      isExpired: isExpired,
    );
  }
}
