/// Request body for POST /api/v1/device-change-request.
class CreateDeviceChangeRequestRequest {
  const CreateDeviceChangeRequestRequest({
    required this.oldDeviceId,
    required this.deviceUniqueIdentifier,
    required this.fcmToken,
    required this.userAgent,
    required this.detail,
    required this.companyId,
  });

  final String oldDeviceId;
  final String deviceUniqueIdentifier;
  final String fcmToken;
  final String userAgent;
  final String detail;
  final String companyId;

  Map<String, dynamic> toJson() => {
        'old_device_id': oldDeviceId,
        'device_unique_identifier': deviceUniqueIdentifier,
        'fcm_token': fcmToken,
        'user_agent': userAgent,
        'detail': detail,
        'company_id': companyId,
      };
}
