import 'package:dio/dio.dart';

import '../models/api_error.dart';
import '../models/auth/refresh_token_response.dart';
import 'refresh_lock.dart';

/// Dio interceptor that:
/// 1. Attaches `Authorization: Bearer <token>` to every request.
/// 2. On HTTP 401, performs a **single-flight** token refresh (via
///    [TokenRefreshLock]) and retries the original request exactly once.
/// 3. On any non-2xx response (including unrecoverable 401), throws an
///    [ApiError] that wraps the original [DioException].
///
/// Construct one instance per token domain (identity vs. company).
///
/// For company token interceptors, set [companyId] to enable per-company
/// token storage and refresh.
class TokenRefreshInterceptor extends Interceptor {
  TokenRefreshInterceptor({
    required this.authBaseUrl,
    required this.getAccessToken,
    required this.getRefreshToken,
    required this.onTokenRefreshed,
    required this.onLoggedOut,
    required this.lock,
    required this.plainDio,
    this.companyId,
  });

  final String authBaseUrl;

  /// For identity tokens: `() => getIdentityAccessToken()`
  /// For company tokens: `() => getCompanyAccessToken(companyId)`
  final Future<String?> Function() getAccessToken;

  /// For identity tokens: `() => getIdentityRefreshToken()`
  /// For company tokens: `() => getCompanyRefreshToken(companyId)`
  final Future<String?> Function() getRefreshToken;

  /// For identity tokens: `({accessToken, refreshToken}) => onIdentityTokenRefreshed(...)`
  /// For company tokens: `({accessToken, refreshToken}) => onCompanyTokenRefreshed(companyId: ..., ...)`
  final Future<void> Function({
    required String accessToken,
    required String refreshToken,
  }) onTokenRefreshed;

  /// For identity tokens: `onLoggedOut`
  /// For company tokens: `() => onCompanyLoggedOut(companyId)`
  final Future<void> Function() onLoggedOut;

  final TokenRefreshLock lock;

  /// A plain Dio instance (no interceptors) used exclusively for the refresh
  /// POST call, preventing infinite interceptor loops.
  final Dio plainDio;

  /// The company ID for company-scoped interceptors. `null` for identity interceptors.
  final String? companyId;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    final status = err.response?.statusCode;

    // ── Pass through non-401 errors (wrapped as ApiError) ──────────────────
    if (status != 401) {
      return handler.reject(_wrapAsApiError(err));
    }

    // ── Irrecoverable 401: the refresh endpoint itself returned 401 ─────────
    if (options.path.contains('/auth/refresh') ||
        options.uri.path.contains('/auth/refresh')) {
      await onLoggedOut();
      return handler.reject(_wrapAsApiError(err));
    }

    // ── Already retried — give up ────────────────────────────────────────────
    if (options.extra['_retry'] == true) {
      await onLoggedOut();
      return handler.reject(_wrapAsApiError(err));
    }

    // ── Explicit skip (e.g. logout call) ────────────────────────────────────
    if (options.extra['skipAuthRetry'] == true) {
      return handler.reject(_wrapAsApiError(err));
    }

    // ── Single-flight refresh ────────────────────────────────────────────────
    try {
      final newAccessToken = await lock.run(() async {
        final refreshToken = await getRefreshToken();
        if (refreshToken == null) throw ApiError(message: 'No refresh token');

        final response = await plainDio.post<Map<String, dynamic>>(
          '$authBaseUrl/api/v1/auth/refresh',
          data: {'refresh_token': refreshToken},
        );

        final refreshed = RefreshTokenResponse.fromJson(
          response.data!,
        );

        await onTokenRefreshed(
          accessToken: refreshed.accessToken,
          refreshToken: refreshed.refreshToken,
        );

        return refreshed.accessToken;
      });

      // Retry the original request with the new token.
      options.headers['Authorization'] = 'Bearer $newAccessToken';
      options.extra['_retry'] = true;

      final retryResponse = await plainDio.fetch<dynamic>(options);
      return handler.resolve(retryResponse);
    } on DioException catch (e) {
      await onLoggedOut();
      return handler.reject(_wrapAsApiError(e));
    } on ApiError {
      await onLoggedOut();
      return handler.reject(
        DioException(
          requestOptions: options,
          error: err.error,
          message: 'Token refresh failed',
        ),
      );
    } catch (_) {
      await onLoggedOut();
      return handler.reject(_wrapAsApiError(err));
    }
  }

  /// Wraps a [DioException] in an [ApiError] and re-packages it as a
  /// [DioException] whose [DioException.error] is the [ApiError].
  ///
  /// This preserves full fidelity: callers can catch [DioException] and
  /// inspect `.error as ApiError`, or catch [ApiError] directly.
  DioException _wrapAsApiError(DioException e) {
    final apiError = ApiError.fromDioException(e);
    return DioException(
      requestOptions: e.requestOptions,
      response: e.response,
      type: e.type,
      error: apiError,
      message: apiError.message,
      stackTrace: e.stackTrace,
    );
  }
}
