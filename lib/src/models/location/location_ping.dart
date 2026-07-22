/// A single GPS location data point recorded by the mobile device.
class LocationPing {
  const LocationPing({
    required this.id,
    required this.companyId,
    required this.employeeId,
    this.sessionId,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    this.altitude,
    this.speed,
    this.bearing,
    required this.provider,
    this.batteryLevel,
    this.activityType,
    this.activityConfidence,
    required this.isMock,
    required this.recordedAt,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String companyId;
  final String employeeId;
  final String? sessionId;
  final double latitude;
  final double longitude;
  final double accuracy;
  final double? altitude;
  final double? speed;
  final double? bearing;
  final String provider;
  final double? batteryLevel;
  final String? activityType;
  final int? activityConfidence;
  final bool isMock;
  final DateTime recordedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory LocationPing.fromJson(Map<String, dynamic> json) {
    return LocationPing(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      employeeId: json['employee_id'] as String,
      sessionId: json['session_id'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracy: (json['accuracy'] as num).toDouble(),
      altitude: (json['altitude'] as num?)?.toDouble(),
      speed: (json['speed'] as num?)?.toDouble(),
      bearing: (json['bearing'] as num?)?.toDouble(),
      provider: json['provider'] as String,
      batteryLevel: (json['battery_level'] as num?)?.toDouble(),
      activityType: json['activity_type'] as String?,
      activityConfidence: json['activity_confidence'] as int?,
      isMock: json['is_mock'] as bool,
      recordedAt: DateTime.parse(json['recorded_at'] as String),
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'employee_id': employeeId,
      if (sessionId != null) 'session_id': sessionId,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      if (altitude != null) 'altitude': altitude,
      if (speed != null) 'speed': speed,
      if (bearing != null) 'bearing': bearing,
      'provider': provider,
      if (batteryLevel != null) 'battery_level': batteryLevel,
      if (activityType != null) 'activity_type': activityType,
      if (activityConfidence != null) 'activity_confidence': activityConfidence,
      'is_mock': isMock,
      'recorded_at': recordedAt.toIso8601String(),
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}
