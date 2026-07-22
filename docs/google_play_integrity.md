# GPS Attendance with Google Play Integrity — `fio_backend_client`

> Guide to using the GPS attendance flow with Google Play Integrity (Android) via the Dart client `fio_backend_client`.

---

## Table of Contents

1. [Overview](#1-overview)
2. [Overall Flow](#2-overall-flow)
3. [Prerequisites](#3-prerequisites)
4. [Setup — MobileApiClient](#4-setup--mobileapiclient)
5. [Step 1 — Check GPS Settings](#5-step-1--check-gps-settings)
6. [Step 2 — Get Challenge](#6-step-2--get-challenge)
7. [Step 3 — Request Play Integrity Token](#7-step-3--request-play-integrity-token)
8. [Step 4 — Submit GPS Attendance](#8-step-4--submit-gps-attendance)
9. [Step 5 — Upload Evidence](#9-step-5--upload-evidence)
10. [Debug Mode (Development)](#10-debug-mode-development)
11. [Complete Example](#11-complete-example)
12. [Error Handling](#12-error-handling)
13. [Model Reference](#13-model-reference)

---

## 1. Overview

Google Play Integrity API verifies that:

- **The app is genuine** — APK was downloaded from Google Play, not modified or repackaged.
- **The device is trustworthy** — Android device passes system integrity checks (no root, locked bootloader).
- **The user is licensed** — the Google account has a valid Play license for this app.

This replaces the deprecated SafetyNet Attestation API.

### When to use

- Before every GPS attendance submission (on-demand check).
- The Standard Integrity API has low latency (~hundreds of ms) — suitable for frequent use.

### Compared to iOS (App Attest)

| | Android (Play Integrity) | iOS (App Attest) |
|---|---|---|
| Key registration | ❌ Not needed | ✅ One-time per (device, company) |
| Challenge | 64-char hex → `requestHash` | 64-char hex → SHA256(nonce) |
| Token | Google Play generates & signs | Device signs locally (ECDSA) |
| Backend verification | Calls Google API (OAuth2) | Fully offline (ECDSA verify) |
| Counter tracking | ❌ Not needed | ✅ signCount increment per assertion |

---

## 2. Overall Flow

```
┌──────────────────────────────────────────────────────────────────────────┐
│             GPS ATTENDANCE + PLAY INTEGRITY — FULL FLOW                  │
│                                                                          │
│  Flutter App                    fio_backend_client        Backend Go     │
│      │                                │                        │         │
│ ──── EVERY ATTENDANCE SUBMISSION ────                                    │
│      │                                │                        │         │
│      │ ① GET /integrity/challenge ───>│───────────────────────>│         │
│      │ <── challenge (hex, 60s TTL) ──│<───────────────────────│         │
│      │                                │                        │         │
│      │ GooglePlayIntegrity            │                        │         │
│      │ .requestIntegrityToken(        │                        │         │
│      │   nonce: challenge,            │                        │         │
│      │   cloudProjectNumber: 965...)  │                        │         │
│      │ ← integrityToken (JWE)         │                        │         │
│      │                                │                        │         │
│      │ ② POST /gps-attendance ───────>│───────────────────────>│         │
│      │    {attendance_type, lat,      │   Decode JWE via       │         │
│      │     lng,                       │   Google API (OAuth2)  │         │
│      │     integrity_platform:        │   Verify verdicts      │         │
│      │       android,                 │   Create log +         │         │
│      │     integrity_token: token,    │   approval request     │         │
│      │     integrity_challenge: hex}  │                        │         │
│      │ <── {attendance_log,           │<── Issue upload token ─│         │
│      │      upload_token,             │                        │         │
│      │      upload_expires_in: 1800}  │                        │         │
│      │                                │                        │         │
│      │ ③ POST /gps-attendance/{id}   │                        │         │
│      │    /evidence ─────────────────>│───────────────────────>│         │
│      │    X-Upload-Token: <token>     │   Save photos + note   │         │
│      │    multipart: front_photo,     │   Update status        │         │
│      │    back_photos, attachments,   │                        │         │
│      │    note                        │                        │         │
│      │ <── {metadata} ────────────────│<───────────────────────│         │
│      │                                │                        │         │
└──────────────────────────────────────────────────────────────────────────┘
```

**Key points:**
- **No one-time registration step** — Android Play Integrity works on every request.
- **Challenge (step ①)** is a server-issued 64-char hex nonce with 60-second TTL. Must be requested fresh for each attendance submission.
- **Integrity token (step ②)** is a JWE (JSON Web Encryption) that the backend decodes via the Google Play Integrity API.
- **Upload token** is valid for 30 minutes. Evidence must be uploaded within that window.

---

## 3. Prerequisites

### Google Play Console
- App published to at least **Internal Testing** track on Google Play
- Cloud project **linked** to the app in Play Console → App Integrity
- **Cloud Project Number** noted (visible on the App Integrity page)

### Google Cloud Console
- Play Integrity API **enabled**
- Service account created with `playintegrity` scope (backend-side — no client action needed)

### Flutter App
- Flutter SDK 3.x
- `fio_backend_client` package
- `google_play_integrity` Flutter package

```yaml
# pubspec.yaml
dependencies:
  fio_backend_client:
    path: ../fio_backend_client
  google_play_integrity: ^1.2.0
```

### Android Config
- `compileSdkVersion` ≥ 33
- Physical device with Google Play Services (Play Integrity doesn't work on emulators)

```groovy
// android/app/build.gradle
android {
    compileSdkVersion 34
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

---

## 4. Setup — MobileApiClient

```dart
import 'package:fio_backend_client/fio_backend_client.dart';
import 'package:google_play_integrity/google_play_integrity.dart';

final client = MobileApiClient(
  authBaseUrl: 'https://auth.example.com',
  backendBaseUrl: 'https://backend.example.com',
  authHandler: MyAuthHandler(),
);

// After login & company selection:
await client.auth.issueCompanyToken(IssueCompanyTokenRequest(companyId: '...'));
client.setBackendBaseUrl(company.baseUrl);
client.setCurrentCompany(company.id);
```

See [README.md](../README.md) for detailed auth flow and `MobileApiAuthHandler` implementation.

---

## 5. Step 1 — Check GPS Settings

```dart
final settings = await client.gpsAttendance.getSettings();

// settings.gpsFrontPhoto       → FieldRequirementStatus (required / optional / off)
// settings.gpsAdditionalPhoto  → FieldRequirementStatus
// settings.gpsNote             → FieldRequirementStatus
// settings.gpsAttachment       → FieldRequirementStatus
// settings.maxAttachmentNumber → int
// settings.maxAdditionalPhotoNumber → int
```

Use this to enforce UI validation — e.g., if `gpsFrontPhoto == FieldRequirementStatus.required`, show a mandatory indicator.

---

## 6. Step 2 — Get Challenge

The challenge is a 64-character hex nonce. On Android, you pass it as the `requestHash` argument to `StandardIntegrityManager.requestIntegrityToken()`.

```dart
import 'package:fio_backend_client/fio_backend_client.dart';

final challengeResp = await client.integrity.getChallenge();
// challengeResp.challenge  → 64-char hex string
// challengeResp.expiresIn  → 60 seconds (use quickly!)
```

**Important:** The challenge is bound to the authenticated user and expires in 60 seconds. Request a new challenge for every attendance submission — never reuse or cache.

---

## 7. Step 3 — Request Play Integrity Token

Use the challenge as `requestHash` to call `StandardIntegrityManager.requestIntegrityToken()`.

```dart
import 'dart:convert';
import 'package:google_play_integrity/google_play_integrity.dart';

/// Request a Play Integrity token bound to [challenge].
///
/// [cloudProjectNumber] is the GCP project number (NOT project ID).
/// Find it at: Play Console → App Integrity → "Project number".
///
/// Returns the encrypted JWE token string, or null on failure.
Future<String?> requestPlayIntegrityToken({
  required String challenge,
  required int cloudProjectNumber,
}) async {
  try {
    final token = await GooglePlayIntegrity.instance.requestIntegrityToken(
      nonce: challenge,
      cloudProjectNumber: cloudProjectNumber,
    );
    return token;
  } catch (e) {
    // Common errors:
    // -8: GOOGLE_SERVER_UNAVAILABLE — retry with backoff
    // -3: APP_NOT_INSTALLED — app not installed from Play Store
    // -100: API_NOT_AVAILABLE — Google Play Services too old
    return null;
  }
}
```

**Token format:** The returned value is a compact JWE string (long base64). Do not try to decode or inspect it on the client — always send it to the backend for verification.

---

## 8. Step 4 — Submit GPS Attendance

Wrap `getChallenge()` + `requestIntegrityToken()` + `submit()`:

```dart
import 'package:fio_backend_client/fio_backend_client.dart';

/// Submit GPS attendance with Play Integrity verification.
///
/// Returns the attendance log and (if applicable) a one-time upload token
/// for evidence submission.
Future<SubmitGpsAttendanceResponse> submitWithIntegrity({
  required AttendanceType attendanceType,
  required double latitude,
  required double longitude,
  String? note,
  String? deviceName,
  String? wifiSsid,
  String? wifiMacAddress,
  int cloudProjectNumber = 965666351640,
}) async {
  // 1. Get integrity challenge from backend
  final challengeResp = await client.integrity.getChallenge();

  // 2. Request Play Integrity token from Google Play
  final token = await requestPlayIntegrityToken(
    challenge: challengeResp.challenge,
    cloudProjectNumber: cloudProjectNumber,
  );
  if (token == null) {
    throw Exception('Failed to obtain Play Integrity token');
  }

  // 3. Submit attendance with integrity payload
  return client.gpsAttendance.submit(
    SubmitGpsAttendanceRequest(
      attendanceType: attendanceType,
      latitude: latitude,
      longitude: longitude,
      note: note,
      deviceName: deviceName,
      wifiSsid: wifiSsid,
      wifiMacAddress: wifiMacAddress,
      integrityPlatform: IntegrityPlatform.android,
      integrityToken: token,
      integrityChallenge: challengeResp.challenge,
    ),
  );
}
```

**Response:**

```dart
// response.attendanceLog       → AttendanceLog (created record)
// response.permissionRequest   → Map? (approval workflow, if not auto-approved)
// response.uploadToken         → String? (for evidence upload; valid 30 min)
// response.uploadExpiresIn     → int?   (seconds until upload token expires)
```

---

## 9. Step 5 — Upload Evidence

If the company requires evidence (selfie, back photos, attachments, note), upload using the token:

```dart
import 'package:dio/dio.dart';

// After submit:
final uploadToken = response.uploadToken;
if (uploadToken != null) {
  await client.gpsAttendance.uploadEvidence(
    attendanceLogId: response.attendanceLog.id,
    uploadToken: uploadToken,
    frontPhoto: MultipartFile.fromFileSync('path/to/selfie.jpg',
      filename: 'selfie.jpg'),
    backPhotos: [
      MultipartFile.fromFileSync('path/to/back1.jpg',
        filename: 'back1.jpg'),
      MultipartFile.fromFileSync('path/to/back2.jpg',
        filename: 'back2.jpg'),
    ],
    attachments: [
      MultipartFile.fromFileSync('path/to/doc.pdf',
        filename: 'doc.pdf'),
    ],
    note: 'Arrived at office, heavy traffic',
    onSendProgress: (count, total) {
      print('Upload progress: $count / $total');
    },
  );
}
```

The upload token is **one-time use** and valid for **30 minutes**. Evidence fields required depend on company settings (see Step 1).

---

## 10. Debug Mode (Development)

When the backend is running in `development` mode (`APP_ENV=development`), you can bypass Play Integrity:

```dart
await client.gpsAttendance.submit(
  SubmitGpsAttendanceRequest(
    attendanceType: AttendanceType.checkIn,
    latitude: -6.2088,
    longitude: 106.8456,
    debug: true,  // ← bypass integrity
  ),
);
```

The `debug` flag is silently ignored in production environments.

---

## 11. Complete Example

```dart
import 'package:fio_backend_client/fio_backend_client.dart';
import 'package:google_play_integrity/google_play_integrity.dart';

class GpsAttendanceWithIntegrity {
  final MobileApiClient _client;

  /// Your GCP project number from Play Console → App Integrity.
  static const _cloudProjectNumber = 965666351640;

  GpsAttendanceWithIntegrity(this._client);

  /// Submit GPS attendance with full Play Integrity verification.
  Future<void> submitAttendance({
    required AttendanceType type,
    required double lat,
    required double lng,
    String? note,
    String? frontPhotoPath,
    List<String>? backPhotoPaths,
    List<String>? attachmentPaths,
  }) async {
    // (Optional) Check which evidence fields are required.
    final settings = await _client.gpsAttendance.getSettings();

    // Step 1-3: Challenge → Token → Submit.
    final challengeResp = await _client.integrity.getChallenge();

    final token = await GooglePlayIntegrity.instance.requestIntegrityToken(
      nonce: challengeResp.challenge,
      cloudProjectNumber: _cloudProjectNumber,
    );

    final response = await _client.gpsAttendance.submit(
      SubmitGpsAttendanceRequest(
        attendanceType: type,
        latitude: lat,
        longitude: lng,
        note: note,
        integrityPlatform: IntegrityPlatform.android,
        integrityToken: token,
        integrityChallenge: challengeResp.challenge,
      ),
    );

    // Step 4: Upload evidence if token was issued.
    if (response.uploadToken != null &&
        (frontPhotoPath != null ||
            backPhotoPaths != null ||
            attachmentPaths != null ||
            note != null)) {
      await _client.gpsAttendance.uploadEvidence(
        attendanceLogId: response.attendanceLog.id,
        uploadToken: response.uploadToken!,
        frontPhoto: frontPhotoPath != null
            ? MultipartFile.fromFileSync(frontPhotoPath,
                filename: 'selfie.jpg')
            : null,
        backPhotos: backPhotoPaths
            ?.map((p) =>
                MultipartFile.fromFileSync(p, filename: p.split('/').last))
            .toList(),
        attachments: attachmentPaths
            ?.map((p) =>
                MultipartFile.fromFileSync(p, filename: p.split('/').last))
            .toList(),
        note: note,
      );
    }
  }
}
```

---

## 12. Error Handling

### Reading diagnostics from 403 errors

When the backend rejects an integrity token (HTTP 403), it includes structured
diagnostics that tell you **exactly which check failed** and whether the
problem is on the client side (rooted device, sideloaded APK) or server side
(API not configured, OAuth2 misconfigured).

```dart
try {
  final response = await submitWithIntegrity(...);
} on ApiError catch (e) {
  final diag = e.integrityDiagnostics;

  // Log the full diagnostic for debugging
  print(e.integrityDebugSummary);
  // → "Integrity failure (android): app=PLAY_RECOGNIZED device=[] license=LICENSED failures=[device_integrity_missing, device_verdict_empty]"

  if (diag?.android != null) {
    final a = diag!.android!;

    // Device-level failure — tell the user their device isn't secure
    if (a.failureReasons.contains('device_integrity_missing')) {
      showDialog('Your device does not meet security requirements.');
      return;
    }

    // App not from Play Store — tell the user to download from Play Store
    if (a.failureReasons.any((r) => r.startsWith('app_not_recognized'))) {
      if (a.appRecognitionVerdict == 'UNRECOGNIZED_VERSION') {
        showDialog('This app version is not recognized. '
            'Please download from Google Play Store.');
        return;
      }
      // UNEVALUATED may indicate server-side misconfiguration
      if (a.appRecognitionVerdict == 'UNEVALUATED') {
        showDialog('Unable to verify app authenticity. '
            'Please try again or contact support.');
        return;
      }
    }

    // Device verdict completely empty — likely emulator
    if (a.failureReasons.contains('device_verdict_empty')) {
      showDialog('Device verification returned no result. '
          'Ensure you are using a physical device.');
      return;
    }
  }

  // iOS failures carry the step in failureDetail
  if (diag?.ios != null) {
    final detail = diag!.ios!.failureDetail;
    if (detail?.contains('signCount') == true) {
      // Possible replay attack or clock sync issue
      showDialog('Security counter mismatch. Please try again.');
    } else {
      showDialog('Device verification failed. Please try again.');
    }
  }
}
```

### Error reference

| Error | HTTP | Meaning | Action |
|-------|------|---------|--------|
| `ApiError` 403 | 403 | Device integrity failed | Check `e.integrityDiagnostics` for exact cause |
| `ApiError` 503 | 503 | Rate-limited, no cached verdict | Retry with exponential backoff |
| `ApiError` 409 | 409 | Concurrent submission (signCount conflict, iOS only) | Retry immediately |
| `ApiError` 422 | 422 | Evidence requirements not met | Check settings & required fields |
| `GOOGLE_SERVER_UNAVAILABLE` | — | Google Play servers unreachable | Retry with exponential backoff |
| `APP_NOT_INSTALLED` | — | App not from Play Store | Only in dev; sideloaded builds |

---

## 13. Model Reference

### IntegrityChallengeResponse

| Field | Type | Description |
|-------|------|-------------|
| `challenge` | `String` | 64-char hex nonce (pass as `requestHash` to Play Integrity) |
| `expiresIn` | `int` | TTL in seconds (60) |

### SubmitGpsAttendanceRequest (integrity fields)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `integrityPlatform` | `IntegrityPlatform?` | Yes (production) | `IntegrityPlatform.android` |
| `integrityToken` | `String?` | Yes (production) | JWE token from `requestIntegrityToken()` |
| `integrityChallenge` | `String?` | Yes (production) | Hex challenge from `getChallenge()` |
| `integrityKeyId` | `String?` | iOS only | Ignore on Android |
| `debug` | `bool` | No | Set `true` to bypass (dev only) |

### SubmitGpsAttendanceResponse

| Field | Type | Description |
|-------|------|-------------|
| `attendanceLog` | `AttendanceLog` | Created attendance record |
| `permissionRequest` | `Map?` | Approval workflow (null if auto-approved) |
| `uploadToken` | `String?` | One-time token for evidence upload |
| `uploadExpiresIn` | `int?` | Expiry in seconds (1800 = 30 min) |

### IntegrityErrorDiagnostics

| Field | Type | Description |
|-------|------|-------------|
| `platform` | `String` | `"android"` or `"ios"` |
| `android` | `AndroidDiagnostics?` | Populated for Play Integrity failures |
| `ios` | `IOSDiagnostics?` | Populated for App Attest assertion failures |

### AndroidDiagnostics

| Field | Type | Description |
|-------|------|-------------|
| `appRecognitionVerdict` | `String` | `PLAY_RECOGNIZED`, `UNRECOGNIZED_VERSION`, `UNEVALUATED` |
| `deviceRecognitionVerdict` | `List<String>` | Device labels, e.g. `["MEETS_BASIC_INTEGRITY"]` or `[]` |
| `appLicensingVerdict` | `String` | `LICENSED`, `UNLICENSED`, `UNEVALUATED` |
| `failureReasons` | `List<String>` | Which checks failed — see table below |

**Android `failureReasons` values:**

| Value | Meaning | Client action |
|-------|---------|---------------|
| `device_integrity_missing` | Device failed hardware-backed integrity check | Device is rooted/hacked — show security warning |
| `device_verdict_empty` | No device verdict at all | Likely an emulator or very old device |
| `app_not_recognized:UNRECOGNIZED_VERSION` | App certificate doesn't match Play Store | Debug build or sideloaded — direct user to Play Store |
| `app_not_recognized:UNEVALUATED` | App integrity couldn't be evaluated | Possibly server-side: API not enabled, project not linked, or old Play Services |

### IOSDiagnostics

| Field | Type | Description |
|-------|------|-------------|
| `failureDetail` | `String?` | The exact error from the verification step (e.g., signCount mismatch, ECDSA verify failed) |

---

## Related Documents

- [GPS Attendance with Apple App Attest (iOS)](gps_attendance_apple_app_attest.md)
- [Backend Play Integrity setup](../fio-web-desktop-backend/docs/google_play_integrity_flutter.md)
- [Google Play Integrity — Android Developers](https://developer.android.com/google/play/integrity/overview)
- [`google_play_integrity` package](https://pub.dev/packages/google_play_integrity)
