import '../overtime/overtime_master.dart';

/// GPS attendance settings for a company.
class GpsSettingsResponse {
  const GpsSettingsResponse({
    required this.gpsFrontPhoto,
    required this.gpsAdditionalPhoto,
    required this.gpsNote,
    required this.gpsAttachment,
    required this.maxAttachmentNumber,
    required this.maxAdditionalPhotoNumber,
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
  final int maxAttachmentNumber;

  /// Maximum number of additional photos allowed per GPS attendance record.
  final int maxAdditionalPhotoNumber;

  /// Deprecated: use [maxAttachmentNumber] instead.
  @Deprecated('Use maxAttachmentNumber instead.')
  int get gpsMaxAttachmentNumber => maxAttachmentNumber;

  factory GpsSettingsResponse.fromJson(Map<String, dynamic> json) {
    return GpsSettingsResponse(
      gpsFrontPhoto:
          FieldRequirementStatus.fromJson(json['gps_front_photo'] as String?),
      gpsAdditionalPhoto: FieldRequirementStatus.fromJson(
          json['gps_additional_photo'] as String?),
      gpsNote: FieldRequirementStatus.fromJson(json['gps_note'] as String?),
      gpsAttachment: FieldRequirementStatus.fromJson(
          json['gps_attachment'] as String?),
      maxAttachmentNumber:
          (json['max_attachment_number'] as num?)?.toInt() ??
          (json['gps_max_attachment_number'] as num?)?.toInt() ??
          5,
      maxAdditionalPhotoNumber:
          (json['max_additional_photo_number'] as num?)?.toInt() ?? 3,
    );
  }
}
