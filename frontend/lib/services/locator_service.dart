import '../../data/datasources/local_pokemon_data_source.dart';
import '../data/implements/pokemon_repository_impl.dart';
import '../../domain/repositories/pokemon_repository.dart';
import '../../domain/usecases/pokemon_use_cases.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  static ServiceLocator get instance => _instance;

  final Map<Type, dynamic> _services = {};

  void registerServices() {
    _services[LocalPokemonDataSource] = LocalPokemonDataSource();

    _services[PokemonRepository] = PokemonRepositoryImpl(
      _services[LocalPokemonDataSource] as LocalPokemonDataSource,
    );

    _services[GetPokemonListUseCase] = GetPokemonListUseCase(
      _services[PokemonRepository] as PokemonRepository,
    );
    _services[GetRandomPokemonUseCase] = GetRandomPokemonUseCase(
      _services[PokemonRepository] as PokemonRepository,
    );
  }

  T get<T>() {
    final service = _services[T];
    if (service == null) {
      throw Exception(
        'Service of type $T not found. Make sure it is registered.',
      );
    }
    return service as T;
  }

  void reset() {
    _services.clear();
  }
}

ServiceLocator get sl => ServiceLocator.instance;
