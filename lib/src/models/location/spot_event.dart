/// Type of spot boundary crossing event.
enum SpotEventType {
  enter('enter'),
  exit('exit'),
  dwell('dwell');

  const SpotEventType(this.value);

  final String value;
}

/// A spot enter, exit, or dwell event triggered by a location ping.
class SpotEvent {
  const SpotEvent({
    required this.id,
    required this.companyId,
    required this.employeeId,
    this.spotId,
    this.locationPingId,
    required this.eventType,
    required this.occurredAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String companyId;
  final String employeeId;
  final String? spotId;
  final String? locationPingId;
  final SpotEventType eventType;
  final DateTime occurredAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory SpotEvent.fromJson(Map<String, dynamic> json) {
    return SpotEvent(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      employeeId: json['employee_id'] as String,
      spotId: json['spot_id'] as String?,
      locationPingId: json['location_ping_id'] as String?,
      eventType: SpotEventType.values.firstWhere(
        (e) => e.value == json['event_type'],
        orElse: () => SpotEventType.enter,
      ),
      occurredAt: DateTime.parse(json['occurred_at'] as String),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}
