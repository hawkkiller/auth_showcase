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
class ShowcaseHelper {
  /// {@macro token_expirer_helper}
  factory ShowcaseHelper() => _instance;

  ShowcaseHelper._();

  final _controller = StreamController<void>.broadcast();

  static final ShowcaseHelper _instance = ShowcaseHelper._();

  bool _expireAccess = false;

  /// This variable controls the expiration of the access token.
  ///
  /// If it is expired, then on the next request to the server, the server will
  /// return a 401 status code, which will force the client to refresh token.
  bool get expireAccess => _expireAccess;
  set expireAccess(bool value) {
    _expireAccess = value;

    _controller.add(null);
  }

  bool _expireRefresh = false;

  /// This variable controls the expiration of the refresh token.
  ///
  /// If it is expired, then on the next request to the server, the server will
  /// return a 401 status code, which will force the client to log in again.
  bool get expireRefresh => _expireRefresh;
  set expireRefresh(bool value) {
    _expireRefresh = value;

    _controller.add(null);
  }

  /// Stream that emits an event when the [expireAccess] or [expireRefresh]
  /// variables are changed.
  Stream<void> get stream => _controller.stream;

  /// Resets the [expireAccess] and [expireRefresh] variables to `false`.
  void clear() {
    expireAccess = false;
    expireRefresh = false;

    _controller.add(null);
  }
}
