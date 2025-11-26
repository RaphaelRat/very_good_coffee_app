import 'dart:convert';

import 'package:http/http.dart' as http;

/// Base class for all exceptions thrown by [CoffeeApi].
abstract class CoffeeApiException implements Exception {
  /// Creates a new [CoffeeApiException].
  const CoffeeApiException();
}

/// Thrown when the remote coffee API responds with a non-200 status code.
///
/// The [statusCode] property contains the HTTP status code returned
/// by the server.
class CoffeeApiRequestFailure extends CoffeeApiException {
  /// Creates a new [CoffeeApiRequestFailure] with the given [statusCode].
  const CoffeeApiRequestFailure(this.statusCode);

  /// HTTP status code returned by the coffee API.
  final int statusCode;

  @override
  String toString() => 'CoffeeApiRequestFailure(statusCode: $statusCode)';
}

/// Thrown when the remote coffee API returns an unexpected payload.
///
/// This usually means the response body is not valid JSON or does not
/// contain the expected `file` field.
class CoffeeApiMalformedResponse extends CoffeeApiException {
  /// Creates a new [CoffeeApiMalformedResponse].
  const CoffeeApiMalformedResponse();

  @override
  String toString() => 'CoffeeApiMalformedResponse()';
}

/// {@template coffee_api}
/// HTTP client for the public coffee image API.
///
/// This client is responsible only for performing HTTP requests and
/// decoding the response. It does not cache data or know anything about
/// Flutter or presentation concerns.
/// {@endtemplate}
class CoffeeApi {
  /// Creates a new [CoffeeApi] instance.
  ///
  /// If no [httpClient] is provided, a default [http.Client] is created.
  CoffeeApi({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;

  static const _baseUrl = 'https://coffee.alexflipnote.dev/random.json';

  /// Fetches a random coffee image URL from the remote API.
  ///
  /// Returns the `file` property from the JSON response when the request
  /// is successful.
  ///
  /// Throws a [CoffeeApiRequestFailure] when the response has a non-200
  /// status code, or a [CoffeeApiMalformedResponse] when the body cannot
  /// be parsed or does not contain a valid `file` field.
  Future<String> getRandomCoffeeImageUrl() async {
    final uri = Uri.parse(_baseUrl);
    final response = await _httpClient.get(uri);

    if (response.statusCode != 200) {
      throw CoffeeApiRequestFailure(response.statusCode);
    }

    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException {
      throw const CoffeeApiMalformedResponse();
    }

    if (decoded is! Map<String, dynamic>) {
      throw const CoffeeApiMalformedResponse();
    }

    final file = decoded['file'];
    if (file is! String || file.isEmpty) {
      throw const CoffeeApiMalformedResponse();
    }

    return file;
  }
}
