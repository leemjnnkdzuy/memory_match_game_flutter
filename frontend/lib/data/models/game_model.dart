import '../../domain/entities/offline_game_entity.dart';

class GameModel {
  final String id;
  final List<CardModel> cards;
  final int score;
  final int moves;
  final Duration timeElapsed;
  final String status;
  final String difficulty;

  const GameModel({
    required this.id,
    required this.cards,
    required this.score,
    required this.moves,
    required this.timeElapsed,
    required this.status,
    required this.difficulty,
  });

  factory GameModel.fromEntity(OfflineGameEntity entity) {
    return GameModel(
      id: entity.id,
      cards: entity.cards.map((card) => CardModel.fromEntity(card)).toList(),
      score: entity.score,
      moves: entity.moves,
      timeElapsed: entity.timeElapsed,
      status: entity.status.name,
      difficulty: entity.difficulty.name,
    );
  }

  OfflineGameEntity toEntity() {
    return OfflineGameEntity(
      id: id,
      cards: cards.map((card) => card.toEntity()).toList(),
      score: score,
      moves: moves,
      timeElapsed: timeElapsed,
      status: GameStatus.values.firstWhere((s) => s.name == status),
      difficulty: GameDifficulty.values.firstWhere((d) => d.name == difficulty),
    );
  }

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      id: json['id'] as String,
      cards: (json['cards'] as List)
          .map((card) => CardModel.fromJson(card))
          .toList(),
      score: json['score'] as int,
      moves: json['moves'] as int,
      timeElapsed: Duration(milliseconds: json['timeElapsed'] as int),
      status: json['status'] as String,
      difficulty: json['difficulty'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cards': cards.map((card) => card.toJson()).toList(),
      'score': score,
      'moves': moves,
      'timeElapsed': timeElapsed.inMilliseconds,
      'status': status,
      'difficulty': difficulty,
    };
  }
}

class CardModel {
  final String id;
  final int pokemonId;
  final bool isFlipped;
  final bool isMatched;
  final int position;

  const CardModel({
    required this.id,
    required this.pokemonId,
    required this.isFlipped,
    required this.isMatched,
    required this.position,
  });

  factory CardModel.fromEntity(CardEntity entity) {
    return CardModel(
      id: entity.id,
      pokemonId: entity.pokemonId,
      isFlipped: entity.isFlipped,
      isMatched: entity.isMatched,
      position: entity.position,
    );
  }

  CardEntity toEntity() {
    return CardEntity(
      id: id,
      pokemonId: pokemonId,
      isFlipped: isFlipped,
      isMatched: isMatched,
      position: position,
    );
  }

  factory CardModel.fromJson(Map<String, dynamic> json) {
    return CardModel(
      id: json['id'] as String,
      pokemonId: json['pokemonId'] as int,
      isFlipped: json['isFlipped'] as bool,
      isMatched: json['isMatched'] as bool,
      position: json['position'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pokemonId': pokemonId,
      'isFlipped': isFlipped,
      'isMatched': isMatched,
      'position': position,
    };
  }
}
