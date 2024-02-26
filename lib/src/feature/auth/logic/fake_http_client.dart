import 'dart:convert';

import 'package:http/http.dart';
import 'package:http/testing.dart';

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

/// {@template fake_http_client}
/// A fake HTTP client, that returns mock responses.
///
/// This is used in the application instead of communicating with a real server.
/// {@endtemplate}
class FakeHttpClient extends MockClient {
  /// {@macro fake_http_client}
  FakeHttpClient() : super(_handler);

  static Future<Response> _handler(Request request) async {
    if (request.url.path == '/login') {
      return Response(
        '{"access_token": "abcd", "refresh_token": "abcd"}',
        200,
        request: request,
      );
    }

    if (request.url.path == '/refresh') {
      // if the refresh token is expired, return 401
      if (expireRefresh) {
        return Response(
          'Unauthorized',
          401,
          request: request,
        );
      }

      return Response(
        '{"access_token": "abcd", "refresh_token": "abcd"}',
        200,
        request: request,
      );
    }

    if (expireAccess || expireRefresh) {
      await Future<void>.delayed(const Duration(seconds: 2));
      return Response(
        'Unauthorized',
        401,
        request: request,
      );
    }

    if (request.url.path == '/pokemons') {
      await Future<void>.delayed(const Duration(seconds: 2));
      return Response(
        json.encode([
          {'name': 'Pikachu', 'type': 'Electric'},
          {'name': 'Charmander', 'type': 'Fire'},
          {'name': 'Squirtle', 'type': 'Water'},
        ]),
        200,
        request: request,
      );
    }

    return Response('Not Found', 404, request: request);
  }
}
