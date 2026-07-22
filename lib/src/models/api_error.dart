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
/// - [integrityDiagnostics] — Structured diagnostics when an integrity check
///                  fails (HTTP 403). Helps distinguish a legitimate device
///                  issue (rooted, sideloaded APK) from a server
///                  misconfiguration (API not enabled). `null` for non-
///                  integrity errors.
class ApiError implements Exception {
  const ApiError({
    this.statusCode,
    required this.message,
    this.code,
    this.details,
    this.cause,
    this.integrityDiagnostics,
  });

  final int? statusCode;
  final String message;
  final String? code;
  final Object? details;
  final Object? cause;
  final IntegrityErrorDiagnostics? integrityDiagnostics;

  /// Constructs an [ApiError] from a [DioException].
  ///
  /// Tries to parse the response body as a JSON object and reads known fields:
  /// `message`, `error`, `code`. Falls back to `"Request failed"` when the
  /// body is absent or has an unrecognised shape.
  ///
  /// Also parses the optional `diagnostics` field for integrity-check failures.
  factory ApiError.fromDioException(DioException e) {
    final response = e.response;
    final statusCode = response?.statusCode;
    final body = response?.data;

    String message = 'Request failed';
    String? code;
    IntegrityErrorDiagnostics? diagnostics;

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
      // Parse integrity diagnostics if present.
      final diag = raw['diagnostics'];
      if (diag is Map<String, dynamic>) {
        diagnostics = IntegrityErrorDiagnostics.fromJson(diag);
      }
    }

    return ApiError(
      statusCode: statusCode,
      message: message,
      code: code,
      details: body,
      cause: e,
      integrityDiagnostics: diagnostics,
    );
  }

  /// Human-readable diagnostic summary suitable for logging / debug UI.
  String get integrityDebugSummary {
    final d = integrityDiagnostics;
    if (d == null) return '';
    final buf = StringBuffer('Integrity failure (${d.platform}):');
    if (d.android != null) {
      buf.write(' app=${d.android!.appRecognitionVerdict}');
      buf.write(' device=${d.android!.deviceRecognitionVerdict}');
      buf.write(' license=${d.android!.appLicensingVerdict}');
      buf.write(' failures=${d.android!.failureReasons}');
    }
    if (d.ios != null) {
      buf.write(' failureDetail=${d.ios!.failureDetail}');
    }
    return buf.toString();
  }

  @override
  String toString() {
    final parts = <String>['ApiError($message'];
    if (statusCode != null) parts.add(', status=$statusCode');
    if (code != null) parts.add(', code=$code');
    if (integrityDiagnostics != null) {
      parts.add(', integrity=${integrityDiagnostics!.platform}');
    }
    parts.add(')');
    return parts.join();
  }
}

/// Structured diagnostics returned by the backend when a device-integrity
/// check fails (HTTP 403 on POST /mobile/v1/gps-attendance).
///
/// Use this to:
/// - Log exactly which check failed.
/// - Show user-facing messages: e.g., "device_integrity_missing" means root,
///   while "app_not_recognized:UNRECOGNIZED_VERSION" means debug build.
/// - Distinguish client-side failures (rooted device, sideloaded APK) from
///   server misconfiguration (API not enabled, OAuth2 misconfigured).
class IntegrityErrorDiagnostics {
  const IntegrityErrorDiagnostics({
    required this.platform,
    this.android,
    this.ios,
  });

  /// Always "android" or "ios".
  final String platform;

  /// Populated for Android Play Integrity failures.
  final AndroidDiagnostics? android;

  /// Populated for iOS App Attest assertion failures.
  final IOSDiagnostics? ios;

  factory IntegrityErrorDiagnostics.fromJson(Map<String, dynamic> json) {
    return IntegrityErrorDiagnostics(
      platform: json['platform'] as String? ?? 'unknown',
      android: json['android'] is Map
          ? AndroidDiagnostics.fromJson(json['android'] as Map<String, dynamic>)
          : null,
      ios: json['ios'] is Map
          ? IOSDiagnostics.fromJson(json['ios'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Individual Play Integrity verdict sub-fields and failure reasons.
class AndroidDiagnostics {
  const AndroidDiagnostics({
    required this.appRecognitionVerdict,
    required this.deviceRecognitionVerdict,
    required this.appLicensingVerdict,
    required this.failureReasons,
  });

  /// PLAY_RECOGNIZED, UNRECOGNIZED_VERSION, UNEVALUATED, or "" if not
  /// present in the verdict.
  final String appRecognitionVerdict;

  /// List of device labels, e.g. ["MEETS_BASIC_INTEGRITY"] or [].
  final List<String> deviceRecognitionVerdict;

  /// LICENSED, UNLICENSED, UNEVALUATED, or "" if not present.
  final String appLicensingVerdict;

  /// Why the verdict was rejected, e.g.:
  /// - "device_integrity_missing"  → device failed integrity (rooted?)
  /// - "device_verdict_empty"      → no device verdict at all (emulator?)
  /// - "app_not_recognized:UNRECOGNIZED_VERSION" → debug build / unknown cert
  final List<String> failureReasons;

  factory AndroidDiagnostics.fromJson(Map<String, dynamic> json) {
    return AndroidDiagnostics(
      appRecognitionVerdict: json['app_recognition_verdict'] as String? ?? '',
      deviceRecognitionVerdict: (json['device_recognition_verdict'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      appLicensingVerdict: json['app_licensing_verdict'] as String? ?? '',
      failureReasons: (json['failure_reasons'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

/// App Attest assertion verification details.
class IOSDiagnostics {
  const IOSDiagnostics({
    this.signCountReceived,
    this.signCountExpected,
    this.failureStep,
    this.failureDetail,
  });

  final int? signCountReceived;
  final int? signCountExpected;
  final String? failureStep;
  final String? failureDetail;

  factory IOSDiagnostics.fromJson(Map<String, dynamic> json) {
    return IOSDiagnostics(
      signCountReceived: json['sign_count_received'] as int?,
      signCountExpected: json['sign_count_expected'] as int?,
      failureStep: json['failure_step'] as String?,
      failureDetail: json['failure_detail'] as String?,
    );
  }
}
