/// How a payment feature item is tracked.
enum FeatureType {
  /// Assignable quota (e.g. employee/device seat).
  seat('seat'),

  /// Metered usage (e.g. API calls).
  usage('usage'),

  /// Boolean on/off access.
  flag('flag'),

  /// Unknown/unspecified — reserved for forward compatibility.
  unknown('unknown');

  const FeatureType(this.value);

  final String value;

  static FeatureType fromValue(String? value) {
    return FeatureType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => FeatureType.unknown,
    );
  }
}

/// A single payment feature grant for the authenticated employee.
///
/// Mirrors the `featureDTO` shape returned by `GET /mobile/v1/my-features`.
class EmployeeFeature {
  const EmployeeFeature({
    required this.itemKey,
    required this.itemName,
    required this.featureType,
    required this.status,
    required this.parentItemKey,
  });

  /// Feature item key (e.g. `"employee-quota"`, `"face-recognition"`).
  final String itemKey;

  /// Display name of the feature.
  final String itemName;

  /// Classification of the feature (`seat`, `usage`, or `flag`).
  final FeatureType featureType;

  /// Status of the employee's assignment for this feature.
  ///
  /// For seat features: `"assigned"`, `"revoked"`, or `"expired"`.
  /// For flag features: always `"assigned"` (presence = granted).
  final String status;

  /// Bundle item key when this feature originates from a bundle
  /// (e.g. `"mobile-pro"`). Empty for direct plan/addon features.
  final String parentItemKey;

  factory EmployeeFeature.fromJson(Map<String, dynamic> json) {
    return EmployeeFeature(
      itemKey: json['item_key'] as String? ?? '',
      itemName: json['item_name'] as String? ?? '',
      featureType: FeatureType.fromValue(json['feature_type'] as String?),
      status: json['status'] as String? ?? '',
      parentItemKey: json['parent_item_key'] as String? ?? '',
    );
  }
}
