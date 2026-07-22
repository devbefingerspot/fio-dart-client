import 'package:dio/dio.dart';

import '../models/api_error.dart';
import '../models/device/create_device_change_request_request.dart';
import '../models/device/create_device_change_request_response.dart';
import '../models/device/my_device.dart';

/// Provides device management operations against the auth-service.
///
/// Uses the identity access token (no company context required).
/// Obtain this via [MobileApiClient.devices].
class DeviceService {
  DeviceService({
    required Dio identityDio,
    required String authBaseUrl,
  })  : _identityDio = identityDio,
        _authBaseUrl = authBaseUrl;

  final Dio _identityDio;
  final String _authBaseUrl;

  /// GET /api/v1/user/my-devices
  ///
  /// Returns all registered mobile devices for the authenticated user.
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<List<MyDevice>> getMyDevices() async {
    try {
      final response = await _identityDio.get<Map<String, dynamic>>(
        '$_authBaseUrl/api/v1/user/my-devices',
      );
      final list = response.data?['devices'] as List<dynamic>? ?? [];
      return list
          .cast<Map<String, dynamic>>()
          .map(MyDevice.fromJson)
          .toList();
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// POST /api/v1/device-change-request
  ///
  /// Submits a request to change a mobile device. The user specifies which
  /// old device to replace and provides the new device details. The request
  /// must be approved by an admin before the device swap is executed.
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<CreateDeviceChangeRequestResponse> createDeviceChangeRequest(
    CreateDeviceChangeRequestRequest request,
  ) async {
    try {
      final response = await _identityDio.post<Map<String, dynamic>>(
        '$_authBaseUrl/api/v1/device-change-request',
        data: request.toJson(),
      );
      return CreateDeviceChangeRequestResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
