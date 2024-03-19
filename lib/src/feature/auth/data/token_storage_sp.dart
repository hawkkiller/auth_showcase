import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizzle_starter/src/core/components/rest_client/rest_client.dart';
import 'package:sizzle_starter/src/core/utils/preferences_dao.dart';
import 'package:sizzle_starter/src/feature/auth/logic/auth_interceptor.dart';

/// {@template token_storage_sp}
/// Implementation of [TokenStorage] that uses [TypedEntry] to store
/// the authorization info.
/// {@endtemplate}
final class TokenStorageSP implements TokenStorage<Token> {
  /// {@macro token_storage_sp}
  TokenStorageSP({required SharedPreferences sharedPreferences})
      : _accessToken = TypedEntry(
          sharedPreferences: sharedPreferences,
          key: 'authorization.access_token',
        ),
        _refreshToken = TypedEntry(
          sharedPreferences: sharedPreferences,
          key: 'authorization.refresh_token',
        );

  late final PreferencesEntry<String> _accessToken;
  late final PreferencesEntry<String> _refreshToken;
  final _streamController = StreamController<Token?>.broadcast();

  @override
  Future<Token?> load() async {
    final accessToken = _accessToken.read();
    final refreshToken = _refreshToken.read();

    if (accessToken == null || refreshToken == null) {
      return null;
    }

    return Token(accessToken, refreshToken);
  }

  @override
  Future<void> save(Token tokenPair) async {
    await (
      _accessToken.set(tokenPair.accessToken),
      _refreshToken.set(tokenPair.refreshToken)
    ).wait;

    _streamController.add(tokenPair);
  }

  @override
  Future<void> clear() async {
    await (_accessToken.remove(), _refreshToken.remove()).wait;
    _streamController.add(null);
  }

  @override
  Stream<Token?> getStream() => _streamController.stream;

  @override
  Future<void> close() => _streamController.close();
}
