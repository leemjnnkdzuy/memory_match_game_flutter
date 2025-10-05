class OfflineGameEntity {
  final String id;
  final List<CardEntity> cards;
  final int score;
  final int moves;
  final Duration timeElapsed;
  final GameStatus status;
  final GameDifficulty difficulty;

  const OfflineGameEntity({
    required this.id,
    required this.cards,
    required this.score,
    required this.moves,
    required this.timeElapsed,
    required this.status,
    required this.difficulty,
  });

  OfflineGameEntity copyWith({
    String? id,
    List<CardEntity>? cards,
    int? score,
    int? moves,
    Duration? timeElapsed,
    GameStatus? status,
    GameDifficulty? difficulty,
  }) {
    return OfflineGameEntity(
      id: id ?? this.id,
      cards: cards ?? this.cards,
      score: score ?? this.score,
      moves: moves ?? this.moves,
      timeElapsed: timeElapsed ?? this.timeElapsed,
      status: status ?? this.status,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}

class CardEntity {
  final String id;
  final int pokemonId;
  final bool isFlipped;
  final bool isMatched;
  final int position;

  const CardEntity({
    required this.id,
    required this.pokemonId,
    required this.isFlipped,
    required this.isMatched,
    required this.position,
  });

  CardEntity copyWith({
    String? id,
    int? pokemonId,
    bool? isFlipped,
    bool? isMatched,
    int? position,
  }) {
    return CardEntity(
      id: id ?? this.id,
      pokemonId: pokemonId ?? this.pokemonId,
      isFlipped: isFlipped ?? this.isFlipped,
      isMatched: isMatched ?? this.isMatched,
      position: position ?? this.position,
    );
  }
}

enum GameStatus { notStarted, playing, paused, completed, gameOver }

enum GameDifficulty {
  veryEasy(cardPairs: 6, timeLimit: Duration(minutes: 5)),
  easy(cardPairs: 12, timeLimit: Duration(minutes: 10)),
  normal(cardPairs: 18, timeLimit: Duration(minutes: 15)),
  medium(cardPairs: 24, timeLimit: Duration(minutes: 20)),
  hard(cardPairs: 30, timeLimit: Duration(minutes: 30)),
  superHard(cardPairs: 36, timeLimit: Duration(minutes: 40)),
  insane(cardPairs: 42, timeLimit: Duration(minutes: 50)),
  extreme(cardPairs: 48, timeLimit: Duration(minutes: 60));

  const GameDifficulty({required this.cardPairs, required this.timeLimit});

  final int cardPairs;
  final Duration timeLimit;
}
