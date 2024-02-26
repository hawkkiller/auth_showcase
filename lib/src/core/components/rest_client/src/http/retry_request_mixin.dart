import 'package:http/http.dart';

/// Mixin that provides a method to retry a request.
mixin RetryRequestMixin {
  /// Method that retries a request.
  ///
  /// It supports [Request] and [MultipartRequest] types, creates [Client] under
  /// the hood and sends the request again returning a [StreamedResponse].
  ///
  /// It doesn't support [StreamedRequest] and [BaseRequest] types to avoid
  /// unexpected behavior.
  Future<StreamedResponse> retryRequest(StreamedResponse response) async {
    final oldRequest = response.request;

    if (oldRequest is Request) {
      final newRequest = Request(
        oldRequest.method,
        oldRequest.url,
      );

      newRequest.headers.addAll(oldRequest.headers);
      newRequest.followRedirects = oldRequest.followRedirects;
      newRequest.maxRedirects = oldRequest.maxRedirects;
      newRequest.persistentConnection = oldRequest.persistentConnection;
      newRequest.bodyBytes = oldRequest.bodyBytes;

      return newRequest.send();
    }

    if (oldRequest is MultipartRequest) {
      final newRequest = MultipartRequest(
        oldRequest.method,
        oldRequest.url,
      );

      newRequest.headers.addAll(oldRequest.headers);
      newRequest.followRedirects = oldRequest.followRedirects;
      newRequest.maxRedirects = oldRequest.maxRedirects;
      newRequest.persistentConnection = oldRequest.persistentConnection;

      for (final field in oldRequest.fields.entries) {
        newRequest.fields[field.key] = field.value;
      }

      newRequest.files.addAll(oldRequest.files);

      return newRequest.send();
    }

    throw ArgumentError('Unknown request type: ${oldRequest.runtimeType}');
  }
}
