class SoloDuelMatchEntity {
  final String matchId;
  final MatchStatus status;
  final List<PlayerEntity> players;
  final List<SoloDuelCardEntity> cards;
  final String? currentTurn;
  final List<FlippedCardEntity> flippedCards;
  final String? winnerId;
  final DateTime? startedAt;
  final DateTime? finishedAt;

  const SoloDuelMatchEntity({
    required this.matchId,
    required this.status,
    required this.players,
    required this.cards,
    this.currentTurn,
    required this.flippedCards,
    this.winnerId,
    this.startedAt,
    this.finishedAt,
  });

  SoloDuelMatchEntity copyWith({
    String? matchId,
    MatchStatus? status,
    List<PlayerEntity>? players,
    List<SoloDuelCardEntity>? cards,
    String? currentTurn,
    List<FlippedCardEntity>? flippedCards,
    String? winnerId,
    DateTime? startedAt,
    DateTime? finishedAt,
  }) {
    return SoloDuelMatchEntity(
      matchId: matchId ?? this.matchId,
      status: status ?? this.status,
      players: players ?? this.players,
      cards: cards ?? this.cards,
      currentTurn: currentTurn ?? this.currentTurn,
      flippedCards: flippedCards ?? this.flippedCards,
      winnerId: winnerId ?? this.winnerId,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
    );
  }
}

class PlayerEntity {
  final String userId;
  final String username;
  final int score;
  final int matchedCards;
  final bool isReady;
  final String? avatar;

  const PlayerEntity({
    required this.userId,
    required this.username,
    required this.score,
    required this.matchedCards,
    required this.isReady,
    this.avatar,
  });

  PlayerEntity copyWith({
    String? userId,
    String? username,
    int? score,
    int? matchedCards,
    bool? isReady,
    String? avatar,
  }) {
    return PlayerEntity(
      userId: userId ?? this.userId,
      username: username ?? this.username,
      score: score ?? this.score,
      matchedCards: matchedCards ?? this.matchedCards,
      isReady: isReady ?? this.isReady,
      avatar: avatar ?? this.avatar,
    );
  }
}

class SoloDuelCardEntity {
  final int pokemonId;
  final String pokemonName;
  final bool isFlipped;
  final bool isMatched;
  final String? matchedBy;
  final String? flippedBy;
  final int position;

  const SoloDuelCardEntity({
    required this.pokemonId,
    required this.pokemonName,
    required this.isFlipped,
    required this.isMatched,
    this.matchedBy,
    this.flippedBy,
    required this.position,
  });

  SoloDuelCardEntity copyWith({
    int? pokemonId,
    String? pokemonName,
    bool? isFlipped,
    bool? isMatched,
    String? matchedBy,
    String? flippedBy,
    int? position,
  }) {
    return SoloDuelCardEntity(
      pokemonId: pokemonId ?? this.pokemonId,
      pokemonName: pokemonName ?? this.pokemonName,
      isFlipped: isFlipped ?? this.isFlipped,
      isMatched: isMatched ?? this.isMatched,
      matchedBy: matchedBy ?? this.matchedBy,
      flippedBy: flippedBy ?? this.flippedBy,
      position: position ?? this.position,
    );
  }
}

class FlippedCardEntity {
  final int cardIndex;
  final String flippedBy;
  final DateTime flippedAt;

  const FlippedCardEntity({
    required this.cardIndex,
    required this.flippedBy,
    required this.flippedAt,
  });
}

enum MatchStatus { waiting, ready, playing, completed, cancelled }
