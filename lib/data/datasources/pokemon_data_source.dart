import '../models/pokemon_model.dart';

abstract class PokemonDataSource {
  Future<List<PokemonModel>> getAllPokemon();
  Future<PokemonModel?> getPokemonById(int id);
}
