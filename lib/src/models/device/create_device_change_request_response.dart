/// Response from POST /api/v1/device-change-request.
class CreateDeviceChangeRequestResponse {
  const CreateDeviceChangeRequestResponse({
    required this.message,
    required this.id,
  });

  final String message;
  final String id;

  factory CreateDeviceChangeRequestResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    return CreateDeviceChangeRequestResponse(
      message: json['message'] as String,
      id: json['id'] as String,
    );
  }
}
