import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart';
import 'package:sizzle_starter/src/core/components/rest_client/rest_client.dart';
import 'package:sizzle_starter/src/feature/auth/logic/auth_interceptor.dart';
import 'package:sizzle_starter/src/feature/auth/logic/showcase_helper.dart';

/// Dummy [AuthorizationClient] that always returns true
class AuthorizationClientToken implements AuthorizationClient<Token> {
  final Client _client;

  /// {@macro authorization_client}
  AuthorizationClientToken(this._client);

  @override
  FutureOr<bool> isRefreshTokenValid(Token token) =>
      !ShowcaseHelper().expireRefresh;

  @override
  FutureOr<bool> isAccessTokenValid(Token token) =>
      !ShowcaseHelper().expireAccess;

  @override
  Future<Token> refresh(Token token) async {
    final response = await _client.post(
      Uri.parse('/refresh'),
      headers: {
        'Authorization': 'Bearer ${token.accessToken}',
      },
    );

    final json = jsonDecode(response.body);

    if (json
        case {
          'access_token': final String aToken,
          'refresh_token': final String rToken,
        }) {
      return Token(aToken, rToken);
    }

    throw FormatException('Invalid response $json');
  }
}
