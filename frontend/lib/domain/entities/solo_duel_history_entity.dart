import '../../data/models/user_model.dart';

class SoloDuelHistoryEntity {
  final String id;
  final String matchId;
  final String userId;
  final String opponentId;
  final int score;
  final int opponentScore;
  final int matchedCards;
  final bool isWin;
  final int gameTime;
  final DateTime datePlayed;
  final User? opponent;

  const SoloDuelHistoryEntity({
    required this.id,
    required this.matchId,
    required this.userId,
    required this.opponentId,
    required this.score,
    required this.opponentScore,
    required this.matchedCards,
    required this.isWin,
    required this.gameTime,
    required this.datePlayed,
    this.opponent,
  });
}

class SoloDuelHistoriesResponse {
  final List<SoloDuelHistoryEntity> histories;
  final PaginationEntity pagination;

  const SoloDuelHistoriesResponse({
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
