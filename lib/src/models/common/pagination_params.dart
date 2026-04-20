/// Base pagination parameters for list endpoints.
class PaginationParams {
  const PaginationParams({
    this.page = 1,
    this.pageSize = 20,
  });

  /// Page number to retrieve (1-indexed). Default: 1.
  final int page;

  /// Number of items per page. Default: 20. Max: 100.
  final int pageSize;

  /// Converts to query parameters map.
  Map<String, dynamic> toQueryParameters() => {
        'page': page,
        'page_size': pageSize,
      };
}
