import 'attendance_type.dart';

/// Platform for integrity verification.
enum IntegrityPlatform {
  android('android'),
  ios('ios'),
  debug('debug');

  const IntegrityPlatform(this.value);

  final String value;
}

/// Whether the submission is immediate (`online`) or deferred (`offline`).
///
/// Offline means the record was captured while the device had no usable
/// connection and is being submitted later. It requires [recordedAt].
enum GpsAttendanceMode {
  online('online'),
  offline('offline');

  const GpsAttendanceMode(this.value);

  final String value;
}

/// Request to submit GPS attendance.
///
/// Prefer the [SubmitGpsAttendanceRequest.online] and
/// [SubmitGpsAttendanceRequest.offline] constructors: they make an offline
/// submission without a capture time impossible to build.
class SubmitGpsAttendanceRequest {
  const SubmitGpsAttendanceRequest({
    required this.attendanceType,
    required this.latitude,
    required this.longitude,
    required this.clientSubmissionId,
    this.mode,
    this.recordedAt,
    this.note,
    this.deviceName,
    this.wifiSsid,
    this.wifiMacAddress,
    this.accuracyMeter,
    this.provider,
    this.isMock = false,
    this.integrityPlatform,
    this.integrityToken,
    this.integrityChallenge,
    this.integrityKeyId,
    this.debug = false,
  });

  /// Immediate submission. The server stamps the attendance with its own clock.
  factory SubmitGpsAttendanceRequest.online({
    required AttendanceType attendanceType,
    required double latitude,
    required double longitude,
    required String clientSubmissionId,
    String? note,
    String? deviceName,
    String? wifiSsid,
    String? wifiMacAddress,
    double? accuracyMeter,
    String? provider,
    bool isMock = false,
    IntegrityPlatform? integrityPlatform,
    String? integrityToken,
    String? integrityChallenge,
    String? integrityKeyId,
    bool debug = false,
  }) {
    return SubmitGpsAttendanceRequest(
      attendanceType: attendanceType,
      latitude: latitude,
      longitude: longitude,
      clientSubmissionId: clientSubmissionId,
      mode: GpsAttendanceMode.online,
      note: note,
      deviceName: deviceName,
      wifiSsid: wifiSsid,
      wifiMacAddress: wifiMacAddress,
      accuracyMeter: accuracyMeter,
      provider: provider,
      isMock: isMock,
      integrityPlatform: integrityPlatform,
      integrityToken: integrityToken,
      integrityChallenge: integrityChallenge,
      integrityKeyId: integrityKeyId,
      debug: debug,
    );
  }

  /// Deferred submission. [recordedAt] is the capture instant and is sent as
  /// `recorded_at`; the server keeps it bounded by its offline window.
  factory SubmitGpsAttendanceRequest.offline({
    required AttendanceType attendanceType,
    required double latitude,
    required double longitude,
    required String clientSubmissionId,
    required DateTime recordedAt,
    String? note,
    String? deviceName,
    String? wifiSsid,
    String? wifiMacAddress,
    double? accuracyMeter,
    String? provider,
    bool isMock = false,
    IntegrityPlatform? integrityPlatform,
    String? integrityToken,
    String? integrityChallenge,
    String? integrityKeyId,
    bool debug = false,
  }) {
    return SubmitGpsAttendanceRequest(
      attendanceType: attendanceType,
      latitude: latitude,
      longitude: longitude,
      clientSubmissionId: clientSubmissionId,
      mode: GpsAttendanceMode.offline,
      recordedAt: recordedAt.toUtc(),
      note: note,
      deviceName: deviceName,
      wifiSsid: wifiSsid,
      wifiMacAddress: wifiMacAddress,
      accuracyMeter: accuracyMeter,
      provider: provider,
      isMock: isMock,
      integrityPlatform: integrityPlatform,
      integrityToken: integrityToken,
      integrityChallenge: integrityChallenge,
      integrityKeyId: integrityKeyId,
      debug: debug,
    );
  }

  /// Type of attendance: CHECK_IN, CHECK_OUT, BREAK_IN, BREAK_OUT, etc.
  final AttendanceType attendanceType;

  /// GPS latitude.
  final double latitude;

  /// GPS longitude.
  final double longitude;

  /// Stable idempotency key generated once at capture time. Reusing it on a
  /// retry returns the original record instead of creating a duplicate.
  final String clientSubmissionId;

  /// Declared submission mode. `null` lets the backend infer it from
  /// [recordedAt] (deprecated path, kept for older clients).
  final GpsAttendanceMode? mode;

  /// Capture instant for a deferred submission. Required when [mode] is
  /// [GpsAttendanceMode.offline].
  final DateTime? recordedAt;

  /// Optional note describing the attendance.
  final String? note;

  /// Device name or model.
  final String? deviceName;

  /// WiFi SSID detected by the device at the attendance location.
  final String? wifiSsid;

  /// WiFi MAC address (BSSID) detected by the device at the attendance location.
  final String? wifiMacAddress;

  /// Horizontal accuracy of the fix in metres.
  final double? accuracyMeter;

  /// Location provider: gps, network, fused, passive.
  final String? provider;

  /// Whether the device reports a mocked location. Advisory only — the server
  /// never treats it as authoritative.
  final bool isMock;

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
    assert(
      mode != GpsAttendanceMode.offline || recordedAt != null,
      'recordedAt is required when mode is offline',
    );

    final map = <String, dynamic>{
      'attendance_type': attendanceType.value,
      'latitude': latitude,
      'longitude': longitude,
      'client_submission_id': clientSubmissionId,
    };
    if (mode != null) map['mode'] = mode!.value;
    if (recordedAt != null) {
      map['recorded_at'] = recordedAt!.toUtc().toIso8601String();
    }
    if (note != null) map['note'] = note;
    if (deviceName != null) map['device_name'] = deviceName;
    if (wifiSsid != null) map['wifi_ssid'] = wifiSsid;
    if (wifiMacAddress != null) map['wifi_mac_address'] = wifiMacAddress;
    if (accuracyMeter != null) map['accuracy_meter'] = accuracyMeter;
    if (provider != null) map['provider'] = provider;
    if (isMock) map['is_mock'] = true;
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
