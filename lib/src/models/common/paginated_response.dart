import 'pagination_meta.dart';

/// Generic wrapper for paginated list responses.
///
/// Use the [fromJson] factory with a deserializer function for the data items:
/// ```dart
/// final response = PaginatedResponse<Employee>.fromJson(
///   json,
///   (item) => Employee.fromJson(item),
/// );
/// ```
class PaginatedResponse<T> {
  const PaginatedResponse({
    required this.data,
    required this.meta,
  });

  /// The list of items for the current page.
  final List<T> data;

  /// Pagination metadata.
  final PaginationMeta meta;

  /// Creates a [PaginatedResponse] from JSON.
  ///
  /// [fromJsonT] is a function that deserializes each item in the `data` array.
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final dataList = (json['data'] as List<dynamic>?) ?? [];
    return PaginatedResponse(
      data: dataList
          .cast<Map<String, dynamic>>()
          .map((item) => fromJsonT(item))
          .toList(),
      meta: PaginationMeta.fromJson(json['meta'] as Map<String, dynamic>),
    );
  }

  /// Whether there are more pages after the current one.
  bool get hasNextPage => meta.page < meta.totalPage;

  /// Whether there are pages before the current one.
  bool get hasPreviousPage => meta.page > 1;

  /// Whether the response is empty.
  bool get isEmpty => data.isEmpty;

  /// Whether the response has items.
  bool get isNotEmpty => data.isNotEmpty;
}
