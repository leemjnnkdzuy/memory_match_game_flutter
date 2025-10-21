import 'package:flutter/material.dart';
import '../../../domain/entities/solo_duel_match_entity.dart';
import '../../../domain/entities/pokemon_entity.dart';
import '../../../core/utils/pokemon_name_utils.dart';
import './solo_duel_card_widget.dart';

class SoloDuelGameBoard extends StatelessWidget {
  final SoloDuelMatchEntity match;
  final String myUserId;
  final Function(int) onCardTap;

  const SoloDuelGameBoard({
    super.key,
    required this.match,
    required this.myUserId,
    required this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    bool areTwoCardsFlippedAndMatching = false;
    if (match.flippedCards.length == 2) {
      final firstIndex = match.flippedCards[0].cardIndex;
      final secondIndex = match.flippedCards[1].cardIndex;
      final firstCard = match.cards[firstIndex];
      final secondCard = match.cards[secondIndex];
      areTwoCardsFlippedAndMatching =
          firstCard.pokemonId == secondCard.pokemonId;
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.7,
      ),
      itemCount: match.cards.length,
      itemBuilder: (context, index) {
        final card = match.cards[index];
        final pokemon = PokemonEntity(
          id: card.pokemonId,
          name: card.pokemonName,
          imagePath: PokemonNameUtils.pokemonNameToImagePath(card.pokemonName),
        );

        final showGreenBorder =
            card.isMatched ||
            (card.isFlipped &&
                !card.isMatched &&
                areTwoCardsFlippedAndMatching);

        return SoloDuelCardWidget(
          card: card,
          pokemon: pokemon,
          onTap: () => onCardTap(index),
          isMyTurn: match.currentTurn == myUserId,
          isPotentialMatch: showGreenBorder,
        );
      },
    );
  }
}
