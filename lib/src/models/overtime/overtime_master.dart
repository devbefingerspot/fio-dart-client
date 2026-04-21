/// Tri-state requirement status for photo/note fields.
enum FieldRequirementStatus {
  optional,
  required,
  hidden;

  static FieldRequirementStatus fromJson(String? value) {
    switch (value) {
      case 'required':
        return FieldRequirementStatus.required;
      case 'hidden':
        return FieldRequirementStatus.hidden;
      case 'optional':
      default:
        return FieldRequirementStatus.optional;
    }
  }
}

/// Overtime master (template) defining overtime rules.
class OvertimeMaster {
  const OvertimeMaster({
    required this.id,
    required this.companyId,
    required this.name,
    this.frontPhoto,
    this.additionalPhoto,
    this.note,
    this.config,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String companyId;
  final String name;
  final FieldRequirementStatus? frontPhoto;
  final FieldRequirementStatus? additionalPhoto;
  final FieldRequirementStatus? note;
  final Map<String, dynamic>? config;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory OvertimeMaster.fromJson(Map<String, dynamic> json) {
    return OvertimeMaster(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      name: json['name'] as String,
      frontPhoto: json['front_photo'] != null
          ? FieldRequirementStatus.fromJson(json['front_photo'] as String?)
          : null,
      additionalPhoto: json['additional_photo'] != null
          ? FieldRequirementStatus.fromJson(json['additional_photo'] as String?)
          : null,
      note: json['note'] != null
          ? FieldRequirementStatus.fromJson(json['note'] as String?)
          : null,
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
