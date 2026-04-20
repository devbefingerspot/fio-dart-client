import 'attendance_type.dart';

/// Platform for integrity verification.
enum IntegrityPlatform {
  android('android'),
  ios('ios'),
  debug('debug');

  const IntegrityPlatform(this.value);

  final String value;
}

/// Request to submit GPS attendance.
class SubmitGpsAttendanceRequest {
  const SubmitGpsAttendanceRequest({
    required this.attendanceType,
    required this.latitude,
    required this.longitude,
    this.note,
    this.deviceName,
    this.integrityPlatform,
    this.integrityToken,
    this.integrityChallenge,
    this.integrityKeyId,
    this.debug = false,
  });

  /// Type of attendance: CHECK_IN, CHECK_OUT, BREAK_IN, BREAK_OUT, etc.
  final AttendanceType attendanceType;

  /// GPS latitude.
  final double latitude;

  /// GPS longitude.
  final double longitude;

  /// Optional note describing the attendance.
  final String? note;

  /// Device name or model.
  final String? deviceName;

  /// Platform for integrity verification: android, ios, or debug.
  final IntegrityPlatform? integrityPlatform;

  /// Integrity token from device attestation (Android: Play Integrity, iOS: App Attest assertion).
  final String? integrityToken;

  /// Integrity challenge nonce (required for Android).
  final String? integrityChallenge;

  /// iOS App Attest key ID (required for iOS).
  final String? integrityKeyId;

  /// Set to true to bypass integrity check (development only).
  final bool debug;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'attendance_type': attendanceType.value,
      'latitude': latitude,
      'longitude': longitude,
    };
    if (note != null) map['note'] = note;
    if (deviceName != null) map['device_name'] = deviceName;
    if (integrityPlatform != null) {
      map['integrity_platform'] = integrityPlatform!.value;
    }
    if (integrityToken != null) map['integrity_token'] = integrityToken;
    if (integrityChallenge != null) {
      map['integrity_challenge'] = integrityChallenge;
    }
    if (integrityKeyId != null) map['integrity_key_id'] = integrityKeyId;
    if (debug) map['debug'] = true;
    return map;
  }
}
