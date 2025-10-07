import '../entities/offline_game_entity.dart';
import '../repositories/game_repository.dart';

class StartNewGameUseCase {
  final GameRepository repository;

  StartNewGameUseCase(this.repository);

  Future<OfflineGameEntity> call(GameDifficulty difficulty) {
    return repository.createNewGame(difficulty);
  }
}

class FlipCardUseCase {
  final GameRepository repository;

  FlipCardUseCase(this.repository);

  Future<OfflineGameEntity> call(OfflineGameEntity game, String cardId) async {
    final cardIndex = game.cards.indexWhere((card) => card.id == cardId);
    if (cardIndex == -1) return game;

    final card = game.cards[cardIndex];
    if (card.isFlipped || card.isMatched) return game;

    final flippedCards = game.cards
        .where((c) => c.isFlipped && !c.isMatched)
        .toList();

    if (flippedCards.length >= 2) {
      return game;
    }

    final updatedCards = List<CardEntity>.from(game.cards);
    updatedCards[cardIndex] = card.copyWith(isFlipped: true);

    var updatedGame = game.copyWith(cards: updatedCards, moves: game.moves + 1);

    if (flippedCards.length == 1) {
      final firstFlipped = flippedCards.first;
      final secondFlipped = updatedCards[cardIndex];

      if (firstFlipped.pokemonId == secondFlipped.pokemonId) {
        final matchedCards = updatedCards.map((c) {
          if (c.id == firstFlipped.id || c.id == secondFlipped.id) {
            return c.copyWith(isMatched: true);
          }
          return c;
        }).toList();

        updatedGame = updatedGame.copyWith(
          cards: matchedCards,
          score: game.score + 10,
        );

        if (matchedCards.every((c) => c.isMatched)) {
          updatedGame = updatedGame.copyWith(status: GameStatus.completed);
        }
      }
    }

    return repository.saveGame(updatedGame);
  }
}

class ResetFlippedCardsUseCase {
  final GameRepository repository;

  ResetFlippedCardsUseCase(this.repository);

  Future<OfflineGameEntity> call(OfflineGameEntity game) async {
    final resetCards = game.cards.map((card) {
      if (card.isFlipped && !card.isMatched) {
        return card.copyWith(isFlipped: false);
      }
      return card;
    }).toList();

    final updatedGame = game.copyWith(cards: resetCards);
    return repository.saveGame(updatedGame);
  }
}
