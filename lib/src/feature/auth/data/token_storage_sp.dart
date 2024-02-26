import 'dart:async';

import 'package:sizzle_starter/src/core/components/rest_client/rest_client.dart';
import 'package:sizzle_starter/src/core/utils/preferences_dao.dart';
import 'package:sizzle_starter/src/feature/auth/logic/auth_interceptor.dart';

/// Token is a simple class that holds the access and refresh token
final class TokenStorageSP extends PreferencesDao
    implements TokenStorage<Token> {
  /// Create a [TokenStorageSP]
  TokenStorageSP({required super.sharedPreferences});

  late final _accessToken = stringEntry('access_token');
  late final _refreshToken = stringEntry('refresh_token');
  final _streamController = StreamController<Token?>.broadcast();

  @override
  Future<void> clear() async {
    await (_accessToken.remove(), _refreshToken.remove()).wait;
    _streamController.add(null);
  }

  @override
  Future<void> close() => _streamController.close();

  @override
  Stream<Token?> getStream() => _streamController.stream;

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
}
