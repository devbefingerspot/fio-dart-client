import '../overtime/overtime_master.dart';

/// Leave type definition (master data).
class Leave {
  const Leave({
    required this.id,
    required this.companyId,
    required this.name,
    this.amount,
    this.cycle,
    this.isPaid,
    this.allowMobileRequest,
    this.frontPhoto,
    this.additionalPhoto,
    this.note,
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
  final bool? allowMobileRequest;
  final FieldRequirementStatus? frontPhoto;
  final FieldRequirementStatus? additionalPhoto;
  final FieldRequirementStatus? note;
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
      allowMobileRequest: json['allow_mobile_request'] as bool?,
      frontPhoto: json['front_photo'] != null
          ? FieldRequirementStatus.fromJson(json['front_photo'] as String?)
          : null,
      additionalPhoto: json['additional_photo'] != null
          ? FieldRequirementStatus.fromJson(json['additional_photo'] as String?)
          : null,
      note: json['note'] != null
          ? FieldRequirementStatus.fromJson(json['note'] as String?)
          : null,
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
