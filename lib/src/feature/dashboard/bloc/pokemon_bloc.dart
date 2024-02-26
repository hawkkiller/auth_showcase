import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizzle_starter/src/feature/dashboard/data/pokemon_repository.dart';
import 'package:sizzle_starter/src/feature/dashboard/model/pokemon.dart';

/// Pokemon event
sealed class PokemonEvent {
  const PokemonEvent();

  /// Load the pokemons
  const factory PokemonEvent.load() = _LoadPokemonEvent;
}

final class _LoadPokemonEvent extends PokemonEvent {
  const _LoadPokemonEvent();
}

/// The state of the pokemon bloc
sealed class PokemonState {
  const PokemonState({
    required this.pokemons,
  });

  /// The list of pokemons
  final List<Pokemon> pokemons;

  /// Returns true if the state is idle
  bool get isIdle => switch (this) {
        _IdlePokemonState _ => true,
        _ => false,
      };

  /// Returns true if the state is loading
  bool get isLoading => switch (this) {
        _LoadingPokemonState _ => true,
        _ => false,
      };

  /// Returns true if the state is loaded
  bool get isLoaded => switch (this) {
        _LoadedPokemonState _ => true,
        _ => false,
      };
}

final class _IdlePokemonState extends PokemonState {
  const _IdlePokemonState({
    required super.pokemons,
  });

  @override
  String toString() => 'IdlePokemonState(pokemons: $pokemons)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is _IdlePokemonState && other.pokemons == pokemons);

  @override
  int get hashCode => pokemons.hashCode;
}

final class _LoadingPokemonState extends PokemonState {
  const _LoadingPokemonState({
    required super.pokemons,
  });

  @override
  String toString() => 'LoadingPokemonState(pokemons: $pokemons)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is _LoadingPokemonState && other.pokemons == pokemons);

  @override
  int get hashCode => pokemons.hashCode;
}

final class _LoadedPokemonState extends PokemonState {
  const _LoadedPokemonState({
    required super.pokemons,
  });

  @override
  String toString() => 'LoadedPokemonState(pokemons: $pokemons)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is _LoadedPokemonState && other.pokemons == pokemons);

  @override
  int get hashCode => pokemons.hashCode;
}

/// {@template pokemon_bloc}
/// Pokemon bloc.
/// {@endtemplate}
class PokemonBloc extends Bloc<PokemonEvent, PokemonState> {
  final PokemonRepository _pokemonRepository;

  /// {@macro pokemon_bloc}
  PokemonBloc(this._pokemonRepository)
      : super(const _IdlePokemonState(pokemons: [])) {
    on<_LoadPokemonEvent>(_onLoadPokemon);
  }

  Future<void> _onLoadPokemon(
    _LoadPokemonEvent event,
    Emitter<PokemonState> emit,
  ) async {
    try {
      emit(_LoadingPokemonState(pokemons: state.pokemons));
      final pokemons = await _pokemonRepository.getPokemons();
      emit(_LoadedPokemonState(pokemons: pokemons));
    } on Object catch (e, st) {
      onError(e, st);
    }
  }
}
