/// Employee list item with basic information.
class EmployeeListItem {
  const EmployeeListItem({
    required this.id,
    required this.companyId,
    required this.fullName,
    this.customId,
    this.nip,
    this.photoFileUrl,
    this.officeId,
    this.officeName,
    this.departmentId,
    this.departmentName,
    this.positionId,
    this.positionName,
    this.isActive,
    this.contractType,
    this.joinedAt,
  });

  final String id;
  final String companyId;
  final String fullName;
  final String? customId;
  final String? nip;
  final String? photoFileUrl;
  final String? officeId;
  final String? officeName;
  final String? departmentId;
  final String? departmentName;
  final String? positionId;
  final String? positionName;
  final bool? isActive;
  final String? contractType;
  final DateTime? joinedAt;

  factory EmployeeListItem.fromJson(Map<String, dynamic> json) {
    return EmployeeListItem(
      id: json['id'] as String,
      companyId: json['company_id'] as String,
      fullName: json['full_name'] as String,
      customId: json['custom_id'] as String?,
      nip: json['nip'] as String?,
      photoFileUrl: json['photo_file_url'] as String?,
      officeId: json['office_id'] as String?,
      officeName: json['office_name'] as String?,
      departmentId: json['department_id'] as String?,
      departmentName: json['department_name'] as String?,
      positionId: json['position_id'] as String?,
      positionName: json['position_name'] as String?,
      isActive: json['is_active'] as bool?,
      contractType: json['contract_type'] as String?,
      joinedAt: json['joined_at'] != null
          ? DateTime.parse(json['joined_at'] as String)
          : null,
    );
  }
}
