import '../../domain/entities/history_entity.dart';
import 'user_model.dart';

class HistoryModel {
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

  final List<PlayerModel>? players;
  final dynamic winner;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const HistoryModel({
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

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;

    if (type == 'offline') {
      final userIdData = json['userId'];

      return HistoryModel(
        id: json['id'] as String? ?? json['_id'] as String,
        type: type,
        userId: userIdData is String
            ? userIdData
            : (userIdData as Map<String, dynamic>)['_id'] as String,
        score: (json['score'] as num?)?.toInt(),
        moves: (json['moves'] as num?)?.toInt(),
        timeElapsed: (json['timeElapsed'] as num?)?.toInt(),
        difficulty: json['difficulty'] as String?,
        isWin: json['isWin'] as bool?,
        datePlayed: json['datePlayed'] != null
            ? DateTime.parse(json['datePlayed'] as String)
            : null,
        user: userIdData is Map<String, dynamic>
            ? User.fromJson(userIdData)
            : null,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
      );
    } else {
      final winnerData = json['winner'];

      return HistoryModel(
        id: json['id'] as String? ?? json['_id'] as String,
        type: type,
        players: json['players'] != null
            ? (json['players'] as List)
                  .map((p) => PlayerModel.fromJson(p as Map<String, dynamic>))
                  .toList()
            : null,
        winner: winnerData is Map<String, dynamic>
            ? User.fromJson(winnerData)
            : winnerData,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
      );
    }
  }
  HistoryEntity toEntity() {
    return HistoryEntity(
      id: id,
      type: type,
      userId: userId,
      score: score,
      moves: moves,
      timeElapsed: timeElapsed,
      difficulty: difficulty,
      isWin: isWin,
      datePlayed: datePlayed,
      user: user,
      players: players?.map((p) => p.toEntity()).toList(),
      winner: winner,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}

class PlayerModel {
  final String playerId;
  final User? player;
  final int score;
  final int moves;
  final int timeTaken;

  const PlayerModel({
    required this.playerId,
    this.player,
    required this.score,
    required this.moves,
    required this.timeTaken,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    final playerIdData = json['playerId'];

    return PlayerModel(
      playerId: playerIdData is String
          ? playerIdData
          : (playerIdData as Map<String, dynamic>)['_id'] as String,
      player: playerIdData is Map<String, dynamic>
          ? User.fromJson(playerIdData)
          : null,
      score: (json['score'] as num?)?.toInt() ?? 0,
      moves: (json['moves'] as num?)?.toInt() ?? 0,
      timeTaken: (json['timeTaken'] as num?)?.toInt() ?? 0,
    );
  }

  PlayerEntity toEntity() {
    return PlayerEntity(
      playerId: playerId,
      player: player,
      score: score,
      moves: moves,
      timeTaken: timeTaken,
    );
  }
}

class HistoriesResponseModel {
  final List<HistoryModel> histories;
  final PaginationWithTypeModel pagination;

  const HistoriesResponseModel({
    required this.histories,
    required this.pagination,
  });

  factory HistoriesResponseModel.fromJson(Map<String, dynamic> json) {
    return HistoriesResponseModel(
      histories: (json['histories'] as List)
          .map((h) => HistoryModel.fromJson(h as Map<String, dynamic>))
          .toList(),
      pagination: PaginationWithTypeModel.fromJson(
        json['pagination'] as Map<String, dynamic>,
      ),
    );
  }

  HistoriesResponse toEntity() {
    return HistoriesResponse(
      histories: histories.map((h) => h.toEntity()).toList(),
      pagination: pagination.toEntity(),
    );
  }
}

class PaginationWithTypeModel {
  final int total;
  final int totalOffline;
  final int totalOnline;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;

  const PaginationWithTypeModel({
    required this.total,
    required this.totalOffline,
    required this.totalOnline,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory PaginationWithTypeModel.fromJson(Map<String, dynamic> json) {
    return PaginationWithTypeModel(
      total: json['total'] as int,
      totalOffline: json['totalOffline'] as int,
      totalOnline: json['totalOnline'] as int,
      page: json['page'] as int,
      limit: json['limit'] as int,
      totalPages: json['totalPages'] as int,
      hasNextPage: json['hasNextPage'] as bool,
      hasPrevPage: json['hasPrevPage'] as bool,
    );
  }

  PaginationWithTypeEntity toEntity() {
    return PaginationWithTypeEntity(
      total: total,
      totalOffline: totalOffline,
      totalOnline: totalOnline,
      page: page,
      limit: limit,
      totalPages: totalPages,
      hasNextPage: hasNextPage,
      hasPrevPage: hasPrevPage,
    );
  }
}
