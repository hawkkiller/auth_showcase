import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizzle_starter/src/feature/auth/bloc/auth_bloc.dart';
import 'package:sizzle_starter/src/feature/dashboard/data/pokemon_repository.dart';

/// {@template dependencies}
/// Dependencies container
/// {@endtemplate}
base class Dependencies {
  /// {@macro dependencies}
  const Dependencies({
    required this.sharedPreferences,
    required this.client,
    required this.authBloc,
    required this.pokemonRepository,
  });

  /// [SharedPreferences] instance, used to store Key-Value pairs.
  final SharedPreferences sharedPreferences;

  /// [Client] instance, used to make HTTP requests.
  final Client client;

  /// [AuthBloc] instance, used to manage the authentication state.
  final AuthBloc authBloc;

  /// [PokemonRepository] instance, used to manage the pokemon data.
  final PokemonRepository pokemonRepository;
}

/// {@template initialization_result}
/// Result of initialization
/// {@endtemplate}
final class InitializationResult {
  /// {@macro initialization_result}
  const InitializationResult({
    required this.dependencies,
    required this.msSpent,
  });

  /// The dependencies
  final Dependencies dependencies;

  /// The number of milliseconds spent
  final int msSpent;

  @override
  String toString() => '$InitializationResult('
      'dependencies: $dependencies, '
      'msSpent: $msSpent'
      ')';
}
