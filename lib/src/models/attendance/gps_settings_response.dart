/// GPS attendance settings for a company.
class GpsSettingsResponse {
  const GpsSettingsResponse({
    required this.isGpsFrontPhotoRequired,
    required this.isGpsAdditionalPhotoRequired,
    required this.isGpsNoteRequired,
  });

  /// Whether a front (selfie) photo is required for GPS attendance.
  final bool isGpsFrontPhotoRequired;

  /// Whether additional photos are required for GPS attendance.
  final bool isGpsAdditionalPhotoRequired;

  /// Whether a note is required for GPS attendance.
  final bool isGpsNoteRequired;

  factory GpsSettingsResponse.fromJson(Map<String, dynamic> json) {
    return GpsSettingsResponse(
      isGpsFrontPhotoRequired:
          json['is_gps_front_photo_required'] as bool? ?? false,
      isGpsAdditionalPhotoRequired:
          json['is_gps_additional_photo_required'] as bool? ?? false,
      isGpsNoteRequired: json['is_gps_note_required'] as bool? ?? false,
    );
  }
}
