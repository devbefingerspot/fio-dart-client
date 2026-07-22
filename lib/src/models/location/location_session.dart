/// Type of location tracking session.
enum LocationSessionType {
  periodic('periodic'),
  trip('trip');

  const LocationSessionType(this.value);

  final String value;
}

/// Lifecycle status of a location tracking session.
enum LocationSessionStatus {
  active('active'),
  paused('paused'),
  completed('completed');

  const LocationSessionStatus(this.value);

  final String value;
}

/// A location tracking session that groups related pings.
class LocationSession {
  const LocationSession({
    required this.id,
    required this.companyId,
    required this.employeeId,
    required this.sessionType,
    required this.status,
    this.purpose,
    required this.startedAt,
    this.endedAt,
    this.totalDistance,
    this.totalDuration,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String companyId;
  final String employeeId;
  final LocationSessionType sessionType;
  final LocationSessionStatus status;
  final String? purpose;
  final DateTime startedAt;
  final DateTime? endedAt;
  final double? totalDistance;
  final int? totalDuration;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory LocationSession.fromJson(Map<String, dynamic> json) {
    return LocationSession(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      employeeId: json['employee_id'] as String,
      sessionType: LocationSessionType.values.firstWhere(
        (e) => e.value == json['session_type'],
      ),
      status: LocationSessionStatus.values.firstWhere(
        (e) => e.value == json['status'],
      ),
      purpose: json['purpose'] as String?,
      startedAt: DateTime.parse(json['started_at'] as String),
      endedAt: json['ended_at'] != null ? DateTime.parse(json['ended_at'] as String) : null,
      totalDistance: (json['total_distance'] as num?)?.toDouble(),
      totalDuration: json['total_duration'] as int?,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'employee_id': employeeId,
      'session_type': sessionType.value,
      'status': status.value,
      if (purpose != null) 'purpose': purpose,
      'started_at': startedAt.toIso8601String(),
      if (endedAt != null) 'ended_at': endedAt!.toIso8601String(),
      if (totalDistance != null) 'total_distance': totalDistance,
      if (totalDuration != null) 'total_duration': totalDuration,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}
