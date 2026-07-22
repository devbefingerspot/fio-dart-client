/// Parameters for querying location ping history.
class QueryHistoryParams {
  const QueryHistoryParams({
    this.page = 1,
    this.pageSize = 20,
    this.startDate,
    this.endDate,
    this.employeeId,
  });

  final int page;
  final int pageSize;
  final String? startDate;
  final String? endDate;
  final String? employeeId;

  Map<String, dynamic> toQueryParameters() {
    final map = <String, dynamic>{
      'page': page,
      'page_size': pageSize,
    };
    if (startDate != null) map['start_date'] = startDate;
    if (endDate != null) map['end_date'] = endDate;
    if (employeeId != null) map['employee_id'] = employeeId;
    return map;
  }
}
