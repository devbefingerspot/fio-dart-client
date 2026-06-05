import 'package:dio/dio.dart';

import '../models/common/office.dart';

/// Service for office-related mobile endpoints.
class OfficeService {
  const OfficeService({required Dio backendDio}) : _backendDio = backendDio;

  final Dio _backendDio;

  /// Returns the list of offices the current user has access to.
  ///
  /// - **owner / subadmin / admin**: all offices in the company.
  /// - **employee**: only the office linked to the employee's employment
  ///   (empty list if not assigned to any office).
  ///
  /// Throws [DioException] on network or server errors.
  Future<List<Office>> getMyOffices() async {
    final response = await _backendDio.get('/mobile/v1/offices');
    final list = response.data as List<dynamic>;
    return list
        .map((e) => Office.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
