/// Overtime master (template) defining overtime rules.
class OvertimeMaster {
  const OvertimeMaster({
    required this.id,
    required this.companyId,
    required this.name,
    this.isPhotoRequired,
    this.isNoteRequired,
    this.config,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String companyId;
  final String name;
  final bool? isPhotoRequired;
  final bool? isNoteRequired;
  final Map<String, dynamic>? config;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory OvertimeMaster.fromJson(Map<String, dynamic> json) {
    return OvertimeMaster(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      name: json['name'] as String,
      isPhotoRequired: json['is_photo_required'] as bool?,
      isNoteRequired: json['is_note_required'] as bool?,
      config: json['config'] as Map<String, dynamic>?,
      isActive: json['is_active'] as bool?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
}
