import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:test/test.dart';

import 'package:fio_backend_client/fio_backend_client.dart';
import 'package:fio_backend_client/src/interceptor/refresh_lock.dart';
import 'package:fio_backend_client/src/interceptor/token_refresh_interceptor.dart';

/// HTTP adapter stub so tests never touch the network.
class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.onFetch);

  final Future<ResponseBody> Function(RequestOptions options) onFetch;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) =>
      onFetch(options);

  @override
  void close({bool force = false}) {}
}

ResponseBody _json(int status, Map<String, dynamic> body) {
  return ResponseBody.fromString(
    jsonEncode(body),
    status,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

Future<ResponseBody> _transportError(RequestOptions options) async {
  throw DioException.connectionError(
    requestOptions: options,
    reason: 'no route to host',
  );
}

class _Harness {
  _Harness({
    required Future<ResponseBody> Function(RequestOptions) refresh,
    String? refreshToken = 'refresh-1',
    Future<ResponseBody> Function(RequestOptions)? backend,
  }) {
    final plain = Dio();
    plain.httpClientAdapter = _StubAdapter((options) {
      if (options.path.contains('/auth/refresh')) {
        return refresh(options);
      }
      return _backend(options);
    });

    interceptor = TokenRefreshInterceptor(
      authBaseUrl: 'https://auth.test',
      getAccessToken: () async => 'expired-access',
      getRefreshToken: () async => refreshToken,
      onTokenRefreshed: ({required accessToken, required refreshToken}) async {
        refreshedAccessToken = accessToken;
      },
      onLoggedOut: () async {
        logoutCalls++;
      },
      lock: TokenRefreshLock(),
      plainDio: plain,
    );

    _backend = backend ?? (_) async => _json(401, {'error': 'unauthorized'});
  }

  late final TokenRefreshInterceptor interceptor;
  late final Future<ResponseBody> Function(RequestOptions) _backend;

  int logoutCalls = 0;
  String? refreshedAccessToken;

  Future<Response<dynamic>> request() {
    final dio = Dio(BaseOptions(baseUrl: 'https://api.test'));
    dio.httpClientAdapter = _StubAdapter(_backend);
    dio.interceptors.add(interceptor);
    return dio.get<dynamic>('/mobile/v1/gps-attendance');
  }

  /// Returns the [DioException] the caller sees.
  Future<DioException> failedRequest() async {
    try {
      await request();
    } on DioException catch (e) {
      return e;
    }
    fail('expected the request to fail');
  }
}

ApiError _apiError(DioException e) => e.error as ApiError;

void main() {
  group('TokenRefreshInterceptor — refresh failures', () {
    test('transport error keeps the session and is retryable', () async {
      final h = _Harness(refresh: _transportError);

      final err = await h.failedRequest();

      expect(h.logoutCalls, 0,
          reason: 'a network blip must not destroy the session');
      expect(_apiError(err).statusCode, isNull);
      expect(_apiError(err).message, contains('Token refresh unavailable'));
    });

    test('auth service 5xx keeps the session and is retryable', () async {
      final h = _Harness(
        refresh: (_) async => _json(503, {'error': 'unavailable'}),
      );

      final err = await h.failedRequest();

      expect(h.logoutCalls, 0);
      expect(_apiError(err).statusCode, 503);
    });

    test('refresh 401 logs out', () async {
      final h = _Harness(
        refresh: (_) async => _json(401, {'error': 'invalid refresh token'}),
      );

      final err = await h.failedRequest();

      expect(h.logoutCalls, 1);
      expect(_apiError(err).statusCode, 401);
    });

    test('refresh 403 logs out', () async {
      final h = _Harness(
        refresh: (_) async => _json(403, {'error': 'forbidden'}),
      );

      await h.failedRequest();

      expect(h.logoutCalls, 1);
    });

    test('missing refresh token logs out', () async {
      final h = _Harness(
        refresh: (_) async => _json(200, {}),
        refreshToken: null,
      );

      final err = await h.failedRequest();

      expect(h.logoutCalls, 1);
      expect(_apiError(err).statusCode, 401,
          reason: 'a missing refresh token is terminal, not retryable');
    });
  });

  group('TokenRefreshInterceptor — success path', () {
    test('refreshes once and retries the original request', () async {
      var backendCalls = 0;
      final h = _Harness(
        refresh: (_) async => _json(200, {
          'access_token': 'new-access',
          'access_token_expires_at': 1792655200,
          'refresh_token': 'new-refresh',
          'refresh_token_expires_at': 1797839200,
          'token_type': 'Bearer',
        }),
        backend: (_) async {
          backendCalls++;
          if (backendCalls == 1) return _json(401, {'error': 'unauthorized'});
          return _json(200, {'ok': true});
        },
      );

      final response = await h.request();

      expect(response.statusCode, 200);
      expect(backendCalls, 2);
      expect(h.logoutCalls, 0);
      expect(h.refreshedAccessToken, 'new-access');
    });
  });
}
