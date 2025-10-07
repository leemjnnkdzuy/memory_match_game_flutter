import '../../domain/entities/solo_duel_match_entity.dart';

class SoloDuelMatchModel extends SoloDuelMatchEntity {
  const SoloDuelMatchModel({
    required super.matchId,
    required super.status,
    required super.players,
    required super.cards,
    super.currentTurn,
    required super.flippedCards,
    super.winnerId,
    super.startedAt,
    super.finishedAt,
  });

  factory SoloDuelMatchModel.fromJson(Map<String, dynamic> json) {
    return SoloDuelMatchModel(
      matchId: json['matchId'] as String,
      status: _parseMatchStatus(json['status'] as String),
      players: (json['players'] as List)
          .map((p) => PlayerModel.fromJson(p as Map<String, dynamic>))
          .toList(),
      cards: (json['cards'] as List)
          .map((c) => SoloDuelCardModel.fromJson(c as Map<String, dynamic>))
          .toList(),
      currentTurn: json['currentTurn'] as String?,
      flippedCards:
          (json['flippedCards'] as List?)
              ?.map((f) => FlippedCardModel.fromJson(f as Map<String, dynamic>))
              .toList() ??
          [],
      winnerId: json['winnerId'] as String?,
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'] as String)
          : null,
      finishedAt: json['finishedAt'] != null
          ? DateTime.parse(json['finishedAt'] as String)
          : null,
    );
  }

  static MatchStatus _parseMatchStatus(String status) {
    switch (status.toLowerCase()) {
      case 'waiting':
        return MatchStatus.waiting;
      case 'ready':
        return MatchStatus.ready;
      case 'playing':
        return MatchStatus.playing;
      case 'completed':
        return MatchStatus.completed;
      case 'cancelled':
        return MatchStatus.cancelled;
      default:
        return MatchStatus.waiting;
    }
  }
}

class PlayerModel extends PlayerEntity {
  const PlayerModel({
    required super.userId,
    required super.username,
    required super.score,
    required super.matchedCards,
    required super.isReady,
  });

  factory PlayerModel.fromJson(Map<String, dynamic> json) {
    return PlayerModel(
      userId: json['userId'] as String,
      username: json['username'] as String,
      score: json['score'] as int,
      matchedCards: json['matchedCards'] as int,
      isReady: json['isReady'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'score': score,
      'matchedCards': matchedCards,
      'isReady': isReady,
    };
  }
}

class SoloDuelCardModel extends SoloDuelCardEntity {
  const SoloDuelCardModel({
    required super.pokemonId,
    required super.pokemonName,
    required super.isFlipped,
    required super.isMatched,
    super.matchedBy,
    super.flippedBy,
    required super.position,
  });

  factory SoloDuelCardModel.fromJson(Map<String, dynamic> json) {
    return SoloDuelCardModel(
      pokemonId: json['pokemonId'] as int,
      pokemonName: json['pokemonName'] as String,
      isFlipped: json['isFlipped'] as bool? ?? false,
      isMatched: json['isMatched'] as bool? ?? false,
      matchedBy: json['matchedBy'] as String?,
      flippedBy: json['flippedBy'] as String?,
      position: json['position'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pokemonId': pokemonId,
      'pokemonName': pokemonName,
      'isFlipped': isFlipped,
      'isMatched': isMatched,
      'matchedBy': matchedBy,
      'flippedBy': flippedBy,
      'position': position,
    };
  }
}

class FlippedCardModel extends FlippedCardEntity {
  const FlippedCardModel({
    required super.cardIndex,
    required super.flippedBy,
    required super.flippedAt,
  });

  factory FlippedCardModel.fromJson(Map<String, dynamic> json) {
    return FlippedCardModel(
      cardIndex: json['cardIndex'] as int,
      flippedBy: json['flippedBy'] as String,
      flippedAt: DateTime.parse(json['flippedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cardIndex': cardIndex,
      'flippedBy': flippedBy,
      'flippedAt': flippedAt.toIso8601String(),
    };
  }
}
