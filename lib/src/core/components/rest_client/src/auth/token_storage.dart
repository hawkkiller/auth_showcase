import 'dart:async';

/// The interface for token storage.
abstract interface class TokenStorage<T> {
  /// Load the Auth token pair.
  Future<T?> load();

  /// Save the Auth token pair.
  Future<void> save(T tokenPair);

  /// Clear the Auth token pair.
  ///
  /// This is used to clear the token pair when the request fails with a 401.
  Future<void> clear();

  /// A stream of token pairs.
  Stream<T?> getStream();

  /// Close the token storage.
  Future<void> close();
}
