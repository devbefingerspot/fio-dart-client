import '../../models/common/paginated_response.dart';
import 'location_ping.dart';
import 'location_session.dart';

/// Response from GET /mobile/v1/location/sessions/:id.
class SessionDetailResponse {
  const SessionDetailResponse({
    required this.session,
    required this.pings,
  });

  final LocationSession session;
  final PaginatedResponse<LocationPing> pings;

  factory SessionDetailResponse.fromJson(Map<String, dynamic> json) {
    return SessionDetailResponse(
      session: LocationSession.fromJson(json['session'] as Map<String, dynamic>),
      pings: PaginatedResponse.fromJson(
        json['pings'] as Map<String, dynamic>,
        (data) => LocationPing.fromJson(data),
      ),
    );
  }
}
