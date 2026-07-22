import 'geofence_event.dart';
import 'location_ping.dart';

/// Request to submit a single location ping.
class SubmitPingRequest {
  const SubmitPingRequest({
    this.sessionId,
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    this.altitude,
    this.speed,
    this.bearing,
    required this.provider,
    this.batteryLevel,
    this.activityType,
    this.activityConfidence,
    this.isMock = false,
    required this.recordedAt,
  });

  final String? sessionId;
  final double latitude;
  final double longitude;
  final double accuracy;
  final double? altitude;
  final double? speed;
  final double? bearing;
  final String provider;
  final double? batteryLevel;
  final String? activityType;
  final int? activityConfidence;
  final bool isMock;
  final String recordedAt;

  Map<String, dynamic> toJson() {
    return {
      if (sessionId != null) 'session_id': sessionId,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      if (altitude != null) 'altitude': altitude,
      if (speed != null) 'speed': speed,
      if (bearing != null) 'bearing': bearing,
      'provider': provider,
      if (batteryLevel != null) 'battery_level': batteryLevel,
      if (activityType != null) 'activity_type': activityType,
      if (activityConfidence != null) 'activity_confidence': activityConfidence,
      'is_mock': isMock,
      'recorded_at': recordedAt,
    };
  }
}

/// Response from POST /mobile/v1/location/ping.
class SubmitPingResponse {
  const SubmitPingResponse({
    required this.locationPing,
    this.geofenceEvents,
  });

  final LocationPing locationPing;
  final List<GeofenceEvent>? geofenceEvents;

  factory SubmitPingResponse.fromJson(Map<String, dynamic> json) {
    return SubmitPingResponse(
      locationPing: LocationPing.fromJson(json['location_ping'] as Map<String, dynamic>),
      geofenceEvents: (json['geofence_events'] as List<dynamic>?)
          ?.map((e) => GeofenceEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
