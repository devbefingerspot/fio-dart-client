import 'package:dio/dio.dart';

import '../models/common/office.dart';

/// Service for office-related mobile endpoints.
class OfficeService {
  const OfficeService({required Dio backendDio}) : _backendDio = backendDio;

  final Dio _backendDio;

  /// Returns the list of offices the current user has access to.
  ///
  /// - **owner**: all offices in the company (works even when the owner account
  ///   is not linked to an employee record).
  /// - **employee**: only the office linked to the employee's employment
  ///   (empty list if not assigned to any office).
  ///
  /// `subadmin` / `admin` cannot obtain a mobile token, so those branches do not
  /// apply to this client.
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
