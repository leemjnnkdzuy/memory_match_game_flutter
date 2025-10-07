import '../../domain/entities/solo_duel_history_entity.dart';
import './user_model.dart';

class SoloDuelHistoryModel extends SoloDuelHistoryEntity {
  const SoloDuelHistoryModel({
    required super.id,
    required super.matchId,
    required super.userId,
    required super.opponentId,
    required super.score,
    required super.opponentScore,
    required super.matchedCards,
    required super.isWin,
    required super.gameTime,
    required super.datePlayed,
    super.opponent,
  });

  factory SoloDuelHistoryModel.fromJson(Map<String, dynamic> json) {
    return SoloDuelHistoryModel(
      id: json['_id'] as String,
      matchId: json['matchId'] as String,
      userId: json['userId'] as String,
      opponentId: json['opponentId'] as String,
      score: json['score'] as int,
      opponentScore: json['opponentScore'] as int,
      matchedCards: json['matchedCards'] as int,
      isWin: json['isWin'] as bool,
      gameTime: json['gameTime'] as int,
      datePlayed: DateTime.parse(json['datePlayed'] as String),
      opponent: json['opponent'] != null
          ? User.fromJson(json['opponent'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'matchId': matchId,
      'userId': userId,
      'opponentId': opponentId,
      'score': score,
      'opponentScore': opponentScore,
      'matchedCards': matchedCards,
      'isWin': isWin,
      'gameTime': gameTime,
      'datePlayed': datePlayed.toIso8601String(),
      'opponent': opponent?.toJson(),
    };
  }
}

class SoloDuelHistoriesResponseModel extends SoloDuelHistoriesResponse {
  const SoloDuelHistoriesResponseModel({
    required super.histories,
    required super.pagination,
  });

  factory SoloDuelHistoriesResponseModel.fromJson(Map<String, dynamic> json) {
    return SoloDuelHistoriesResponseModel(
      histories: (json['data'] as List)
          .map((h) => SoloDuelHistoryModel.fromJson(h as Map<String, dynamic>))
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
