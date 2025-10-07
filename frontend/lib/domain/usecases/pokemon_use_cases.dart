import '../entities/pokemon_entity.dart';
import '../repositories/pokemon_repository.dart';

class GetPokemonListUseCase {
  final PokemonRepository repository;

  GetPokemonListUseCase(this.repository);

  Future<List<PokemonEntity>> call() {
    return repository.getAllPokemon();
  }
}

class GetRandomPokemonUseCase {
  final PokemonRepository repository;

  GetRandomPokemonUseCase(this.repository);

  Future<List<PokemonEntity>> call(int count) {
    return repository.getRandomPokemon(count);
  }
}
