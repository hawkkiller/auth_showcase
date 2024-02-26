import 'package:sizzle_starter/src/core/components/rest_client/rest_client.dart';
import 'package:sizzle_starter/src/feature/auth/data/auth_data_source.dart';
import 'package:sizzle_starter/src/feature/auth/logic/auth_interceptor.dart';

/// AuthRepository
abstract interface class AuthRepository {
  /// Sign in with email and password
  Future<Token> signInWithEmailAndPassword(String email, String password);

  /// Sign out
  Future<void> signOut();
}

/// AuthRepositoryImpl
final class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource<Token> _dataSource;
  final TokenStorage<Token> _storage;

  /// Create an [AuthRepositoryImpl]
  const AuthRepositoryImpl({
    required AuthDataSource<Token> dataSource,
    required TokenStorage<Token> storage,
  })  : _dataSource = dataSource,
        _storage = storage;

  @override
  Future<Token> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final token = await _dataSource.signInWithEmailAndPassword(email, password);
    await _storage.save(token);

    return token;
  }

  @override
  Future<void> signOut() async {
    await _dataSource.signOut();
    await _storage.clear();
  }
}
