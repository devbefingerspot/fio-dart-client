/// Type of geofence boundary crossing event.
enum GeofenceEventType {
  enter('enter'),
  exit('exit'),
  dwell('dwell');

  const GeofenceEventType(this.value);

  final String value;
}

/// A geofence enter, exit, or dwell event triggered by a location ping.
class GeofenceEvent {
  const GeofenceEvent({
    required this.id,
    required this.companyId,
    required this.employeeId,
    this.geofenceId,
    this.locationPingId,
    required this.eventType,
    required this.occurredAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String companyId;
  final String employeeId;
  final String? geofenceId;
  final String? locationPingId;
  final GeofenceEventType eventType;
  final DateTime occurredAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory GeofenceEvent.fromJson(Map<String, dynamic> json) {
    return GeofenceEvent(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      employeeId: json['employee_id'] as String,
      geofenceId: json['geofence_id'] as String?,
      locationPingId: json['location_ping_id'] as String?,
      eventType: GeofenceEventType.values.firstWhere(
        (e) => e.value == json['event_type'],
      ),
      occurredAt: DateTime.parse(json['occurred_at'] as String),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'employee_id': employeeId,
      if (geofenceId != null) 'geofence_id': geofenceId,
      if (locationPingId != null) 'location_ping_id': locationPingId,
      'event_type': eventType.value,
      'occurred_at': occurredAt.toIso8601String(),
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}
