/// A single face-registry record returned by the auth service.
///
/// Both [FaceRegistryResponse.companyRecord] and
/// [FaceRegistryResponse.userOnlyRecord] are represented by this class.
class FaceRegistryRecord {
  const FaceRegistryRecord({
    required this.id,
    required this.userId,
    this.companyId,
    required this.photoUrl,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FaceRegistryRecord.fromJson(Map<String, dynamic> json) =>
      FaceRegistryRecord(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        companyId: json['company_id'] as String?,
        photoUrl: json['photo_url'] as String,
        metadata: json['metadata'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      );

  final String id;
  final String userId;

  /// `null` for user-only records (not scoped to a company).
  final String? companyId;

  final String photoUrl;

  /// Arbitrary JSON string produced by a face-recognition pipeline.
  final String? metadata;

  final DateTime createdAt;
  final DateTime updatedAt;
}
