import 'package:dio/dio.dart';

import '../models/api_error.dart';
import '../models/feature/employee_feature.dart';

/// Service for the authenticated employee's payment feature grants.
///
/// Obtain this via [MobileApiClient.features].
class FeatureService {
  const FeatureService({required Dio backendDio}) : _backendDio = backendDio;

  final Dio _backendDio;

  /// GET /mobile/v1/my-features
  ///
  /// Returns the list of payment features granted to the authenticated
  /// employee. Flag features are company-level grants; seat/usage features
  /// reflect the employee's active assignments.
  ///
  /// Throws [ApiError] on any non-2xx response.
  Future<List<EmployeeFeature>> getMyFeatures() async {
    try {
      final response = await _backendDio.get<Map<String, dynamic>>(
        '/mobile/v1/my-features',
      );
      final list = response.data!['features'] as List<dynamic>? ?? const [];
      return list
          .map((e) => EmployeeFeature.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiError.fromDioException(e);
    }
  }
}
