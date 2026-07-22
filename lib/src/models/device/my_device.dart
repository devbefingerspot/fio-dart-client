/// A single registered mobile device from GET /api/v1/user/my-devices.
class MyDevice {
  const MyDevice({
    required this.deviceId,
    required this.fcmToken,
    required this.companyId,
    required this.createdAt,
  });

  final String deviceId;
  final String fcmToken;
  final String companyId;
  final DateTime createdAt;

  factory MyDevice.fromJson(Map<String, dynamic> json) {
    return MyDevice(
      deviceId: json['device_id'] as String,
      fcmToken: json['fcm_token'] as String,
      companyId: json['company_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
