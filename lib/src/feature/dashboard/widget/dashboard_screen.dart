import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sizzle_starter/src/feature/auth/logic/showcase_helper.dart';
import 'package:sizzle_starter/src/feature/auth/widget/auth_scope.dart';
import 'package:sizzle_starter/src/feature/dashboard/bloc/pokemon_bloc.dart';
import 'package:sizzle_starter/src/feature/initialization/widget/dependencies_scope.dart';

/// {@template dashboard_screen}
/// Protected screen, visible to authenticated users only.
/// {@endtemplate}
class DashboardScreen extends StatefulWidget {
  /// {@macro dashboard_screen}
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final PokemonBloc _pokemonBloc;

  @override
  void initState() {
    _pokemonBloc = PokemonBloc(DependenciesScope.of(context).pokemonRepository);
    super.initState();
  }

  void _loadPokemons() {
    _pokemonBloc.add(const PokemonEvent.load());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: _loadPokemons,
          child: const Icon(Icons.refresh_sharp),
        ),
        body: BlocBuilder<PokemonBloc, PokemonState>(
          bloc: _pokemonBloc,
          builder: (context, state) => CustomScrollView(
            slivers: [
              SliverAppBar(
                title: const Text('Dashboard'),
                pinned: true,
                expandedHeight: 144,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout),
                    onPressed: AuthScope.of(context).signOut,
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Material(
                      type: MaterialType.transparency,
                      child: StreamBuilder<void>(
                        stream: ShowcaseHelper().stream,
                        builder: (context, snapshot) => Row(
                          children: [
                            const Text('Expire access'),
                            Switch(
                              value: ShowcaseHelper().expireAccess,
                              onChanged: (value) =>
                                  ShowcaseHelper().expireAccess = value,
                            ),
                            const Text('Expire refresh'),
                            Switch(
                              value: ShowcaseHelper().expireRefresh,
                              onChanged: (value) =>
                                  ShowcaseHelper().expireRefresh = value,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              if (state.isIdle)
                SliverFillRemaining(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('No pokemons loaded'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPokemons,
                        child: const Text('Load pokemons'),
                      ),
                    ],
                  ),
                ),
              if (state.pokemons.isNotEmpty)
                SliverList.builder(
                  itemCount: state.pokemons.length,
                  itemBuilder: (context, index) {
                    final pokemon = state.pokemons[index];
                    return ListTile(
                      title: Text(pokemon.name),
                      subtitle: Text(pokemon.type),
                    );
                  },
                ),
              if (state.isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        ),
      );
}
