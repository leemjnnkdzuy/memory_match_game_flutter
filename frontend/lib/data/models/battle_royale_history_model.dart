import '../../domain/entities/battle_royale_history_entity.dart';
import './user_model.dart';

class BattleRoyaleHistoryModel extends BattleRoyaleHistoryEntity {
  const BattleRoyaleHistoryModel({
    required super.id,
    required super.matchId,
    required super.userId,
    required super.rank,
    required super.score,
    required super.pairsFound,
    required super.flipCount,
    required super.completionTime,
    required super.isFinished,
    required super.datePlayed,
    super.createdAt,
    super.updatedAt,
    super.user,
    super.players,
    required super.totalPlayers,
  });

  factory BattleRoyaleHistoryModel.fromJson(Map<String, dynamic> json) {
    return BattleRoyaleHistoryModel(
      id: json['_id'] as String? ?? json['id'] as String,
      matchId: json['matchId'] as String,
      userId: json['userId'] is String
          ? json['userId']
          : (json['userId'] as Map<String, dynamic>)['_id'] as String,
      rank: json['rank'] as int,
      score: json['score'] as int,
      pairsFound: json['pairsFound'] as int,
      flipCount: json['flipCount'] as int,
      completionTime: json['completionTime'] as int,
      isFinished: json['isFinished'] as bool,
      datePlayed: DateTime.parse(json['datePlayed'] as String),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      user: json['userId'] is Map<String, dynamic>
          ? User.fromJson(json['userId'] as Map<String, dynamic>)
          : null,
      players: json['players'] != null
          ? (json['players'] as List)
                .map(
                  (p) => BattleRoyalePlayerResultModel.fromJson(
                    p as Map<String, dynamic>,
                  ),
                )
                .toList()
          : null,
      totalPlayers: json['totalPlayers'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'matchId': matchId,
      'userId': userId,
      'rank': rank,
      'score': score,
      'pairsFound': pairsFound,
      'flipCount': flipCount,
      'completionTime': completionTime,
      'isFinished': isFinished,
      'datePlayed': datePlayed.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'totalPlayers': totalPlayers,
    };
  }
}

class BattleRoyalePlayerResultModel extends BattleRoyalePlayerResult {
  const BattleRoyalePlayerResultModel({
    required super.userId,
    required super.username,
    super.avatarUrl,
    required super.borderColor,
    required super.rank,
    required super.score,
    required super.pairsFound,
    required super.flipCount,
    required super.completionTime,
    required super.isFinished,
  });

  factory BattleRoyalePlayerResultModel.fromJson(Map<String, dynamic> json) {
    return BattleRoyalePlayerResultModel(
      userId: json['userId'] is String
          ? json['userId']
          : (json['userId'] as Map<String, dynamic>)['_id'] as String,
      username: json['username'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      borderColor: json['borderColor'] as String? ?? '#4CAF50',
      rank: json['rank'] as int,
      score: (json['score'] as num).toInt(),
      pairsFound: json['pairsFound'] as int,
      flipCount: json['flipCount'] as int,
      completionTime: json['completionTime'] as int,
      isFinished: json['isFinished'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'avatarUrl': avatarUrl,
      'borderColor': borderColor,
      'rank': rank,
      'score': score,
      'pairsFound': pairsFound,
      'flipCount': flipCount,
      'completionTime': completionTime,
      'isFinished': isFinished,
    };
  }
}

class BattleRoyaleHistoriesResponseModel extends BattleRoyaleHistoriesResponse {
  const BattleRoyaleHistoriesResponseModel({
    required super.histories,
    required super.pagination,
  });

  factory BattleRoyaleHistoriesResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return BattleRoyaleHistoriesResponseModel(
      histories: (json['data'] as List)
          .map(
            (h) => BattleRoyaleHistoryModel.fromJson(h as Map<String, dynamic>),
          )
          .toList(),
      pagination: PaginationModel.fromJson(
        json['pagination'] as Map<String, dynamic>,
      ),
    );
  }
}

class PaginationModel extends PaginationEntity {
  const PaginationModel({
    required super.total,
    required super.page,
    required super.limit,
    required super.totalPages,
    required super.hasNextPage,
    required super.hasPrevPage,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      total: json['total'] as int,
      page: json['page'] as int,
      limit: json['limit'] as int,
      totalPages: json['totalPages'] as int,
      hasNextPage: json['hasNextPage'] as bool,
      hasPrevPage: json['hasPrevPage'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'page': page,
      'limit': limit,
      'totalPages': totalPages,
      'hasNextPage': hasNextPage,
      'hasPrevPage': hasPrevPage,
    };
  }
}
