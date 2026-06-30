import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_exception.dart';

class ApiClient {
  static const String baseUrl = 'http://localhost:3000/api';

  static String? _token;

  static void setToken(String? token) => _token = token;
  static String? get token => _token;

  static Map<String, String> _headers({bool withAuth = false}) {
    final headers = {'Content-Type': 'application/json'};
    if (withAuth && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  static Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body, {
    bool withAuth = false,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    http.Response response;
    try {
      response = await http
          .post(uri, headers: _headers(withAuth: withAuth), body: jsonEncode(body))
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      throw ApiException('Could not reach the server. Check your connection.');
    }
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> get(
    String path, {
    bool withAuth = true,
    Map<String, String>? queryParams,
  }) async {
    var uri = Uri.parse('$baseUrl$path');
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }

    http.Response response;
    try {
      response = await http
          .get(uri, headers: _headers(withAuth: withAuth))
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      throw ApiException('Could not reach the server. Check your connection.');
    }
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body, {
    bool withAuth = true,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    http.Response response;
    try {
      response = await http
          .put(uri, headers: _headers(withAuth: withAuth), body: jsonEncode(body))
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      throw ApiException('Could not reach the server. Check your connection.');
    }
    return _handleResponse(response);
  }

  static Future<Map<String, dynamic>> delete(
    String path, {
    bool withAuth = true,
  }) async {
    final uri = Uri.parse('$baseUrl$path');
    http.Response response;
    try {
      response = await http
          .delete(uri, headers: _headers(withAuth: withAuth))
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      throw ApiException('Could not reach the server. Check your connection.');
    }
    return _handleResponse(response);
  }

  static Map<String, dynamic> _handleResponse(http.Response response) {
    Map<String, dynamic> json;
    try {
      json = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException(
        'Unexpected server response (status ${response.statusCode}).',
        statusCode: response.statusCode,
      );
    }

    if (json['success'] != true) {
      throw ApiException(
        json['message'] as String? ?? 'Something went wrong.',
        statusCode: response.statusCode,
      );
    }

    return json;
  }
}