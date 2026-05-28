import 'face_registry_record.dart';

/// Response for face-registry GET and POST endpoints.
///
/// Both [companyRecord] and [userOnlyRecord] may be `null` if the respective
/// record has not been registered yet.
class FaceRegistryResponse {
  const FaceRegistryResponse({
    this.companyRecord,
    this.userOnlyRecord,
  });

  factory FaceRegistryResponse.fromJson(Map<String, dynamic> json) =>
      FaceRegistryResponse(
        companyRecord: json['company_record'] != null
            ? FaceRegistryRecord.fromJson(
                json['company_record'] as Map<String, dynamic>)
            : null,
        userOnlyRecord: json['user_only_record'] != null
            ? FaceRegistryRecord.fromJson(
                json['user_only_record'] as Map<String, dynamic>)
            : null,
      );

  /// Face record scoped to the current company. `null` if not registered.
  final FaceRegistryRecord? companyRecord;

  /// Global (user-only) face record, not tied to any company. `null` if not registered.
  final FaceRegistryRecord? userOnlyRecord;
}
