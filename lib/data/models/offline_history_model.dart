import '../../domain/entities/offline_history_entity.dart';
import 'user_model.dart';

class OfflineHistoryModel {
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

  const OfflineHistoryModel({
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

  factory OfflineHistoryModel.fromJson(Map<String, dynamic> json) {
    return OfflineHistoryModel(
      id: json['id'] as String? ?? json['_id'] as String,
      userId: json['userId'] is String
          ? json['userId']
          : (json['userId'] as Map<String, dynamic>)['_id'] as String,
      score: json['score'] as int,
      moves: json['moves'] as int,
      timeElapsed: json['timeElapsed'] as int,
      difficulty: json['difficulty'] as String,
      isWin: json['isWin'] as bool,
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'score': score,
      'moves': moves,
      'timeElapsed': timeElapsed,
      'difficulty': difficulty,
      'isWin': isWin,
    };
  }

  OfflineHistoryEntity toEntity() {
    return OfflineHistoryEntity(
      id: id,
      userId: userId,
      score: score,
      moves: moves,
      timeElapsed: timeElapsed,
      difficulty: difficulty,
      isWin: isWin,
      datePlayed: datePlayed,
      createdAt: createdAt,
      updatedAt: updatedAt,
      user: user,
    );
  }

  factory OfflineHistoryModel.fromEntity(OfflineHistoryEntity entity) {
    return OfflineHistoryModel(
      id: entity.id,
      userId: entity.userId,
      score: entity.score,
      moves: entity.moves,
      timeElapsed: entity.timeElapsed,
      difficulty: entity.difficulty,
      isWin: entity.isWin,
      datePlayed: entity.datePlayed,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      user: entity.user != null
          ? User(
              id: entity.user!.id,
              username: entity.user!.username,
              email: entity.user!.email,
              firstName: entity.user!.firstName,
              lastName: entity.user!.lastName,
              avatar: entity.user!.avatar,
              language: entity.user!.language,
              bio: entity.user!.bio,
              isActive: entity.user!.isActive,
              isVerified: entity.user!.isVerified,
              githubUrl: entity.user!.githubUrl,
              linkedinUrl: entity.user!.linkedinUrl,
              websiteUrl: entity.user!.websiteUrl,
              youtubeUrl: entity.user!.youtubeUrl,
              facebookUrl: entity.user!.facebookUrl,
              instagramUrl: entity.user!.instagramUrl,
              historyMatch: entity.user!.historyMatch,
              createdAt: entity.user!.createdAt,
              updatedAt: entity.user!.updatedAt,
            )
          : null,
    );
  }
}

class OfflineHistoriesResponseModel {
  final List<OfflineHistoryModel> histories;
  final PaginationModel pagination;

  const OfflineHistoriesResponseModel({
    required this.histories,
    required this.pagination,
  });

  factory OfflineHistoriesResponseModel.fromJson(Map<String, dynamic> json) {
    return OfflineHistoriesResponseModel(
      histories: (json['histories'] as List)
          .map((h) => OfflineHistoryModel.fromJson(h as Map<String, dynamic>))
          .toList(),
      pagination: PaginationModel.fromJson(
        json['pagination'] as Map<String, dynamic>,
      ),
    );
  }

  OfflineHistoriesResponse toEntity() {
    return OfflineHistoriesResponse(
      histories: histories.map((h) => h.toEntity()).toList(),
      pagination: pagination.toEntity(),
    );
  }
}

class PaginationModel {
  final int total;
  final int page;
  final int limit;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPrevPage;

  const PaginationModel({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPrevPage,
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

  PaginationEntity toEntity() {
    return PaginationEntity(
      total: total,
      page: page,
      limit: limit,
      totalPages: totalPages,
      hasNextPage: hasNextPage,
      hasPrevPage: hasPrevPage,
    );
  }
}
