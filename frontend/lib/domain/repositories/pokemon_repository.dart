import '../entities/pokemon_entity.dart';

abstract class PokemonRepository {
  Future<List<PokemonEntity>> getAllPokemon();
  Future<PokemonEntity?> getPokemonById(int id);
  Future<List<PokemonEntity>> getRandomPokemon(int count);
}
