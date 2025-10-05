class UserEntity {
  final String id;
  final String username;
  final String email;
  final DateTime? lastLogin;
  final bool isGuest;
  final int gamesPlayed;
  final int bestScore;

  const UserEntity({
    required this.id,
    required this.username,
    required this.email,
    this.lastLogin,
    this.isGuest = false,
    this.gamesPlayed = 0,
    this.bestScore = 0,
  });

  UserEntity copyWith({
    String? id,
    String? username,
    String? email,
    DateTime? lastLogin,
    bool? isGuest,
    int? gamesPlayed,
    int? bestScore,
  }) {
    return UserEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      lastLogin: lastLogin ?? this.lastLogin,
      isGuest: isGuest ?? this.isGuest,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      bestScore: bestScore ?? this.bestScore,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserEntity &&
        other.id == id &&
        other.username == username &&
        other.email == email &&
        other.lastLogin == lastLogin &&
        other.isGuest == isGuest &&
        other.gamesPlayed == gamesPlayed &&
        other.bestScore == bestScore;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        username.hashCode ^
        email.hashCode ^
        lastLogin.hashCode ^
        isGuest.hashCode ^
        gamesPlayed.hashCode ^
        bestScore.hashCode;
  }

  @override
  String toString() {
    return 'UserEntity(id: $id, username: $username, email: $email, lastLogin: $lastLogin, isGuest: $isGuest, gamesPlayed: $gamesPlayed, bestScore: $bestScore)';
  }
}
