/// Parameters for listing employees.
class ListEmployeesParams {
  const ListEmployeesParams({
    this.page = 1,
    this.pageSize = 20,
    this.search,
  });

  /// Page number (1-indexed). Default: 1.
  final int page;

  /// Items per page. Default: 20. Max: 100.
  final int pageSize;

  /// Search term. Filters by full_name, custom_id, or nip (LIKE match).
  final String? search;

  Map<String, dynamic> toQueryParameters() {
    final map = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
    };
    if (search != null && search!.isNotEmpty) map['search'] = search;
    return map;
  }
}
