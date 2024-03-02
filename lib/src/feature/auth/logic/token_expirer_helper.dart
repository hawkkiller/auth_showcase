// ignore_for_file: close_sinks

import 'dart:async';

/// {@template token_expirer_helper}
/// Singleton that is used to simulate the token expiration
///
/// This class is used to simulate the token expiration in the example
/// and can't be used in a real-world application.
///
/// The token expiration is simulated by setting
/// the [expireAccess] and [expireRefresh] variables to `true` and
/// then to `false` after corresponding actions are taken.
/// {@endtemplate}
class TokenExpirerHelper {
  /// {@macro token_expirer_helper}
  factory TokenExpirerHelper() => _instance;

  TokenExpirerHelper._();

  static final TokenExpirerHelper _instance = TokenExpirerHelper._();

  /// The stream that notifies about the changes in the token expiration.
  Stream<String> get changes => _changes.stream;
  final _changes = StreamController<String>.broadcast();

  /// This method is called when the access token is refreshed.
  void refreshed() {
    expireAccess = false;
    expireRefresh = false;

    _changes.add('Token Pair was refreshed');
  }

  /// This method is called when the user logs out.
  void loggedOut(String reason) {
    expireAccess = false;
    expireRefresh = false;

    _changes.add(reason);
  }

  /// This variable controls the expiration of the access token.
  ///
  /// If it is expired, then on the next request to the server, the server will
  /// return a 401 status code, which will force the client to refresh token.
  bool expireAccess = false;

  /// This variable controls the expiration of the refresh token.
  ///
  /// If it is expired, then on the next request to the server, the server will
  /// return a 401 status code, which will force the client to log in again.
  bool expireRefresh = false;
}
