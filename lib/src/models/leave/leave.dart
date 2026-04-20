/// Leave type definition (master data).
class Leave {
  const Leave({
    required this.id,
    required this.companyId,
    required this.name,
    this.amount,
    this.cycle,
    this.isPaid,
    this.isPhotoRequired,
    this.isNoteRequired,
    this.flexibleFrequency,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String companyId;
  final String name;
  final int? amount;
  final String? cycle;
  final bool? isPaid;
  final bool? isPhotoRequired;
  final bool? isNoteRequired;
  final bool? flexibleFrequency;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory Leave.fromJson(Map<String, dynamic> json) {
    return Leave(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      name: json['name'] as String,
      amount: json['amount'] as int?,
      cycle: json['cycle'] as String?,
      isPaid: json['is_paid'] as bool?,
      isPhotoRequired: json['is_photo_required'] as bool?,
      isNoteRequired: json['is_note_required'] as bool?,
      flexibleFrequency: json['flexible_frequency'] as bool?,
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
