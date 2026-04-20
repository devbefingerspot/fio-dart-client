/// Pagination metadata returned in paginated list responses.
class PaginationMeta {
  const PaginationMeta({
    required this.page,
    required this.pageSize,
    required this.total,
    required this.totalPage,
  });

  /// Current page number (1-indexed).
  final int page;

  /// Number of items per page.
  final int pageSize;

  /// Total number of items across all pages.
  final int total;

  /// Total number of pages.
  final int totalPage;

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      page: json['page'] as int,
      pageSize: json['page_size'] as int,
      total: json['total'] as int,
      totalPage: json['total_page'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'page': page,
        'page_size': pageSize,
        'total': total,
        'total_page': totalPage,
      };
}
