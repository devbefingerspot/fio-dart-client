import 'package:dio/dio.dart';

import '../models/api_error.dart';
import '../models/attendance/attendance_log.dart';
import '../models/attendance/gps_settings_response.dart';
import '../models/attendance/submit_gps_attendance_request.dart';
import '../models/attendance/submit_gps_attendance_response.dart';

/// Provides GPS attendance operations against the mobile backend.
///
/// Obtain this via [MobileApiClient.gpsAttendance].
class GpsAttendanceService {
  GpsAttendanceService({
    required Dio backendDio,
  }) : _backendDio = backendDio;

  final Dio _backendDio;

  /// GET /mobile/v1/gps-attendance/settings
  ///
  /// Returns evidence upload requirement flags for the company.
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<GpsSettingsResponse> getSettings() async {
    try {
      final response = await _backendDio.get<Map<String, dynamic>>(
        '/mobile/v1/gps-attendance/settings',
      );
      return GpsSettingsResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// POST /mobile/v1/gps-attendance
  ///
  /// Submits GPS attendance. Returns an upload token (valid 30 min) for
  /// evidence upload via [uploadEvidence].
  ///
  /// For production, include integrity verification:
  /// - Android: Set [SubmitGpsAttendanceRequest.integrityPlatform] to `android`,
  ///   [integrityToken] to the Play Integrity token, and [integrityChallenge]
  ///   to the nonce from [IntegrityService.getChallenge].
  /// - iOS: Set [integrityPlatform] to `ios`, [integrityToken] to the
  ///   generateAssertion() result, and [integrityKeyId] to your key ID.
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<SubmitGpsAttendanceResponse> submit(
    SubmitGpsAttendanceRequest request,
  ) async {
    try {
      final response = await _backendDio.post<Map<String, dynamic>>(
        '/mobile/v1/gps-attendance',
        data: request.toJson(),
      );
      return SubmitGpsAttendanceResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// POST /mobile/v1/gps-attendance/{id}/evidence
  ///
  /// Uploads evidence (photos, attachments) for an attendance log.
  /// Must be called within 30 minutes of the attendance submission.
  ///
  /// [attendanceLogId] The ID of the attendance log.
  /// [uploadToken] The upload token from [submit].
  /// [frontPhoto] Front (selfie) photo file bytes with filename.
  /// [backPhotos] Optional list of back photos.
  /// [attachments] Optional list of attachment files.
  /// [note] Optional note.
  /// [onSendProgress] Optional callback for upload progress.
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<AttendanceLogMetadata> uploadEvidence({
    required String attendanceLogId,
    required String uploadToken,
    MultipartFile? frontPhoto,
    List<MultipartFile>? backPhotos,
    List<MultipartFile>? attachments,
    String? note,
    void Function(int, int)? onSendProgress,
  }) async {
    try {
      final formData = FormData();

      if (frontPhoto != null) {
        formData.files.add(MapEntry('front_photo', frontPhoto));
      }

      if (backPhotos != null) {
        for (final photo in backPhotos) {
          formData.files.add(MapEntry('back_photos', photo));
        }
      }

      if (attachments != null) {
        for (final file in attachments) {
          formData.files.add(MapEntry('attachments', file));
        }
      }

      if (note != null) {
        formData.fields.add(MapEntry('note', note));
      }

      final response = await _backendDio.post<Map<String, dynamic>>(
        '/mobile/v1/gps-attendance/$attendanceLogId/evidence',
        data: formData,
        options: Options(
          headers: {'X-Upload-Token': uploadToken},
        ),
        onSendProgress: onSendProgress,
      );

      return AttendanceLogMetadata.fromJson(
        response.data!['metadata'] as Map<String, dynamic>,
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
