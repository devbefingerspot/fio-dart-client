/// Parameters for listing leave requests.
class ListLeaveParams {
  const ListLeaveParams({
    this.page = 1,
    this.pageSize = 20,
    this.startDate,
    this.endDate,
    this.status,
  });

  /// Page number (1-indexed). Default: 1.
  final int page;

  /// Items per page. Default: 20. Max: 100.
  final int pageSize;

  /// Filter: start date (inclusive), format: YYYY-MM-DD.
  final String? startDate;

  /// Filter: end date (inclusive), format: YYYY-MM-DD.
  final String? endDate;

  /// Filter by status.
  final String? status;

  Map<String, dynamic> toQueryParameters() {
    final map = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
    };
    if (startDate != null) map['start_date'] = startDate;
    if (endDate != null) map['end_date'] = endDate;
    if (status != null) map['status'] = status;
    return map;
  }
}
