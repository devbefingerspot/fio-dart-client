/// Type of geofence zone.
enum GeofenceType {
  office('office'),
  clientSite('client_site'),
  custom('custom');

  const GeofenceType(this.value);

  final String value;
}

/// A circular geofence zone defined by center point and radius.
class Geofence {
  const Geofence({
    required this.id,
    required this.companyId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusMeter,
    required this.type,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String companyId;
  final String name;
  final double latitude;
  final double longitude;
  final double radiusMeter;
  final GeofenceType type;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Geofence.fromJson(Map<String, dynamic> json) {
    return Geofence(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radiusMeter: (json['radius_meter'] as num).toDouble(),
      type: GeofenceType.values.firstWhere(
        (e) => e.value == json['type'],
      ),
      isActive: json['is_active'] as bool,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'radius_meter': radiusMeter,
      'type': type.value,
      'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}
