import '../../data/models/user_model.dart';

class BattleRoyaleHistoryEntity {
  final String id;
  final String matchId;
  final String userId;
  final int rank;
  final int score;
  final int pairsFound;
  final int flipCount;
  final int completionTime;
  final bool isFinished;
  final DateTime datePlayed;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final User? user;
  final List<BattleRoyalePlayerResult>? players;
  final int totalPlayers;

  const BattleRoyaleHistoryEntity({
    required this.id,
    required this.matchId,
    required this.userId,
    required this.rank,
    required this.score,
    required this.pairsFound,
    required this.flipCount,
    required this.completionTime,
    required this.isFinished,
    required this.datePlayed,
    this.createdAt,
    this.updatedAt,
    this.user,
    this.players,
    required this.totalPlayers,
  });
}

class BattleRoyalePlayerResult {
  final String userId;
  final String username;
  final String? avatarUrl;
  final String borderColor;
  final int rank;
  final int score;
  final int pairsFound;
  final int flipCount;
  final int completionTime;
  final bool isFinished;

  const BattleRoyalePlayerResult({
    required this.userId,
    required this.username,
    this.avatarUrl,
    required this.borderColor,
    required this.rank,
    required this.score,
    required this.pairsFound,
    required this.flipCount,
    required this.completionTime,
    required this.isFinished,
  });
}

class BattleRoyaleHistoriesResponse {
  final List<BattleRoyaleHistoryEntity> histories;
  final PaginationEntity pagination;

  const BattleRoyaleHistoriesResponse({
    required this.histories,
    required this.pagination,
  });
}

class PaginationEntity {
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;

  const PaginationEntity({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
  });
}
