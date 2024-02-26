import 'dart:async';

/// The client that refreshes the Auth token using the refresh token.
abstract interface class AuthorizationClient<T> {
  /// Check if the token can be refreshed.
  FutureOr<bool> isRefreshTokenValid(T token);

  /// Check if the token is valid.
  FutureOr<bool> isAccessTokenValid(T token);

  /// Refresh the token.
  Future<T> refresh(T token);
}
