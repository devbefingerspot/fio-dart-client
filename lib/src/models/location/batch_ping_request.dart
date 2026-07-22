import 'geofence_event.dart';
import 'submit_ping_request.dart';

/// Request to submit a batch of location pings (max 500).
class SubmitBatchRequest {
  const SubmitBatchRequest({
    required this.pings,
  });

  final List<SubmitPingRequest> pings;

  Map<String, dynamic> toJson() {
    return {
      'pings': pings.map((p) => p.toJson()).toList(),
    };
  }
}

/// Response from POST /mobile/v1/location/batch.
class SubmitBatchResponse {
  const SubmitBatchResponse({
    required this.accepted,
    this.geofenceEvents,
  });

  final int accepted;
  final List<GeofenceEvent>? geofenceEvents;

  factory SubmitBatchResponse.fromJson(Map<String, dynamic> json) {
    return SubmitBatchResponse(
      accepted: json['accepted'] as int,
      geofenceEvents: (json['geofence_events'] as List<dynamic>?)
          ?.map((e) => GeofenceEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
