import 'package:dio/dio.dart';

import '../models/api_error.dart';
import '../models/integrity/integrity_challenge_response.dart';
import '../models/integrity/ios_attest_request.dart';
import '../models/integrity/ios_attest_response.dart';

/// Provides device integrity operations against the mobile backend.
///
/// Obtain this via [MobileApiClient.integrity].
class IntegrityService {
  IntegrityService({
    required Dio backendDio,
  }) : _backendDio = backendDio;

  final Dio _backendDio;

  /// GET /mobile/v1/integrity/challenge
  ///
  /// Issues a 32-byte hex nonce (TTL 60s) for device attestation.
  /// Android: Pass as requestHash to StandardIntegrityManager.
  /// iOS: Pass as nonce to DCAppAttestService.
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<IntegrityChallengeResponse> getChallenge() async {
    try {
      final response = await _backendDio.get<Map<String, dynamic>>(
        '/mobile/v1/integrity/challenge',
      );
      return IntegrityChallengeResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// POST /mobile/v1/ios/attest
  ///
  /// One-time iOS App Attest key registration per app installation.
  /// Idempotent — re-attesting an active key returns 200.
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<IosAttestResponse> registerIosKey(IosAttestRequest request) async {
    try {
      final response = await _backendDio.post<Map<String, dynamic>>(
        '/mobile/v1/ios/attest',
        data: request.toJson(),
      );
      return IosAttestResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
