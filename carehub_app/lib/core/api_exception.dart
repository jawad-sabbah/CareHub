/// Thrown whenever the backend responds with success: false,
/// or the request fails before a response is even received
/// (no internet, server down, CORS block, timeout).
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}