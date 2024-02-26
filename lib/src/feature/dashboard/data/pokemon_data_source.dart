import 'dart:convert';

import 'package:http/http.dart';
import 'package:sizzle_starter/src/feature/dashboard/model/pokemon.dart';

/// {@template pokemon_data_source}
/// Pokemon data source.
/// {@endtemplate}
abstract interface class PokemonDataSource {
  /// Get the list of pokemons
  Future<List<Pokemon>> getPokemons();
}

/// {@macro pokemon_data_source}
final class PokemonDataSourceNetwork implements PokemonDataSource {
  final Client _client;

  /// {@macro pokemon_data_source}
  const PokemonDataSourceNetwork(this._client);

  @override
  Future<List<Pokemon>> getPokemons() async {
    final response = await _client.get(Uri.parse('/pokemons'));
    final json = jsonDecode(response.body) as List<Object?>;

    final pokemons = json.map((e) {
      if (e
          case {
            'name': final String name,
            'type': final String type,
          }) {
        return Pokemon(name: name, type: type);
      }

      throw FormatException('Invalid response $e');
    }).toList();

    return pokemons;
  }
}
