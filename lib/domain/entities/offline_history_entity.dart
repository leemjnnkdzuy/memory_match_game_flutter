import '../auth/user.dart';

class OfflineHistoryEntity {
  final String id;
  final String userId;
  final int score;
  final int moves;
  final int timeElapsed;
  final String difficulty;
  final bool isWin;
  final DateTime datePlayed;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final User? user;

  const OfflineHistoryEntity({
    required this.id,
    required this.userId,
    required this.score,
    required this.moves,
    required this.timeElapsed,
    required this.difficulty,
    required this.isWin,
    required this.datePlayed,
    this.createdAt,
    this.updatedAt,
    this.user,
  });

  OfflineHistoryEntity copyWith({
    String? id,
    String? userId,
    int? score,
    int? moves,
    int? timeElapsed,
    String? difficulty,
    bool? isWin,
    DateTime? datePlayed,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? user,
  }) {
    return OfflineHistoryEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      score: score ?? this.score,
      moves: moves ?? this.moves,
      timeElapsed: timeElapsed ?? this.timeElapsed,
      difficulty: difficulty ?? this.difficulty,
      isWin: isWin ?? this.isWin,
      datePlayed: datePlayed ?? this.datePlayed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
    );
  }
}

class OfflineHistoriesResponse {
  final List<OfflineHistoryEntity> histories;
  final PaginationEntity pagination;

  const OfflineHistoriesResponse({
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
