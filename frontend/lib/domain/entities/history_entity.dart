import '../../data/models/user_model.dart';

class HistoryEntity {
  final String id;
  final String type;

  final String? userId;
  final int? score;
  final int? moves;
  final int? timeElapsed;
  final String? difficulty;
  final bool? isWin;
  final DateTime? datePlayed;
  final User? user;

  final List<PlayerEntity>? players;
  final dynamic winner;

  final String? matchId;
  final int? rank;
  final int? pairsFound;
  final int? flipCount;
  final int? completionTime;
  final bool? isFinished;
  final int? totalPlayers;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const HistoryEntity({
    required this.id,
    required this.type,
    this.userId,
    this.score,
    this.moves,
    this.timeElapsed,
    this.difficulty,
    this.isWin,
    this.datePlayed,
    this.user,
    this.players,
    this.winner,
    this.matchId,
    this.rank,
    this.pairsFound,
    this.flipCount,
    this.completionTime,
    this.isFinished,
    this.totalPlayers,
    this.createdAt,
    this.updatedAt,
  });

  HistoryEntity copyWith({
    String? id,
    String? type,
    String? userId,
    int? score,
    int? moves,
    int? timeElapsed,
    String? difficulty,
    bool? isWin,
    DateTime? datePlayed,
    User? user,
    List<PlayerEntity>? players,
    dynamic winner,
    String? matchId,
    int? rank,
    int? pairsFound,
    int? flipCount,
    int? completionTime,
    bool? isFinished,
    int? totalPlayers,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return HistoryEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      userId: userId ?? this.userId,
      score: score ?? this.score,
      moves: moves ?? this.moves,
      timeElapsed: timeElapsed ?? this.timeElapsed,
      difficulty: difficulty ?? this.difficulty,
      isWin: isWin ?? this.isWin,
      datePlayed: datePlayed ?? this.datePlayed,
      user: user ?? this.user,
      players: players ?? this.players,
      winner: winner ?? this.winner,
      matchId: matchId ?? this.matchId,
      rank: rank ?? this.rank,
      pairsFound: pairsFound ?? this.pairsFound,
      flipCount: flipCount ?? this.flipCount,
      completionTime: completionTime ?? this.completionTime,
      isFinished: isFinished ?? this.isFinished,
      totalPlayers: totalPlayers ?? this.totalPlayers,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class PlayerEntity {
  final String playerId;
  final User? player;
  final int score;
  final int moves;
  final int timeTaken;

  final String? username;
  final String? avatarUrl;
  final String? borderColor;
  final int? rank;
  final int? pairsFound;
  final int? flipCount;
  final int? completionTime;
  final bool? isFinished;

  const PlayerEntity({
    required this.playerId,
    this.player,
    required this.score,
    required this.moves,
    required this.timeTaken,
    this.username,
    this.avatarUrl,
    this.borderColor,
    this.rank,
    this.pairsFound,
    this.flipCount,
    this.completionTime,
    this.isFinished,
  });

  PlayerEntity copyWith({
    String? playerId,
    User? player,
    int? score,
    int? moves,
    int? timeTaken,
    String? username,
    String? avatarUrl,
    String? borderColor,
    int? rank,
    int? pairsFound,
    int? flipCount,
    int? completionTime,
    bool? isFinished,
  }) {
    return PlayerEntity(
      playerId: playerId ?? this.playerId,
      player: player ?? this.player,
      score: score ?? this.score,
      moves: moves ?? this.moves,
      timeTaken: timeTaken ?? this.timeTaken,
      username: username ?? this.username,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      borderColor: borderColor ?? this.borderColor,
      rank: rank ?? this.rank,
      pairsFound: pairsFound ?? this.pairsFound,
      flipCount: flipCount ?? this.flipCount,
      completionTime: completionTime ?? this.completionTime,
      isFinished: isFinished ?? this.isFinished,
    );
  }
}

class HistoriesResponse {
  final List<HistoryEntity> histories;
  final PaginationWithTypeEntity pagination;

  const HistoriesResponse({required this.histories, required this.pagination});
}

class PaginationWithTypeEntity {
  final int total;
  final int totalOffline;
  final int totalOnline;
  final int totalBattleRoyale;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;

  const PaginationWithTypeEntity({
    required this.total,
    required this.totalOffline,
    required this.totalOnline,
    this.totalBattleRoyale = 0,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
  });
}
