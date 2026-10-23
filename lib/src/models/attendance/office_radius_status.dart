/// Whether a GPS attendance record was captured inside the employee's office
/// radius.
///
/// Only GPS submissions have a radius status; other attendance methods return
/// `null`.
enum OfficeRadiusStatus {
  /// The fix was within `gpsMaxDistanceFromOfficeMeter` of the assigned office.
  inside('inside'),

  /// The fix was outside the radius.
  outside('outside'),

  /// The radius could not be computed (no assigned office, or the office has
  /// no coordinates).
  unknown('unknown');

  const OfficeRadiusStatus(this.value);

  /// The string value sent to/from the API.
  final String value;

  /// Parses a radius status from the API. Returns `null` for an unknown or
  /// missing value so non-GPS records stay nullable.
  static OfficeRadiusStatus? fromString(String? value) {
    if (value == null) return null;
    for (final status in OfficeRadiusStatus.values) {
      if (status.value == value) return status;
    }
    return null;
  }
}
