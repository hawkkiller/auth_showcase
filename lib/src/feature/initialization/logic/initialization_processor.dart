import 'package:intercepted_client/intercepted_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizzle_starter/src/core/utils/logger.dart';
import 'package:sizzle_starter/src/feature/app/logic/tracking_manager.dart';
import 'package:sizzle_starter/src/feature/auth/bloc/auth_bloc.dart';
import 'package:sizzle_starter/src/feature/auth/data/auth_data_source.dart';
import 'package:sizzle_starter/src/feature/auth/data/auth_repository.dart';
import 'package:sizzle_starter/src/feature/auth/data/token_storage_sp.dart';
import 'package:sizzle_starter/src/feature/auth/logic/auth_interceptor.dart';
import 'package:sizzle_starter/src/feature/auth/logic/authorization_client.dart';
import 'package:sizzle_starter/src/feature/auth/logic/fake_http_client.dart';
import 'package:sizzle_starter/src/feature/dashboard/data/pokemon_data_source.dart';
import 'package:sizzle_starter/src/feature/dashboard/data/pokemon_repository.dart';
import 'package:sizzle_starter/src/feature/initialization/model/dependencies.dart';
import 'package:sizzle_starter/src/feature/initialization/model/environment_store.dart';

part 'initialization_factory.dart';

/// {@template initialization_processor}
/// A class which is responsible for processing initialization steps.
/// {@endtemplate}
final class InitializationProcessor {
  final ExceptionTrackingManager _trackingManager;
  final EnvironmentStore _environmentStore;

  /// {@macro initialization_processor}
  const InitializationProcessor({
    required ExceptionTrackingManager trackingManager,
    required EnvironmentStore environmentStore,
  })  : _trackingManager = trackingManager,
        _environmentStore = environmentStore;

  Future<Dependencies> _initDependencies() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final fakeClient = FakeHttpClient();

    final storage = TokenStorageSP(sharedPreferences: sharedPreferences);

    final authInterceptor = AuthInterceptor(
      tokenStorage: storage,
      authorizationClient: DummyAuthorizationClient(fakeClient),
      retryClient: fakeClient,
    );

    final interceptedClient = InterceptedClient(
      inner: fakeClient,
      interceptors: [authInterceptor],
    );

    final status = await authInterceptor.init();

    final authBloc = AuthBloc(
      AuthState.idle(status: status),
      authStatusSource: authInterceptor,
      authRepository: AuthRepositoryImpl(
        dataSource: AuthDataSourceNetwork(client: interceptedClient),
        storage: storage,
      ),
    );

    final pokemonRepository = PokemonRepositoryImpl(
      PokemonDataSourceNetwork(interceptedClient),
    );

    return Dependencies(
      sharedPreferences: sharedPreferences,
      client: interceptedClient,
      authBloc: authBloc,
      pokemonRepository: pokemonRepository,
    );
  }

  /// Method that starts the initialization process
  /// and returns the result of the initialization.
  ///
  /// This method may contain additional steps that need initialization
  /// before the application starts
  /// (for example, caching or enabling tracking manager)
  Future<InitializationResult> initialize() async {
    if (_environmentStore.enableTrackingManager) {
      await _trackingManager.enableReporting();
    }
    final stopwatch = Stopwatch()..start();

    logger.info('Initializing dependencies...');
    final dependencies = await _initDependencies();
    logger.info('Dependencies initialized');

    stopwatch.stop();
    final result = InitializationResult(
      dependencies: dependencies,
      msSpent: stopwatch.elapsedMilliseconds,
    );
    return result;
  }
}
