import 'dart:convert';
import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.code, this.statusCode});
  final String message;
  final String? code;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({String? baseUrl})
    : baseUrl =
          baseUrl ??
          const String.fromEnvironment(
            'API_URL',
            defaultValue: 'http://192.168.1.5/starguess-admin/api/v1',
          );

  String baseUrl;
  String? token;

  void updateBaseUrl(String url) {
    baseUrl = url.trim().replaceAll(RegExp(r'/+$'), '');
  }

  Future<Map<String, dynamic>> get(String path) => request(path);

  Future<Map<String, dynamic>> post(
    String path, [
    Map<String, Object?> body = const {},
  ]) => request(path, method: 'POST', body: body);

  Future<Map<String, dynamic>> put(String path, Map<String, Object?> body) =>
      request(path, method: 'PUT', body: body);

  Future<Map<String, dynamic>> request(
    String path, {
    String method = 'GET',
    Map<String, Object?>? body,
  }) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 15);
    try {
      final endpoint = Uri.parse('$baseUrl$path');
      if (!endpoint.hasAuthority ||
          !const {'http', 'https'}.contains(endpoint.scheme)) {
        throw const ApiException('The StarGuess API address is invalid.');
      }
      if (!kDebugMode && endpoint.scheme != 'https') {
        throw const ApiException(
          'Secure HTTPS is required to connect to StarGuess.',
        );
      }
      final request = await client.openUrl(method, endpoint);
      request.followRedirects = false;
      request.headers.contentType = ContentType.json;
      request.headers.set(HttpHeaders.acceptHeader, 'application/json');
      if (token case final value?) {
        request.headers.set(HttpHeaders.authorizationHeader, 'Bearer $value');
      }
      if (body != null) request.write(jsonEncode(body));
      final response = await request.close().timeout(
        const Duration(seconds: 20),
      );
      final bytes = await response
          .fold<List<int>>(<int>[], (all, chunk) {
            if (all.length + chunk.length > 1024 * 1024) {
              throw const ApiException('The server response was too large.');
            }
            return all..addAll(chunk);
          })
          .timeout(const Duration(seconds: 20));
      final text = utf8.decode(bytes);
      Map<String, dynamic> payload;
      try {
        final decoded = jsonDecode(text);
        if (decoded is! Map<String, dynamic>) throw const FormatException();
        payload = decoded;
      } on FormatException {
        throw ApiException(
          'Server returned an invalid response.',
          statusCode: response.statusCode,
        );
      }
      if (response.statusCode < 200 ||
          response.statusCode >= 300 ||
          payload['success'] != true) {
        throw ApiException(
          (payload['message'] ?? payload['error'] ?? 'Request failed.')
              .toString(),
          code: payload['error_code']?.toString(),
          statusCode: response.statusCode,
        );
      }
      return payload;
    } on SocketException {
      throw const ApiException(
        'Cannot reach StarGuess. Check your connection and API address.',
      );
    } on HttpException {
      throw const ApiException(
        'The server connection was interrupted. Try again.',
      );
    } on IOException {
      throw const ApiException(
        'A secure connection to StarGuess could not be established.',
      );
    } on TimeoutException {
      throw const ApiException(
        'The server took too long to respond. Try again.',
      );
    } on FormatException {
      throw const ApiException('The server returned invalid text.');
    } finally {
      client.close(force: true);
    }
  }
}
