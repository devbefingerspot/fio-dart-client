import 'package:dio/dio.dart';

/// Typed error thrown by every service method in [MobileApiClient].
///
/// - [statusCode] — HTTP status from the response, or `null` for network errors.
/// - [message]    — Human-readable message parsed from the response body
///                  (`message` or `error` field), falling back to
///                  `"Request failed"` if the body is absent or unrecognised.
/// - [code]       — Optional application-level error code from the `code` field.
/// - [details]    — Raw response body (preserved as-is for custom handling).
/// - [cause]      — The original [DioException]; always present.
class ApiError implements Exception {
  const ApiError({
    this.statusCode,
    required this.message,
    this.code,
    this.details,
    this.cause,
  });

  final int? statusCode;
  final String message;
  final String? code;
  final Object? details;
  final Object? cause;

  /// Constructs an [ApiError] from a [DioException].
  ///
  /// Tries to parse the response body as a JSON object and reads known fields:
  /// `message`, `error`, `code`. Falls back to `"Request failed"` when the
  /// body is absent or has an unrecognised shape.
  factory ApiError.fromDioException(DioException e) {
    final response = e.response;
    final statusCode = response?.statusCode;
    final body = response?.data;

    String message = 'Request failed';
    String? code;

    if (body is Map) {
      final raw = body;
      final msg = raw['message'] ?? raw['error'];
      if (msg is String && msg.isNotEmpty) {
        message = msg;
      }
      final c = raw['code'];
      if (c != null) {
        code = c.toString();
      }
    }

    return ApiError(
      statusCode: statusCode,
      message: message,
      code: code,
      details: body,
      cause: e,
    );
  }

  @override
  String toString() {
    final parts = <String>['ApiError($message'];
    if (statusCode != null) parts.add(', status=$statusCode');
    if (code != null) parts.add(', code=$code');
    parts.add(')');
    return parts.join();
  }
}
