import '../overtime/overtime_master.dart';

/// GPS attendance settings for a company.
class GpsSettingsResponse {
  const GpsSettingsResponse({
    required this.gpsFrontPhoto,
    required this.gpsAdditionalPhoto,
    required this.gpsNote,
    required this.gpsAttachment,
    required this.gpsMaxAttachmentNumber,
  });

  /// Requirement status for front (selfie) photo in GPS attendance.
  final FieldRequirementStatus gpsFrontPhoto;

  /// Requirement status for additional photos in GPS attendance.
  final FieldRequirementStatus gpsAdditionalPhoto;

  /// Requirement status for note in GPS attendance.
  final FieldRequirementStatus gpsNote;

  /// Requirement status for file attachments in GPS attendance.
  final FieldRequirementStatus gpsAttachment;

  /// Maximum number of file attachments allowed per GPS attendance record.
  final int gpsMaxAttachmentNumber;

  factory GpsSettingsResponse.fromJson(Map<String, dynamic> json) {
    return GpsSettingsResponse(
      gpsFrontPhoto:
          FieldRequirementStatus.fromJson(json['gps_front_photo'] as String?),
      gpsAdditionalPhoto: FieldRequirementStatus.fromJson(
          json['gps_additional_photo'] as String?),
      gpsNote: FieldRequirementStatus.fromJson(json['gps_note'] as String?),
      gpsAttachment: FieldRequirementStatus.fromJson(
          json['gps_attachment'] as String?),
      gpsMaxAttachmentNumber:
          (json['gps_max_attachment_number'] as num?)?.toInt() ?? 5,
    );
  }
}
