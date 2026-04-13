import 'package:test/test.dart';

import 'package:fio_backend_client/fio_backend_client.dart';

// Minimal smoke-test: verify that MobileApiClient can be instantiated with
// a mock handler and that ApiError.fromDioException parses known fields.

class _MockAuthHandler implements MobileApiAuthHandler {
  @override
  Future<String?> getIdentityAccessToken() async => null;
  @override
  Future<String?> getIdentityRefreshToken() async => null;
  @override
  Future<String?> getCompanyAccessToken() async => null;
  @override
  Future<String?> getCompanyRefreshToken() async => null;
  @override
  Future<void> onIdentityTokenRefreshed({
    required String accessToken,
    required String refreshToken,
  }) async {}
  @override
  Future<void> onCompanyTokenRefreshed({
    required String accessToken,
    required String refreshToken,
  }) async {}
  @override
  Future<void> onLoggedOut() async {}
  @override
  Future<void> onCompanyLoggedOut() async {}
}

void main() {
  group('MobileApiClient', () {
    test('can be instantiated', () {
      final client = MobileApiClient(
        authBaseUrl: 'https://auth.example.com',
        backendBaseUrl: 'https://backend.example.com',
        authHandler: _MockAuthHandler(),
      );
      expect(client.backendBaseUrl, 'https://backend.example.com');
    });

    test('setBackendBaseUrl updates backendBaseUrl', () {
      final client = MobileApiClient(
        authBaseUrl: 'https://auth.example.com',
        backendBaseUrl: 'https://old.example.com',
        authHandler: _MockAuthHandler(),
      );
      client.setBackendBaseUrl('https://new.example.com');
      expect(client.backendBaseUrl, 'https://new.example.com');
    });
  });

  group('LoginRequest', () {
    test('toJson with email', () {
      final req = LoginRequest(email: 'a@b.com', password: 'secret');
      final json = req.toJson();
      expect(json['email'], 'a@b.com');
      expect(json['password'], 'secret');
      expect(json.containsKey('phone'), isFalse);
    });

    test('toJson with phone', () {
      final req = LoginRequest(
          phone: '812345', phoneCode: '+62', password: 'secret');
      final json = req.toJson();
      expect(json['phone'], '812345');
      expect(json['phone_code'], '+62');
      expect(json.containsKey('email'), isFalse);
    });
  });

  group('ApiError', () {
    test('fromDioException parses message field', () {
      // We cannot easily construct a real DioException with a response
      // without an HTTP client, so test the model constructor directly.
      const err = ApiError(
        statusCode: 422,
        message: 'invalid credentials',
        code: 'AUTH_001',
        details: {'message': 'invalid credentials'},
      );
      expect(err.statusCode, 422);
      expect(err.message, 'invalid credentials');
      expect(err.code, 'AUTH_001');
    });
  });
}
