/// Request to update a location tracking session (pause or complete).
class UpdateSessionRequest {
  const UpdateSessionRequest({
    required this.status,
    this.totalDistance,
    this.totalDuration,
  });

  final String status;
  final double? totalDistance;
  final int? totalDuration;

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      if (totalDistance != null) 'total_distance': totalDistance,
      if (totalDuration != null) 'total_duration': totalDuration,
    };
  }
}
