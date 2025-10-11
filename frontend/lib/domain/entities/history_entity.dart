import '../../data/models/user_model.dart';

class HistoryEntity {
  final String id;
  final String type; // 'offline' hoặc 'online'

  // Fields cho offline history
  final String? userId;
  final int? score;
  final int? moves;
  final int? timeElapsed;
  final String? difficulty;
  final bool? isWin;
  final DateTime? datePlayed;
  final User? user;

  // Fields cho online history
  final List<PlayerEntity>? players;
  final dynamic winner; // Có thể là String hoặc User object

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

  const PlayerEntity({
    required this.playerId,
    this.player,
    required this.score,
    required this.moves,
    required this.timeTaken,
  });

  PlayerEntity copyWith({
    String? playerId,
    User? player,
    int? score,
    int? moves,
    int? timeTaken,
  }) {
    return PlayerEntity(
      playerId: playerId ?? this.playerId,
      player: player ?? this.player,
      score: score ?? this.score,
      moves: moves ?? this.moves,
      timeTaken: timeTaken ?? this.timeTaken,
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
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;

  const PaginationWithTypeEntity({
    required this.total,
    required this.totalOffline,
    required this.totalOnline,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
  });
}
