/// Type of a spot/checkpoint zone.
enum SpotType {
  spot('SPOT'),
  guardPatrol('GUARD_PATROL'),
  workFromHome('WORK_FROM_HOME');

  const SpotType(this.value);

  final String value;
}

/// A circular spot/checkpoint zone defined by center point and radius.
class Spot {
  const Spot({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.type,
    required this.isActive,
    this.address,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double radius;
  final SpotType type;
  final bool isActive;
  final String? address;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Spot.fromJson(Map<String, dynamic> json) {
    return Spot(
      id: json['id'] as String,
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radius: (json['radius'] as num).toDouble(),
      type: SpotType.values.firstWhere(
        (e) => e.value == json['type'],
        orElse: () => SpotType.spot,
      ),
      isActive: json['is_active'] as bool,
      address: json['address'] as String?,
      description: json['description'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}
