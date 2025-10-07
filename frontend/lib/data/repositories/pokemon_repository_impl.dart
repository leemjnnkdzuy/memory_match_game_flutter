import 'dart:math';
import '../../domain/entities/pokemon_entity.dart';
import '../../domain/repositories/pokemon_repository.dart';
import '../datasources/local_pokemon_data_source.dart';

class PokemonRepositoryImpl implements PokemonRepository {
  final LocalPokemonDataSource dataSource;

  PokemonRepositoryImpl(this.dataSource);

  @override
  Future<List<PokemonEntity>> getAllPokemon() async {
    final models = await dataSource.getAllPokemon();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<PokemonEntity?> getPokemonById(int id) async {
    final model = await dataSource.getPokemonById(id);
    return model?.toEntity();
  }

  @override
  Future<List<PokemonEntity>> getRandomPokemon(int count) async {
    final allPokemon = await getAllPokemon();
    final random = Random();

    if (count >= allPokemon.length) {
      return allPokemon;
    }

    final shuffled = List<PokemonEntity>.from(allPokemon);
    shuffled.shuffle(random);

    return shuffled.take(count).toList();
  }
}
