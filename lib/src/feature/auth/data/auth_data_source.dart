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

/// Data source for authentication status
final class AuthDataSourceToken implements AuthDataSource<Token> {
  final Client _client;

  /// Create an [AuthDataSourceToken]
  const AuthDataSourceToken({required Client client}) : _client = client;

  @override
  Future<Token> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    final response = await _client.post(
      Uri.parse('/login'),
      body: {
        'email': email,
        'password': password,
      },
    );

    final body = jsonDecode(response.body);

    if (body
        case {
          'access_token': final String accessToken,
          'refresh_token': final String refreshToken,
        }) {
      return Token(accessToken, refreshToken);
    }

    throw FormatException('Invalid response body: ${response.body}');
  }

  @override
  Future<void> signOut() async {}
}
