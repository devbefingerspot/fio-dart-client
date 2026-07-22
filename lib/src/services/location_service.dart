import 'package:dio/dio.dart';

import '../models/api_error.dart';
import '../models/common/paginated_response.dart';
import '../models/location/batch_ping_request.dart';
import '../models/location/geofence.dart';
import '../models/location/list_sessions_params.dart';
import '../models/location/location_ping.dart';
import '../models/location/location_session.dart';
import '../models/location/query_history_params.dart';
import '../models/location/session_detail_response.dart';
import '../models/location/start_session_request.dart';
import '../models/location/submit_ping_request.dart';
import '../models/location/update_session_request.dart';

/// Provides location monitoring operations against the mobile backend.
///
/// Supports real-time GPS ping submission, batch uploads, trip/periodic
/// session management, geofence event detection, and paginated history queries.
///
/// Obtain this via [MobileApiClient.location].
class LocationService {
  LocationService({required Dio backendDio}) : _backendDio = backendDio;

  final Dio _backendDio;

  /// POST /mobile/v1/location/ping
  ///
  /// Submits a single real-time GPS ping. Automatically detects geofence
  /// boundary crossings (enter/exit) and returns generated events.
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<SubmitPingResponse> submitPing(SubmitPingRequest request) async {
    try {
      final response = await _backendDio.post<Map<String, dynamic>>(
        '/mobile/v1/location/ping',
        data: request.toJson(),
      );
      return SubmitPingResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// POST /mobile/v1/location/batch
  ///
  /// Submits a batch of buffered location pings (max 500).
  /// Geofence detection is performed per ping.
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<SubmitBatchResponse> submitBatch(SubmitBatchRequest request) async {
    try {
      final response = await _backendDio.post<Map<String, dynamic>>(
        '/mobile/v1/location/batch',
        data: request.toJson(),
      );
      return SubmitBatchResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// POST /mobile/v1/location/sessions
  ///
  /// Starts a new location tracking session.
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<LocationSession> startSession(StartSessionRequest request) async {
    try {
      final response = await _backendDio.post<Map<String, dynamic>>(
        '/mobile/v1/location/sessions',
        data: request.toJson(),
      );
      return LocationSession.fromJson(response.data!['session'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// PUT /mobile/v1/location/sessions/:id
  ///
  /// Pauses or completes an active session.
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<LocationSession> updateSession(
    String id,
    UpdateSessionRequest request,
  ) async {
    try {
      final response = await _backendDio.put<Map<String, dynamic>>(
        '/mobile/v1/location/sessions/$id',
        data: request.toJson(),
      );
      return LocationSession.fromJson(response.data!['session'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// GET /mobile/v1/location/sessions
  ///
  /// Returns a paginated list of location sessions.
  /// Self: own sessions. Owner/manager: own + subordinates.
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<PaginatedResponse<LocationSession>> listSessions([
    ListSessionsParams? params,
  ]) async {
    try {
      final query = params?.toQueryParameters() ?? {};
      final response = await _backendDio.get<Map<String, dynamic>>(
        '/mobile/v1/location/sessions',
        queryParameters: query,
      );
      return PaginatedResponse.fromJson(
        response.data!,
        (json) => LocationSession.fromJson(json),
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// GET /mobile/v1/location/sessions/:id
  ///
  /// Returns a session with its paginated pings sorted by time.
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<SessionDetailResponse> getSessionDetail(
    String id, {
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final response = await _backendDio.get<Map<String, dynamic>>(
        '/mobile/v1/location/sessions/$id',
        queryParameters: {'page': page, 'page_size': pageSize},
      );
      return SessionDetailResponse.fromJson(response.data!);
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// GET /mobile/v1/location/history
  ///
  /// Returns a paginated list of location pings across date range.
  /// Self: own data. Owner/manager: own + subordinates.
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<PaginatedResponse<LocationPing>> queryHistory([
    QueryHistoryParams? params,
  ]) async {
    try {
      final query = params?.toQueryParameters() ?? {};
      final response = await _backendDio.get<Map<String, dynamic>>(
        '/mobile/v1/location/history',
        queryParameters: query,
      );
      return PaginatedResponse.fromJson(
        response.data!,
        (json) => LocationPing.fromJson(json),
      );
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }

  /// GET /mobile/v1/location/geofences
  ///
  /// Returns all active geofence zones for the company.
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<List<Geofence>> listGeofences() async {
    try {
      final response = await _backendDio.get<Map<String, dynamic>>(
        '/mobile/v1/location/geofences',
      );
      final list = response.data!['geofences'] as List<dynamic>;
      return list
          .map((e) => Geofence.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
