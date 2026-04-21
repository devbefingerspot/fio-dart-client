import '../overtime/overtime_master.dart';

/// GPS attendance settings for a company.
class GpsSettingsResponse {
  const GpsSettingsResponse({
    required this.gpsFrontPhoto,
    required this.gpsAdditionalPhoto,
    required this.gpsNote,
  });

  /// Requirement status for front (selfie) photo in GPS attendance.
  final FieldRequirementStatus gpsFrontPhoto;

  /// Requirement status for additional photos in GPS attendance.
  final FieldRequirementStatus gpsAdditionalPhoto;

  /// Requirement status for note in GPS attendance.
  final FieldRequirementStatus gpsNote;

  factory GpsSettingsResponse.fromJson(Map<String, dynamic> json) {
    return GpsSettingsResponse(
      gpsFrontPhoto:
          FieldRequirementStatus.fromJson(json['gps_front_photo'] as String?),
      gpsAdditionalPhoto: FieldRequirementStatus.fromJson(
          json['gps_additional_photo'] as String?),
      gpsNote: FieldRequirementStatus.fromJson(json['gps_note'] as String?),
    );
  }
}
