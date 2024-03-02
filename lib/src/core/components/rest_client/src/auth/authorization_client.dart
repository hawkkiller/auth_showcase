import 'dart:async';

/// {@template revoke_token_exception}
/// Revoke token exception
///
/// This exception is thrown when the token is not valid and cannot be refreshed
/// {@endtemplate}
class RevokeTokenException implements Exception {
  /// Create a [RevokeTokenException]
  const RevokeTokenException(this.message);

  /// The message of the exception
  final String message;

  @override
  String toString() => 'RevokeTokenException: $message';
}

/// The client that refreshes the Auth token using the refresh token.
abstract interface class AuthorizationClient<T> {
  /// Check if the token can be refreshed.
  FutureOr<bool> isRefreshTokenValid(T token);

  /// Check if the token is valid.
  FutureOr<bool> isAccessTokenValid(T token);

  /// Refreshes token pair
  ///
  /// Should throw [RevokeTokenException] if token pair
  /// cannot be refreshed.
  Future<T> refresh(T token);
}
