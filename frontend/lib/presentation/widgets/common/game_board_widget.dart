import 'package:flutter/material.dart';
import '../../../domain/entities/offline_game_entity.dart';
import '../../../domain/entities/pokemon_entity.dart';
import 'game_card_widget.dart';

typedef CardTapCallback = void Function(CardEntity card);

class GameBoardWidget extends StatelessWidget {
  final List<CardEntity> cards;
  final List<PokemonEntity> pokemonList;
  final GameDifficulty difficulty;
  final CardTapCallback onCardTap;
  final AnimationController flipController;
  final AnimationController matchController;

  const GameBoardWidget({
    super.key,
    required this.cards,
    required this.pokemonList,
    required this.difficulty,
    required this.onCardTap,
    required this.flipController,
    required this.matchController,
  });

  PokemonEntity? _getPokemonById(int id) {
    try {
      return pokemonList.firstWhere((pokemon) => pokemon.id == id);
    } catch (e) {
      return null;
    }
  }

  int _calculateGridColumns(int cardCount, bool isSmallScreen) {
    if (cardCount <= 12) return isSmallScreen ? 3 : 4;
    if (cardCount <= 24) return isSmallScreen ? 4 : 6;
    return isSmallScreen ? 5 : 8;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;
    final cardCount = difficulty.cardPairs * 2;
    final crossAxisCount = _calculateGridColumns(cardCount, isSmallScreen);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.8,
        ),
        itemCount: cardCount,
        itemBuilder: (context, index) {
          final card = cards[index];
          final pokemon = _getPokemonById(card.pokemonId);

          return GameCardWidget(
            card: card,
            pokemon: pokemon,
            onTap: () => onCardTap(card),
            flipController: flipController,
            matchController: matchController,
          );
        },
      ),
    );
  }
}
