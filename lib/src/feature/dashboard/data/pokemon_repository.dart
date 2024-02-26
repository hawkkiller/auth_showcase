import 'package:sizzle_starter/src/feature/dashboard/data/pokemon_data_source.dart';
import 'package:sizzle_starter/src/feature/dashboard/model/pokemon.dart';

/// {@template pokemon_repository}
/// Pokemon repository.
/// {@endtemplate}
abstract interface class PokemonRepository {
  /// Get the list of pokemons
  Future<List<Pokemon>> getPokemons();
}

/// {@macro pokemon_repository}
final class PokemonRepositoryImpl implements PokemonRepository {
  final PokemonDataSource _dataSource;

  /// {@macro pokemon_repository}
  const PokemonRepositoryImpl(this._dataSource);

  @override
  Future<List<Pokemon>> getPokemons() => _dataSource.getPokemons();
}
