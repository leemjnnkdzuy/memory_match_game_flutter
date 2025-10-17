class BattleRoyalePlayer {
  final String id;
  final String username;
  final String? avatarUrl;
  final String borderColor;
  final bool isReady;
  final bool isHost;
  final int? ping;
  final int pairsFound;
  final int flipCount;
  final int completionTime;
  final double score;
  final bool isFinished;
  final bool isConnected;

  BattleRoyalePlayer({
    required this.id,
    required this.username,
    this.avatarUrl,
    this.borderColor = '#4CAF50',
    this.isReady = false,
    this.isHost = false,
    this.ping,
    this.pairsFound = 0,
    this.flipCount = 0,
    this.completionTime = 0,
    this.score = 0,
    this.isFinished = false,
    this.isConnected = true,
  });

  factory BattleRoyalePlayer.fromJson(Map<String, dynamic> json) {
    final dynamic rawUserId = json['userId'] ?? json['user_id'];
    final String resolvedId;
    if (rawUserId != null) {
      if (rawUserId is Map && rawUserId.containsKey(r'$oid')) {
        resolvedId = rawUserId[r'$oid']?.toString() ?? '';
      } else {
        resolvedId = rawUserId.toString();
      }
    } else {
      final dynamic fallbackId = json['id'] ?? json['_id'];
      resolvedId = fallbackId?.toString() ?? '';
    }

    return BattleRoyalePlayer(
      id: resolvedId,
      username: json['username'] ?? 'Player',
      avatarUrl: json['avatarUrl'],
      borderColor: json['borderColor'] ?? '#4CAF50',
      isReady: json['isReady'] ?? false,
      isHost: json['isHost'] ?? false,
      ping: json['ping'],
      pairsFound: json['pairsFound'] ?? 0,
      flipCount: json['flipCount'] ?? 0,
      completionTime: json['completionTime'] ?? 0,
      score: (json['score'] ?? 0).toDouble(),
      isFinished: json['isFinished'] ?? false,
      isConnected: json['isConnected'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'avatarUrl': avatarUrl,
      'borderColor': borderColor,
      'isReady': isReady,
      'isHost': isHost,
      'ping': ping,
      'pairsFound': pairsFound,
      'flipCount': flipCount,
      'completionTime': completionTime,
      'score': score,
      'isFinished': isFinished,
      'isConnected': isConnected,
    };
  }

  BattleRoyalePlayer copyWith({
    String? id,
    String? username,
    String? avatarUrl,
    String? borderColor,
    bool? isReady,
    bool? isHost,
    int? ping,
    int? pairsFound,
    int? flipCount,
    int? completionTime,
    double? score,
    bool? isFinished,
    bool? isConnected,
  }) {
    return BattleRoyalePlayer(
      id: id ?? this.id,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      borderColor: borderColor ?? this.borderColor,
      isReady: isReady ?? this.isReady,
      isHost: isHost ?? this.isHost,
      ping: ping ?? this.ping,
      pairsFound: pairsFound ?? this.pairsFound,
      flipCount: flipCount ?? this.flipCount,
      completionTime: completionTime ?? this.completionTime,
      score: score ?? this.score,
      isFinished: isFinished ?? this.isFinished,
      isConnected: isConnected ?? this.isConnected,
    );
  }
}
