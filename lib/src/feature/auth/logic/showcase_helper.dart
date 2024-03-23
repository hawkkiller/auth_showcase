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

  static final ShowcaseHelper _instance = ShowcaseHelper._();

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
