import 'dart:convert';

import 'package:http/http.dart';
import 'package:sizzle_starter/src/feature/auth/logic/auth_interceptor.dart';

/// Data source for authentication
abstract interface class AuthDataSource<T> {
  /// Sign in with email and password
  Future<T> signInWithEmailAndPassword(String email, String password);

  /// Sign out
  Future<void> signOut();
}

/// Auth data source that interacts with backend
/// and interprets the response as [Token] or throws [AuthenticationException]
final class AuthDataSourceNetwork implements AuthDataSource<Token> {
  final Client _client;

  /// Create an [AuthDataSourceNetwork]
  const AuthDataSourceNetwork({required Client client}) : _client = client;

  @override
  Future<Token> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final response = await _client.post(
        Uri.parse('/login'),
        body: {
          'email': email,
          'password': password,
        },
      );

      final body = jsonDecode(response.body);

      // Check if response is an error
      if (body
          case {
            'error': {
              // optional description provided by the server
              'message': final String message,
              // system error code
              'code': final int code,
            }
          }) {
        throw switch (code) {
          WrongCredentialsException.code => const WrongCredentialsException(),
          _ => UnknownAuthenticationException(code: code, error: message)
        };
      }

      // Check if response contains access_token and refresh_token
      if (body
          case {
            'data': {
              'access_token': final String accessToken,
              'refresh_token': final String refreshToken,
            }
          }) {
        return Token(accessToken, refreshToken);
      }

      // If we can't understand the response, throw a format exception
      throw FormatException(
        'Returned response is not understood by the application',
        body,
      );
    } on AuthenticationException {
      rethrow;
    } on Object catch (e, stackTrace) {
      Error.throwWithStackTrace(
        UnknownAuthenticationException(error: e),
        stackTrace,
      );
    }
  }

  @override
  Future<void> signOut() async {}
}

/// Exception thrown when the authentication fails
base class AuthenticationException implements Exception {
  /// Create a [AuthenticationException]
  const AuthenticationException();
}

/// Exception thrown when the credentials are wrong
final class WrongCredentialsException implements AuthenticationException {
  /// Create a [WrongCredentialsException]
  const WrongCredentialsException();

  /// [10001] is the system error code for wrong credentials
  static const int code = 10001;
}

/// Unknown authentication exception
final class UnknownAuthenticationException implements AuthenticationException {
  /// System error code, that is not understood
  final int? code;

  /// Error message
  final Object error;

  /// Create a [UnknownAuthenticationException]
  const UnknownAuthenticationException({
    required this.error,
    this.code,
  });
}
