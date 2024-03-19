import 'dart:async';

import 'package:http/http.dart';
import 'package:intercepted_client/intercepted_client.dart';
import 'package:sizzle_starter/src/core/components/rest_client/rest_client.dart';
import 'package:sizzle_starter/src/core/utils/retry_request_mixin.dart';
import 'package:sizzle_starter/src/feature/auth/logic/showcase_helper.dart';

/// Token is a simple class that holds the access and refresh token
class Token {
  /// Create a [Token]
  const Token(this.accessToken, this.refreshToken);

  /// Access token (used to authenticate the user)
  final String accessToken;

  /// Refresh token (used to refresh the access token)
  final String refreshToken;
}

/// Status of the authentication
enum AuthenticationStatus {
  /// Authenticated
  authenticated,

  /// Unauthenticated
  unauthenticated,
}

/// AuthStatusSource is used to get the status of the authentication
abstract interface class AuthStatusSource {
  /// Stream of [AuthenticationStatus]
  Stream<AuthenticationStatus> get authStatus;
}

/// AuthInterceptor is used to add the Auth token to the request header
/// and refreshes or clears the token if the request fails with a 401
class AuthInterceptor extends SequentialHttpInterceptor
    with RetryRequestMixin
    implements AuthStatusSource {
  /// Create an Auth interceptor
  AuthInterceptor({
    required this.tokenStorage,
    required this.authorizationClient,
    Client? retryClient,
    Token? token,
  })  : retryClient = retryClient ?? Client(),
        _token = token {
    tokenStorage.getStream().listen(_updateAuthenticationStatus);
  }

  /// [Client] to retry the request
  final Client retryClient;

  /// [TokenStorage] to store and retrieve the token
  final TokenStorage<Token> tokenStorage;

  /// [AuthorizationClient] to refresh the token
  final AuthorizationClient<Token> authorizationClient;
  final _authStatusController = StreamController<AuthenticationStatus>();
  Token? _token;

  @override
  Stream<AuthenticationStatus> get authStatus => _authStatusController.stream;

  Future<Token?> _loadToken() async => _token ??= await tokenStorage.load();

  Map<String, String> _buildHeaders(Token token) => {
        'Authorization': 'Bearer ${token.accessToken}',
      };

  void _updateAuthenticationStatus(Token? token) {
    _token = token;
    _authStatusController.add(
      token == null
          ? AuthenticationStatus.unauthenticated
          : AuthenticationStatus.authenticated,
    );
  }

  String? _extractTokenFromHeaders(Map<String, String> headers) {
    final authHeader = headers['Authorization'];
    if (authHeader == null || !authHeader.startsWith('Bearer ')) {
      return null;
    }

    return authHeader.substring(7);
  }

  @override
  Future<void> interceptRequest(
    BaseRequest request,
    RequestHandler handler,
  ) async {
    var token = await _loadToken();

    // If token is null, then the request is made without the token
    if (token == null) {
      return handler.next(request);
    }

    // If token is valid, then the request is made with the token
    if (await authorizationClient.isAccessTokenValid(token)) {
      final headers = _buildHeaders(token);
      request.headers.addAll(headers);

      return handler.next(request);
    }

    // If token is not valid and can be refreshed, then the token is refreshed
    if (await authorizationClient.isRefreshTokenValid(token)) {
      token = await authorizationClient.refresh(token);
      await tokenStorage.save(token);
      ShowcaseHelper().tokenRefreshed(
        'Token was refreshed during the request interception',
      );

      final headers = _buildHeaders(token);
      request.headers.addAll(headers);

      return handler.next(request);
    }

    // If token is not valid and cannot be refreshed,
    // then user should be logged out
    await tokenStorage.clear();
    ShowcaseHelper().userLoggedOut(
      'User was logged out during the request interception, '
      'because the token is not valid and cannot be refreshed',
    );

    return handler.rejectRequest(
      const RevokeTokenException('Token is not valid and cannot be refreshed'),
    );
  }

  @override
  Future<void> interceptResponse(
    StreamedResponse response,
    ResponseHandler handler,
  ) async {
    // If response is 401 (Unauthorized), then Access token is expired
    // and, if possible, should be refreshed
    if (response.statusCode != 401) {
      return handler.resolveResponse(response);
    }

    var token = await _loadToken();

    // If token is null, then reject the response
    if (token == null) {
      return handler.resolveResponse(response);
    }

    final tokenFromHeaders = _extractTokenFromHeaders(
      response.request?.headers ?? const {},
    );

    if (tokenFromHeaders == null) {
      return handler.resolveResponse(response);
    }

    // If token is the same, refresh the token
    if (tokenFromHeaders == token.accessToken) {
      if (await authorizationClient.isRefreshTokenValid(token)) {
        try {
          token = await authorizationClient.refresh(token);
          ShowcaseHelper().tokenRefreshed(
            'Token was refreshed during the response interception',
          );
          await tokenStorage.save(token);
        } on RevokeTokenException catch (e) {
          // If token cannot be refreshed, then user should be logged out
          await tokenStorage.clear();
          ShowcaseHelper().userLoggedOut(
            'User was logged out during the response interception, '
            'because the token was not valid or could not be refreshed',
          );
          return handler.rejectResponse(e);
        }
      } else {
        ShowcaseHelper().userLoggedOut(
          'User was logged out during the response interception, '
          'because the token is not valid and cannot be refreshed',
        );
        // If token cannot be refreshed, then user should be logged out
        await tokenStorage.clear();
        return handler.rejectResponse(
          const RevokeTokenException(
            'Token is not valid and cannot be refreshed',
          ),
        );
      }
    }

    // If token is different, then the token is already refreshed
    // and the request should be made again
    final newResponse = await retryRequest(response, retryClient);
    ShowcaseHelper().requestRetried(
      'Request was retried after the token '
      'was refreshed in response interceptor',
    );

    return handler.resolveResponse(newResponse);
  }
}
