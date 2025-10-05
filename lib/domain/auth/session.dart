import 'package:equatable/equatable.dart';

class Session extends Equatable {
  final String id;
  final String deviceInfo;
  final String ipAddress;
  final DateTime createdAt;
  final DateTime expiresAt;
  final bool isExpired;

  const Session({
    required this.id,
    required this.deviceInfo,
    required this.ipAddress,
    required this.createdAt,
    required this.expiresAt,
    required this.isExpired,
  });

  bool get isActive => !isExpired && DateTime.now().isBefore(expiresAt);

  Duration get timeUntilExpiry {
    if (isExpired) return Duration.zero;
    final now = DateTime.now();
    return expiresAt.isAfter(now) ? expiresAt.difference(now) : Duration.zero;
  }

  String get deviceType {
    final deviceLower = deviceInfo.toLowerCase();
    if (deviceLower.contains('android')) return 'Android';
    if (deviceLower.contains('ios')) return 'iOS';
    if (deviceLower.contains('windows')) return 'Windows';
    if (deviceLower.contains('macos') || deviceLower.contains('mac os')) {
      return 'macOS';
    }
    if (deviceLower.contains('linux')) return 'Linux';
    return 'Unknown';
  }

  Session copyWith({
    String? id,
    String? deviceInfo,
    String? ipAddress,
    DateTime? createdAt,
    DateTime? expiresAt,
    bool? isExpired,
  }) {
    return Session(
      id: id ?? this.id,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      ipAddress: ipAddress ?? this.ipAddress,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      isExpired: isExpired ?? this.isExpired,
    );
  }

  @override
  List<Object?> get props => [
    id,
    deviceInfo,
    ipAddress,
    createdAt,
    expiresAt,
    isExpired,
  ];
}
