/// Request to start a new location tracking session.
class StartSessionRequest {
  const StartSessionRequest({
    required this.sessionType,
    this.purpose,
  });

  final String sessionType;
  final String? purpose;

  Map<String, dynamic> toJson() {
    return {
      'session_type': sessionType,
      if (purpose != null) 'purpose': purpose,
    };
  }
}
