# Absensi GPS dengan Apple App Attest — `fio_backend_client`

> Panduan penggunaan GPS attendance flow dengan Apple App Attest menggunakan Dart client `fio_backend_client`.

---

## Daftar Isi

1. [Alur Keseluruhan](#1-alur-keseluruhan)
2. [Konsep Kunci: Lingkup Registrasi Key](#2-konsep-kunci-lingkup-registrasi-key)
3. [Prasyarat](#3-prasyarat)
4. [Instalasi](#4-instalasi)
5. [Langkah 1 — Setup MobileApiClient](#5-langkah-1--setup-mobileapiclient)
6. [Langkah 2 — Cek GPS Settings Perusahaan](#6-langkah-2--cek-gps-settings-perusahaan)
7. [Langkah 3 — iOS App Attest: Registrasi Key](#7-langkah-3--ios-app-attest-registrasi-key)
8. [Langkah 4 — iOS App Attest: Dapatkan Challenge](#8-langkah-4--ios-app-attest-dapatkan-challenge)
9. [Langkah 5 — Submit GPS Attendance dengan Assertion](#9-langkah-5--submit-gps-attendance-dengan-assertion)
10. [Langkah 6 — Upload Evidence (Foto, Lampiran)](#10-langkah-6--upload-evidence-foto-lampiran)
11. [Langkah 7 — Debug Mode (Development)](#11-langkah-7--debug-mode-development)
12. [Contoh Lengkap](#12-contoh-lengkap)
13. [Edge Cases & Multi-Device/Multi-Company](#13-edge-cases--multi-devicemulti-company)
14. [Error Handling](#14-error-handling)
15. [Referensi Model](#15-referensi-model)

---

## 1. Alur Keseluruhan

```
┌──────────────────────────────────────────────────────────────────────────┐
│                GPS ATTENDANCE + APP ATTEST — FULL FLOW                   │
│                                                                          │
│  Flutter App                    fio_backend_client        Backend Go     │
│      │                                │                        │         │
│ ──── SEKALI SAJA PER (device, company) ────                             │
│      │                                │                        │         │
│      │ ① GET /integrity/challenge ───>│───────────────────────>│         │
│      │ <── challenge (hex, 60s TTL) ──│<───────────────────────│         │
│      │                                │                        │         │
│      │ AppAttestPlugin.generateKey()  │                        │         │
│      │ ← keyId                        │                        │         │
│      │                                │                        │         │
│      │ AppAttestPlugin.attestKey(     │                        │         │
│      │   keyId, SHA256(challenge))    │                        │         │
│      │ ← attestation (base64)         │                        │         │
│      │                                │                        │         │
│      │ ② POST /ios/attest ───────────>│───────────────────────>│         │
│      │    {keyId, attestation,        │    Verifikasi offline   │         │
│      │     challenge}                 │    (Apple Root CA)      │         │
│      │ <── {ok: true, key_id} ────────│<── Simpan public key ──│         │
│      │                                │                        │         │
│ ──── SETIAP KALI ABSENSI ────                                            │
│      │                                │                        │         │
│      │ ③ GET /integrity/challenge ───>│───────────────────────>│         │
│      │ <── challenge (hex, 60s TTL) ──│<───────────────────────│         │
│      │                                │                        │         │
│      │ AppAttestPlugin.generateAssertion(                              │
│      │   keyId, SHA256(challenge))    │                        │         │
│      │ ← assertion (base64)           │                        │         │
│      │                                │                        │         │
│      │ ④ POST /gps-attendance ───────>│───────────────────────>│         │
│      │    {attendance_type, lat,      │   Verifikasi assertion  │         │
│      │     lng, integrity_platform:   │   (ECDSA + counter)     │         │
│      │     ios, integrity_token:      │   Buat attendance log   │         │
│      │     assertion,                 │   Buat approval request  │         │
│      │     integrity_key_id: keyId,   │                        │         │
│      │     integrity_challenge: hex}  │                        │         │
│      │ <── {attendance_log,           │<── Issue upload token ──│         │
│      │      upload_token,             │                        │         │
│      │      upload_expires_in: 1800}  │                        │         │
│      │                                │                        │         │
│      │ ⑤ POST /gps-attendance/{id}   │                        │         │
│      │    /evidence ─────────────────>│───────────────────────>│         │
│      │    X-Upload-Token: <token>     │   Simpan foto + note   │         │
│      │    multipart: front_photo,     │   Update status        │         │
│      │    back_photos, attachments,   │                        │         │
│      │    note                        │                        │         │
│      │ <── {metadata} ────────────────│<───────────────────────│         │
│      │                                │                        │         │
└──────────────────────────────────────────────────────────────────────────┘
```

**Poin penting:**
- **Attestation** (langkah ①–②) dilakukan **per (device, company)**. Backend menyimpan public key dan sign_count=0.
- **Assertion** (langkah ③–④) dilakukan **setiap kali** submit absensi. Backend memverifikasi ECDSA signature dan memastikan counter meningkat.
- Upload token valid **30 menit**. Evidence harus diupload dalam rentang waktu tersebut.
- Verifikasi App Attest dilakukan **sepenuhnya offline** di backend menggunakan Apple Root CA — tidak ada panggilan ke server Apple.

---

## 2. Konsep Kunci: Lingkup Registrasi Key

Sebelum masuk ke langkah-langkah implementasi, penting memahami **di mana dan bagaimana** App Attest key disimpan oleh backend.

### 2.1 — Arsitektur Penyimpanan

```
┌─────────────────────────────────────────────────────────────────┐
│                     ARSITEKTUR DEVICE ATTEST KEY                │
│                                                                 │
│  Perangkat A (iPhone user)           Perangkat B (iPad user)    │
│  ┌─────────────────────┐            ┌─────────────────────┐     │
│  │ generateKey()        │            │ generateKey()        │     │
│  │ → keyId_A1          │            │ → keyId_B1          │     │
│  │ attestKey(keyId_A1) │            │ attestKey(keyId_B1) │     │
│  └─────────────────────┘            └─────────────────────┘     │
│                                                                 │
│  ═══════════════════════════════════════════════════════════    │
│                         Backend                                 │
│  ┌──────────────────────────┐  ┌──────────────────────────┐    │
│  │  Company X DB             │  │  Company Y DB             │    │
│  │                          │  │                          │    │
│  │  device_attest_keys      │  │  device_attest_keys      │    │
│  │  ┌────────────────────┐  │  │  ┌────────────────────┐  │    │
│  │  │ keyId_A1 → user_1  │  │  │  │ keyId_A2 → user_1  │  │    │
│  │  │ keyId_B1 → user_2  │  │  │  │ keyId_B2 → user_2  │  │    │
│  │  └────────────────────┘  │  │  └────────────────────┘  │    │
│  └──────────────────────────┘  └──────────────────────────┘    │
│                                                                 │
│  Key disimpan PER COMPANY DB — bukan global.                    │
│  Satu user bisa punya banyak key (satu per device, per company).│
└─────────────────────────────────────────────────────────────────┘
```

### 2.2 — Fakta Kunci

| # | Fakta | Implikasi |
|---|-------|-----------|
| ① | `DeviceAttestKey` disimpan di **company DB** (perusahaan), bukan di auth-service global | Registrasi key harus dilakukan **per perusahaan** |
| ② | `KeyID` memiliki composite unique index `(company_id, key_id)` dalam satu company DB | Satu `keyId` hanya unik per perusahaan — key yang sama bisa terdaftar untuk perusahaan berbeda (jika company share DB) |
| ③ | `DCAppAttestService.generateKey()` bisa dipanggil **berkali-kali** | Satu device bisa memiliki **banyak key** — satu per perusahaan |
| ④ | `DCAppAttestService.attestKey(keyId, ...)` hanya bisa dipanggil **sekali per key** | Setiap key hanya bisa di-attest satu kali. Jika attestation gagal/diskon, key tersebut tidak bisa digunakan lagi |
| ⑤ | Key disimpan di **Secure Enclave** perangkat | Ganti perangkat = key baru. Reinstall app = tergantung iOS Keychain behavior |
| ⑥ | Challenge (`integrity_challenge`) sekali pakai dan terikat ke `userID` | Tidak bisa reuse challenge; harus ambil baru setiap kali |
| ⑦ | Lookup assertion di backend: `WHERE key_id = ? AND user_id = ? AND company_id = ?` | Key TIDAK bisa dipakai oleh user atau company berbeda. Ganti user/company = key baru |

### 2.3 — Ringkasan: Kapan Registrasi Dibutuhkan?

| Skenario | Perlu Registrasi Ulang? | Keterangan |
|----------|------------------------|------------|
| Pertama kali pakai app di device | ✅ Ya | `generateKey()` + `attestKey()` + `registerIosKey()` |
| Bergabung dengan perusahaan kedua | ✅ Ya (key baru) | `generateKey()` baru + `attestKey()` baru + `registerIosKey()` untuk perusahaan baru |
| Ganti device (iPhone baru) | ✅ Ya (semua company) | Semua key lama tidak bisa dipakai; generate ulang per company |
| **Logout akun A, login akun B di device yang sama** | ✅ Ya (semua company) | Key milik user A tidak bisa dipakai user B. Lihat [§13.7](#137--logout--ganti-akun-pada-device-yang-sama) |
| Reinstall app (iOS Keychain wipe) | ✅ Ya (semua company) | Sama seperti ganti device |
| Reinstall app (Keychain survive) | ❌ Tidak | Key masih ada; cukup panggil `registerIosKey()` untuk cek idempotensi |
| Submit absensi harian | ❌ Tidak | Hanya perlu `generateAssertion()` + `getChallenge()` |

### 2.4 — Model Penyimpanan Client

Client harus menyimpan key **per (user, company)**:

```dart
// Penyimpanan lokal (SharedPreferences / FlutterSecureStorage)
//
// Format key storage:
//   app_attest_key_id_<userId>_<companyId>  →  keyId (String)
//
// ⚠️  userId WAJIB disertakan — key TIDAK bisa dipakai lintas user.
//     Jika user logout dan user lain login di device yang sama,
//     key lama HARUS dibersihkan dan diganti key baru.
//
// Contoh:
//   app_attest_key_id_userA_comp123  →  "aGVsbG8..."  (key user A utk company 123)
//   app_attest_key_id_userB_comp123  →  "d29ybGQ..."  (key user B utk company 123)
//
// Setiap (user, company) punya key sendiri.
// Key yang sama TIDAK bisa dipakai untuk user berbeda
// karena backend memfilter assertion dengan user_id dan company_id.
```

---

## 3. Prasyarat

### Apple Developer
- Akun **Apple Developer Program** ($99/tahun)
- **App Attest** capability diaktifkan di App ID & Xcode project
- Perangkat **fisik** iOS 14+ (simulator tidak mendukung Secure Enclave)
- **Team ID** dan **Bundle ID** dicatat untuk konfigurasi backend

### Flutter App
- Flutter SDK 3.x
- `fio_backend_client` package
- **MethodChannel** bridge ke `DCAppAttestService` (lihat [dokumentasi Apple App Attest Flutter](../fio-web-desktop-backend/docs/apple_app_attest_flutter.md))

---

## 4. Instalasi

```yaml
# pubspec.yaml
dependencies:
  fio_backend_client:
    path: ../fio_backend_client
```

---

## 5. Langkah 1 — Setup MobileApiClient

```dart
import 'package:fio_backend_client/fio_backend_client.dart';

final client = MobileApiClient(
  authBaseUrl: 'https://auth.example.com',
  backendBaseUrl: 'https://backend.example.com',
  authHandler: MyAuthHandler(), // implementasi MobileApiAuthHandler
);

// Setelah login & pilih perusahaan:
await client.auth.issueCompanyToken(IssueCompanyTokenRequest(companyId: '...'));
client.setBackendBaseUrl(company.baseUrl);
client.setCurrentCompany(company.id);
```

Lihat [README.md](README.md) untuk detail alur autentikasi dan implementasi `MobileApiAuthHandler`.

---

## 6. Langkah 2 — Cek GPS Settings Perusahaan

Cek apakah perusahaan mewajibkan foto, lampiran, atau catatan:

```dart
final settings = await client.gpsAttendance.getSettings();

// settings.gpsFrontPhoto       → FieldRequirementStatus (required / optional / off)
// settings.gpsAdditionalPhoto  → FieldRequirementStatus
// settings.gpsNote             → FieldRequirementStatus
// settings.gpsAttachment       → FieldRequirementStatus
// settings.maxAttachmentNumber → int
// settings.maxAdditionalPhotoNumber → int
```

Gunakan ini untuk validasi UI — misalnya, jika `gpsFrontPhoto == FieldRequirementStatus.required`, tampilkan indikator wajib di form foto.

---

## 7. Langkah 3 — iOS App Attest: Registrasi Key

> **Dijalankan per (device, company)**, idealnya setelah login pertama kali di perusahaan tersebut.
> Jika pengguna sudah terdaftar di Company A lalu bergabung dengan Company B, ia harus menjalankan
> registrasi ulang dengan **key baru** (`generateKey()` baru) untuk Company B.
>
> Endpoint bersifat **idempotent per company DB** — memanggil ulang dengan key yang sudah terdaftar
> di perusahaan yang sama akan mengembalikan 200 tanpa verifikasi ulang.
>
> Lihat [Edge Cases](#13-edge-cases--multi-devicemulti-company) untuk detail multi-device dan multi-company.

```dart
/// Registrasi App Attest key untuk SATU perusahaan.
/// Panggil fungsi ini setiap kali user login ke perusahaan yang belum memiliki key.
///
/// [companyId] — ID perusahaan yang sedang aktif (dari client.currentCompanyId).
///
/// Key disimpan dengan format: app_attest_key_id_<userId>_<companyId>
Future<void> registerAppAttestKeyForCompany(String companyId) async {
  // 0. Cek apakah company ini sudah punya key terdaftar
  final existingKeyId = await getKeyIdForCompany(companyId);
  if (existingKeyId != null) {
    // Sudah ada — cek idempotensi ke backend
    try {
      await client.integrity.registerIosKey(IosAttestRequest(
        keyId: existingKeyId,
        attestation: 'already_registered', // tidak dipakai jika key sudah ada
        challenge: '0000000000000000000000000000000000000000000000000000000000000000',
      ));
      return; // Key masih valid, tidak perlu registrasi ulang
    } on ApiError {
      // Key mungkin sudah di-revoke dari sisi server — hapus & registrasi ulang
      await clearKeyIdForCompany(companyId);
    }
  }

  // 1. Dapatkan challenge dari backend
  final challengeResp = await client.integrity.getChallenge();
  // challengeResp.challenge  → 64-char hex string
  // challengeResp.expiresIn  → 60 detik

  // 2. Generate key BARU di Secure Enclave (via MethodChannel)
  //    Setiap company mendapat key sendiri.
  final keyId = await AppAttestPlugin.generateKey();

  // 3. Attest key ke Apple (via MethodChannel)
  final clientDataHash = sha256hex(challengeResp.challenge);
  final attestation = await AppAttestPlugin.attestKey(
    keyId: keyId,
    clientDataHash: clientDataHash,
  );

  // 4. Kirim ke backend untuk registrasi
  try {
    await client.integrity.registerIosKey(IosAttestRequest(
      keyId: keyId,
      attestation: attestation, // base64
      challenge: challengeResp.challenge,
    ));

    // 5. Simpan keyId UNTUK COMPANY INI
    await saveKeyIdForCompany(companyId, keyId);
  } on ApiError catch (e) {
    if (e.message.contains('revoked')) {
      // Key sudah direvoke — coba lagi (generate key baru)
      await clearKeyIdForCompany(companyId);
      return registerAppAttestKeyForCompany(companyId);
    } else {
      rethrow;
    }
  }
}

// ── Storage helpers ────────────────────────────────────────────────────────

/// Simpan keyId untuk (user, company) tertentu.
Future<void> saveKeyIdForCompany(String companyId, String keyId) async {
  final userId = getCurrentUserId(); // dari session / token claims
  await storage.write(key: 'app_attest_key_id_${userId}_$companyId', value: keyId);
}

/// Ambil keyId untuk (user, company) tertentu.
Future<String?> getKeyIdForCompany(String companyId) async {
  final userId = getCurrentUserId();
  return storage.read(key: 'app_attest_key_id_${userId}_$companyId');
}

/// Hapus keyId untuk (user, company) tertentu.
Future<void> clearKeyIdForCompany(String companyId) async {
  final userId = getCurrentUserId();
  await storage.delete(key: 'app_attest_key_id_${userId}_$companyId');
}

/// Hapus SEMUA App Attest key yang tersimpan di lokal (dipanggil saat logout).
Future<void> clearAllAttestKeys() async {
  final allKeys = await storage.getAllKeys();
  for (final key in allKeys) {
    if (key.startsWith('app_attest_key_id_')) {
      await storage.delete(key: key);
    }
  }
}
```

---

## 8. Langkah 4 — iOS App Attest: Dapatkan Challenge

```dart
final challengeResp = await client.integrity.getChallenge();
// challengeResp.challenge  → hex string, 64 karakter
// challengeResp.expiresIn  → 60 detik
```

> ⚠️ Challenge hanya valid **60 detik**. Generate assertion harus dilakukan segera setelah mendapatkan challenge.

---

## 9. Langkah 5 — Submit GPS Attendance dengan Assertion

```dart
import 'package:fio_backend_client/fio_backend_client.dart';

Future<SubmitGpsAttendanceResponse> submitGpsAttendance({
  required AttendanceType type,
  required double latitude,
  required double longitude,
  String? note,
  String? deviceName,
}) async {
  // 1. Dapatkan challenge
  final challengeResp = await client.integrity.getChallenge();

  // 2. Generate assertion via MethodChannel
  final companyId = client.currentCompanyId!;
  final keyId = await getKeyIdForCompany(companyId); // dari langkah registrasi
  final clientDataHash = sha256hex(challengeResp.challenge);
  final assertion = await AppAttestPlugin.generateAssertion(
    keyId: keyId,
    clientDataHash: clientDataHash,
  );

  // 3. Submit
  final response = await client.gpsAttendance.submit(
    SubmitGpsAttendanceRequest(
      attendanceType: type,
      latitude: latitude,
      longitude: longitude,
      note: note,
      deviceName: deviceName,
      integrityPlatform: IntegrityPlatform.ios,
      integrityToken: assertion,        // base64 assertion dari generateAssertion
      integrityKeyId: keyId,            // keyId dari generateKey
      integrityChallenge: challengeResp.challenge,
    ),
  );

  // response.attendanceLog    → AttendanceLog
  // response.uploadToken      → String (simpan untuk upload evidence)
  // response.uploadExpiresIn  → int (detik, biasanya 1800 = 30 menit)
  // response.permissionRequest → Map? (approval workflow, null jika tidak perlu approval)

  return response;
}
```

### AttendanceType

```dart
AttendanceType.checkIn    // CHECK_IN
AttendanceType.checkOut   // CHECK_OUT
AttendanceType.breakIn    // BREAK_IN
AttendanceType.breakOut   // BREAK_OUT
AttendanceType.overtimeIn // OVERTIME_IN
AttendanceType.overtimeOut// OVERTIME_OUT
```

### IntegrityPlatform

```dart
IntegrityPlatform.android  // Play Integrity
IntegrityPlatform.ios      // App Attest
IntegrityPlatform.debug    // bypass (development only)
```

---

## 10. Langkah 6 — Upload Evidence (Foto, Lampiran)

Evidence harus diupload dalam **30 menit** setelah attendance submission.

```dart
import 'package:dio/dio.dart';

Future<void> uploadEvidence({
  required String attendanceLogId,
  required String uploadToken,
  required File frontPhotoFile,
  List<File>? backPhotoFiles,
  List<File>? attachmentFiles,
  String? note,
}) async {
  final frontPhoto = frontPhotoFile.existsSync()
      ? await MultipartFile.fromFile(
          frontPhotoFile.path,
          filename: 'front_photo.jpg',
        )
      : null;

  final backPhotos = backPhotoFiles
      ?.where((f) => f.existsSync())
      .map((f) => MultipartFile.fromFile(f.path, filename: f.path.split('/').last))
      .toList();

  final attachments = attachmentFiles
      ?.where((f) => f.existsSync())
      .map((f) => MultipartFile.fromFile(f.path, filename: f.path.split('/').last))
      .toList();

  await client.gpsAttendance.uploadEvidence(
    attendanceLogId: attendanceLogId,
    uploadToken: uploadToken,
    frontPhoto: frontPhoto,
    backPhotos: backPhotos,
    attachments: attachments,
    note: note,
    onSendProgress: (sent, total) {
      // Progress tracking (opsional)
      final progress = sent / total;
      print('Upload progress: ${(progress * 100).toStringAsFixed(0)}%');
    },
  );
}
```

### Catatan Penting Evidence

- Upload token **sekali pakai** — setelah evidence terupload, token hangus.
- Jika evidence diupload **setelah** 30 menit, endpoint akan mengembalikan error `upload token is invalid or expired`.
- Bukti yang didukung: `front_photo` (selfie), `back_photos` (foto tambahan), `attachments` (file lampiran), `note` (teks).
- Validasi `required`/`optional`/`off` berdasarkan `getSettings()` sebaiknya dilakukan di sisi Flutter **sebelum** memanggil endpoint evidence.

---

## 11. Langkah 7 — Debug Mode (Development)

Untuk development tanpa App Attest:

```dart
final response = await client.gpsAttendance.submit(
  SubmitGpsAttendanceRequest(
    attendanceType: AttendanceType.checkIn,
    latitude: -6.2088,
    longitude: 106.8456,
    debug: true, // ← bypass integrity check
  ),
);
```

> ⚠️ `debug: true` hanya berfungsi jika environment backend adalah `development`. Di production, flag ini diabaikan dan request akan ditolak.

---

## 12. Contoh Lengkap

```dart
import 'package:dio/dio.dart';
import 'package:fio_backend_client/fio_backend_client.dart';

/// Service class untuk GPS attendance dengan App Attest.
/// Mendukung multi-company: setiap company mendapat App Attest key sendiri.
class GpsAttendanceManager {
  final MobileApiClient _client;
  final AppAttestPlugin _appAttest; // MethodChannel bridge

  GpsAttendanceManager(this._client, this._appAttest);

  /// Registrasi App Attest key untuk company yang sedang aktif.
  /// Aman dipanggil berkali-kali — cek idempotensi internal.
  Future<void> registerDeviceForCurrentCompany() async {
    final companyId = _client.currentCompanyId;
    if (companyId == null) throw StateError('Tidak ada company aktif');

    final storedKeyId = await _getKeyIdForCompany(companyId);
    if (storedKeyId != null) {
      // Cek idempotensi — key sudah terdaftar?
      try {
        await _client.integrity.registerIosKey(IosAttestRequest(
          keyId: storedKeyId,
          attestation: 'already_registered',
          challenge: '0000000000000000000000000000000000000000000000000000000000000000',
        ));
        return; // Sudah OK
      } on ApiError {
        // Key tidak valid — hapus dan registrasi ulang
        await _clearKeyIdForCompany(companyId);
      }
    }

    // Registrasi baru
    final challengeResp = await _client.integrity.getChallenge();
    final keyId = await _appAttest.generateKey();
    final clientDataHash = _sha256hex(challengeResp.challenge);
    final attestation = await _appAttest.attestKey(
      keyId: keyId,
      clientDataHash: clientDataHash,
    );

    await _client.integrity.registerIosKey(IosAttestRequest(
      keyId: keyId,
      attestation: attestation,
      challenge: challengeResp.challenge,
    ));

    await _saveKeyIdForCompany(companyId, keyId);
  }

  /// Submit absensi GPS + upload evidence.
  Future<AttendanceLog> submitAttendance({
    required AttendanceType type,
    required double lat,
    required double lng,
    String? note,
    String? deviceName,
    File? frontPhotoFile,
    List<File>? backPhotoFiles,
    List<File>? attachmentFiles,
  }) async {
    // 1. Challenge
    final challengeResp = await _client.integrity.getChallenge();

    // 2. Assertion — gunakan key untuk company yang sedang aktif
    final companyId = _client.currentCompanyId!;
    final keyId = await _getKeyIdForCompany(companyId);
    if (keyId == null) throw StateError('App Attest key belum terdaftar untuk company $companyId');
    final clientDataHash = _sha256hex(challengeResp.challenge);
    final assertion = await _appAttest.generateAssertion(
      keyId: keyId,
      clientDataHash: clientDataHash,
    );

    // 3. Submit
    final response = await _client.gpsAttendance.submit(
      SubmitGpsAttendanceRequest(
        attendanceType: type,
        latitude: lat,
        longitude: lng,
        note: note,
        deviceName: deviceName,
        integrityPlatform: IntegrityPlatform.ios,
        integrityToken: assertion,
        integrityKeyId: keyId,
        integrityChallenge: challengeResp.challenge,
      ),
    );

    // 4. Upload evidence (jika ada)
    if (response.uploadToken != null) {
      await _uploadEvidenceIfNeeded(
        attendanceLogId: response.attendanceLog.id,
        uploadToken: response.uploadToken!,
        frontPhotoFile: frontPhotoFile,
        backPhotoFiles: backPhotoFiles,
        attachmentFiles: attachmentFiles,
        note: note,
      );
    }

    return response.attendanceLog;
  }

  Future<void> _uploadEvidenceIfNeeded({
    required String attendanceLogId,
    required String uploadToken,
    File? frontPhotoFile,
    List<File>? backPhotoFiles,
    List<File>? attachmentFiles,
    String? note,
  }) async {
    final hasFiles = frontPhotoFile != null ||
        (backPhotoFiles?.isNotEmpty ?? false) ||
        (attachmentFiles?.isNotEmpty ?? false);

    if (!hasFiles && note == null) return;

    await _client.gpsAttendance.uploadEvidence(
      attendanceLogId: attendanceLogId,
      uploadToken: uploadToken,
      frontPhoto: frontPhotoFile != null
          ? await MultipartFile.fromFile(frontPhotoFile.path)
          : null,
      backPhotos: backPhotoFiles
          ?.map((f) => MultipartFile.fromFile(f.path))
          .toList(),
      attachments: attachmentFiles
          ?.map((f) => MultipartFile.fromFile(f.path))
          .toList(),
      note: note,
    );
  }

  // ── Storage helpers (gunakan SharedPreferences / FlutterSecureStorage) ──

  String get _currentUserId => /* userId dari session JWT claims */ '';

  /// Simpan keyId untuk (user, company) tertentu.
  Future<void> _saveKeyIdForCompany(String companyId, String keyId) async {
    await storage.write(key: 'app_attest_key_id_${_currentUserId}_$companyId', value: keyId);
  }

  /// Ambil keyId untuk (user, company) tertentu.
  Future<String?> _getKeyIdForCompany(String companyId) async {
    return storage.read(key: 'app_attest_key_id_${_currentUserId}_$companyId');
  }

  /// Hapus keyId untuk (user, company) tertentu.
  Future<void> _clearKeyIdForCompany(String companyId) async {
    await storage.delete(key: 'app_attest_key_id_${_currentUserId}_$companyId');
  }

  /// Hapus SEMUA App Attest key di lokal (panggil saat logout).
  Future<void> _clearAllAttestKeys() async {
    final allKeys = await storage.getAllKeys();
    for (final key in allKeys) {
      if (key.startsWith('app_attest_key_id_')) {
        await storage.delete(key: key);
      }
    }
  }

  // ── SHA256 helper ────────────────────────────────────────────────────────

  String _sha256hex(String input) { /* ... */ }
}
```

---

## 13. Edge Cases & Multi-Device/Multi-Company

Bagian ini menjelaskan bagaimana menangani skenario dunia nyata: user dengan banyak perangkat, banyak perusahaan, dan pergantian perangkat.

### 13.1 — User dengan Banyak Perangkat

```
┌─────────────────────────────────────────────────────────────────┐
│                 MULTI-DEVICE: SATU USER, DUA DEVICE              │
│                                                                 │
│  iPhone user                     iPad user                       │
│  ┌────────────────────┐         ┌────────────────────┐          │
│  │ generateKey()       │         │ generateKey()       │          │
│  │ → keyId_iphone     │         │ → keyId_ipad       │          │
│  │ attestKey(...)      │         │ attestKey(...)      │          │
│  └────────────────────┘         └────────────────────┘          │
│           │                              │                       │
│           ▼                              ▼                       │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │              Company X DB — device_attest_keys           │    │
│  │  ┌──────────────────────────────────────────────────┐   │    │
│  │  │ keyId_iphone → user_1, sign_count: 42             │   │    │
│  │  │ keyId_ipad   → user_1, sign_count: 7              │   │    │
│  │  └──────────────────────────────────────────────────┘   │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                 │
│  ✅ Kedua device berfungsi independen.                           │
│  ✅ Masing-masing punya sign_count sendiri.                     │
│  ✅ Tidak ada konflik — keyId berbeda.                          │
└─────────────────────────────────────────────────────────────────┘
```

**Yang terjadi:**
- Setiap device menghasilkan key pair **berbeda** di Secure Enclave masing-masing → `keyId` berbeda.
- Backend menyimpan **semua** key untuk user yang sama dalam satu company DB.
- Setiap assertion diverifikasi dengan public key yang sesuai dengan `keyId` yang dikirim.
- **Tidak ada langkah khusus** — setiap device cukup menjalankan `registerAppAttestKeyForCompany()` secara independen.

### 13.2 — User dengan Banyak Perusahaan

```
┌─────────────────────────────────────────────────────────────────┐
│          MULTI-COMPANY: SATU DEVICE, DUA PERUSAHAAN              │
│                                                                 │
│  iPhone user                                                    │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ Untuk Company X:                                         │    │
│  │   generateKey() → keyId_X                               │    │
│  │   attestKey(keyId_X, challenge_X) → attestation_X       │    │
│  │   registerIosKey() → tersimpan di Company X DB           │    │
│  │                                                         │    │
│  │ Untuk Company Y:                                         │    │
│  │   generateKey() → keyId_Y  ← KEY BERBEDA!               │    │
│  │   attestKey(keyId_Y, challenge_Y) → attestation_Y       │    │
│  │   registerIosKey() → tersimpan di Company Y DB           │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                 │
│  ═══════════════════════════════════════════════════════════    │
│  Company X DB                    Company Y DB                    │
│  ┌────────────────────┐         ┌────────────────────┐          │
│  │ keyId_X → user_1   │         │ keyId_Y → user_1   │          │
│  └────────────────────┘         └────────────────────┘          │
│                                                                 │
│  ⚠️  Key TIDAK BISA dipakai bersama antar company               │
│     karena tabel device_attest_keys ada di company DB           │
│     masing-masing, bukan di database global.                    │
└─────────────────────────────────────────────────────────────────┘
```

**Yang terjadi:**
- `DeviceAttestKey` disimpan di **company DB** (perusahaan), bukan di database global.
- User harus registrasi **per perusahaan**. Setiap perusahaan mendapat key sendiri.
- `generateKey()` bisa dipanggil berkali-kali — setiap panggilan menghasilkan key pair baru.
- Client menyimpan mapping: `app_attest_key_id_<userId>_<companyId>` → `keyId`.

**Kode integrasi saat login/pindah perusahaan:**

```dart
/// Dipanggil setiap kali user login ke suatu company.
Future<void> onCompanySelected(String companyId) async {
  client.setCurrentCompany(companyId);
  client.setBackendBaseUrl(company.baseUrl);

  // Pastikan App Attest key sudah terdaftar untuk company ini
  await gpsManager.registerDeviceForCurrentCompany();
}
```

### 13.3 — Ganti Perangkat (iPhone Baru)

```
┌─────────────────────────────────────────────────────────────────┐
│                  SWITCH DEVICE: IPHONE LAMA → BARU               │
│                                                                 │
│  iPhone Lama                     iPhone Baru                     │
│  ┌────────────────────┐         ┌────────────────────┐          │
│  │ keyId_old → DB     │         │ (Secure Enclave     │          │
│  │ (sign_count: 57)   │         │  baru, key hilang)  │          │
│  └────────────────────┘         │                      │          │
│                                 │ generateKey()        │          │
│                                 │ → keyId_new          │          │
│                                 │ attestKey(...)       │          │
│                                 │ registerIosKey()     │          │
│                                 └────────────────────┘          │
│                                                                 │
│  Company DB setelah migrasi:                                    │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │ keyId_old → user_1, sign_count: 57  (orphaned, tidak    │    │
│  │ keyId_new → user_1, sign_count: 0   dipakai lagi)      │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                 │
│  ⚠️  Key lama TETAP ADA di DB (tidak otomatis dihapus).         │
│     Tidak masalah — tidak ada yang bisa pakai key itu            │
│     karena private key hanya ada di perangkat lama.             │
└─────────────────────────────────────────────────────────────────┘
```

**Yang perlu dilakukan:**
1. Di perangkat baru, tidak ada key tersimpan di local storage.
2. Panggil `registerAppAttestKeyForCompany()` untuk setiap company yang user ikuti.
3. Fungsi akan otomatis `generateKey()` + `attestKey()` + `registerIosKey()` untuk setiap company.
4. Key lama di backend menjadi orphaned — tidak masalah karena private key hanya ada di perangkat lama.

### 13.4 — Reinstall App

| Skenario | Key di Secure Enclave | Key di Local Storage | Tindakan |
|----------|----------------------|---------------------|----------|
| **Hapus & install ulang** (iOS 15+) | ✅ **Mungkin survive** (tergantung iOS Keychain behavior dengan access group) | ❌ Hilang (SharedPreferences wipe) | Coba `getKeyIdForCompany()` → jika null, registrasi ulang |
| **Hapus & install ulang** (iOS 14) | ❌ Hilang | ❌ Hilang | Registrasi ulang semua company |
| **Update app** (App Store/TestFlight) | ✅ Survive | ✅ Survive | Tidak perlu tindakan |

> **Catatan:** Mulai iOS 15, keychain items bisa survive app uninstall jika menggunakan **Keychain Access Group** yang dikonfigurasi dengan benar. Namun jangan mengandalkan ini — selalu fallback ke registrasi ulang.

**Kode yang aman:**

```dart
/// Dipanggil saat app start.
Future<void> ensureKeysForAllCompanies(List<String> companyIds) async {
  for (final companyId in companyIds) {
    final keyId = await getKeyIdForCompany(companyId);

    if (keyId == null) {
      // Key hilang (mungkin reinstall) — registrasi ulang
      client.setCurrentCompany(companyId);
      await registerAppAttestKeyForCompany(companyId);
      continue;
    }

    // Key ada di local storage — cek apakah masih valid di backend
    client.setCurrentCompany(companyId);
    try {
      await client.integrity.registerIosKey(IosAttestRequest(
        keyId: keyId,
        attestation: 'already_registered',
        challenge: '0000000000000000000000000000000000000000000000000000000000000000',
      ));
      // Key masih valid — OK
    } on ApiError {
      // Key tidak valid (di-revoke / company DB reset) — registrasi ulang
      await clearKeyIdForCompany(companyId);
      await registerAppAttestKeyForCompany(companyId);
    }
  }
}
```

### 13.5 — Sign-Count Conflict (Concurrent Requests)

```
┌─────────────────────────────────────────────────────────────────┐
│                SIGN-COUNT CONFLICT (HTTP 409)                    │
│                                                                 │
│  Thread A                        Thread B                        │
│  ┌────────────────────┐         ┌────────────────────┐          │
│  │ generateAssertion() │         │ generateAssertion() │          │
│  │ → sign_count: 5    │         │ → sign_count: 5    │ ← SAMA!  │
│  │ POST /gps-attend..  │         │ POST /gps-attend..  │          │
│  └────────────────────┘         └────────────────────┘          │
│           │                              │                       │
│           ▼                              ▼                       │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │  Backend: UPDATE sign_count=5 → 6                        │    │
│  │  Thread A: RowsAffected=1 ✅ (prev=5, new=6)             │    │
│  │  Thread B: RowsAffected=0 ❌ (prev sudah jadi 6)         │    │
│  │  → HTTP 409 Concurrent submission detected              │    │
│  └─────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

Backend menggunakan **optimistic locking** pada kolom `sign_count`. Jika dua request concurrent menggunakan assertion dengan counter yang sama, hanya satu yang berhasil. Yang kedua mendapat HTTP 409.

**Cara menangani:**

```dart
Future<AttendanceLog> submitWithRetry({ /* params */ }) async {
  int retries = 0;
  while (retries < 3) {
    try {
      return await submitAttendance(/* params */);
    } on ApiError catch (e) {
      if (e.message.contains('concurrent submission')) {
        retries++;
        if (retries >= 3) rethrow;
        // Dapatkan challenge baru, assertion baru, dan retry
        await Future.delayed(Duration(milliseconds: 200 * retries));
        continue;
      }
      rethrow;
    }
  }
  throw ApiError(/* ... */); // Tidak akan sampai sini
}
```

### 13.6 — Decision Matrix: Kapan Registrasi Dibutuhkan?

```
┌─────────────────────────────────────────────────────────────────┐
│                    DECISION MATRIX                               │
│                                                                 │
│  App start                                                      │
│      │                                                          │
│      ▼                                                          │
│  Ada keyId di local storage utk company ini?                    │
│      │                                                          │
│      ├── Ya ──> Cek idempotensi ke backend ──> Valid?          │
│      │                                            │              │
│      │                                     Ya ───┴──> ✅ OK     │
│      │                                     Tidak ───> 🔄        │
│      │                                                  │        │
│      └── Tidak ────────────────────────────────────────┘        │
│                                                         │        │
│                                                         ▼        │
│                                                    🔄 Registrasi │
│                                                    generateKey() │
│                                                    attestKey()   │
│                                                    registerKey() │
│                                                                 │
│  ═══════════════════════════════════════════════════════════    │
│                                                                 │
│  Submit absensi                                                 │
│      │                                                          │
│      ▼                                                          │
│  getChallenge() → generateAssertion() → submit()                │
│      │                                            │              │
│      │                                    200 ───┴──> ✅ OK     │
│      │                                    409 ───┬──> 🔄 Retry  │
│      │                                    403 ───┴──> 🔄        │
│      │                                            Registrasi    │
│      │                                            ulang         │
└─────────────────────────────────────────────────────────────────┘
```

### 13.7 — Logout & Ganti Akun pada Device yang Sama

Skenario: User A logout, lalu User B login di **device yang sama**.

```
┌─────────────────────────────────────────────────────────────────┐
│            LOGOUT A → LOGIN B (DEVICE YANG SAMA)                 │
│                                                                 │
│  User A login                              User B login          │
│  ┌────────────────────┐                   ┌────────────────────┐ │
│  │ generateKey()       │                   │ generateKey()       │ │
│  │ → keyId_A          │                   │ → keyId_B          │ │
│  │ attestKey(keyId_A) │                   │ attestKey(keyId_B) │ │
│  │ registerIosKey()   │                   │ registerIosKey()   │ │
│  └────────────────────┘                   └────────────────────┘ │
│           │                                         │            │
│           ▼                                         ▼            │
│  ┌─────────────────────────────────────────────────────────┐    │
│  │              Company X DB — device_attest_keys           │    │
│  │  ┌──────────────────────────────────────────────────┐   │    │
│  │  │ keyId_A → user_A, sign_count: 12                 │   │    │
│  │  │ keyId_B → user_B, sign_count: 0                  │   │    │
│  │  └──────────────────────────────────────────────────┘   │    │
│  └─────────────────────────────────────────────────────────┘    │
│                                                                 │
│  ⚠️  Key TIDAK BOLEH dipakai lintas user maupun company.        │
│     Lookup assertion: WHERE key_id=? AND user_id=? AND          │
│     company_id=?                                                │
│     → keyId_A hanya bisa dipakai user_A di company tersebut.   │
│     → User B WAJIB generateKey() baru + attest + register.     │
└─────────────────────────────────────────────────────────────────┘
```

**Mengapa key tidak bisa dipakai bersama:**

Saat submit GPS attendance, backend melakukan lookup assertion:

```go
// gps_attendance_handler.go — resolveIntegrity()
cDB.Where("key_id = ? AND user_id = ? AND company_id = ? AND is_revoked = false",
    req.IntegrityKeyID, userID, companyID).First(&attestKey)
```

Jika user B mengirim `keyId_A` (milik user A), lookup akan gagal karena `user_id` tidak cocok. Backend akan mengembalikan error:

> `ios device key not registered — call POST /mobile/v1/ios/attest first`

**Yang harus dilakukan saat logout:**

```dart
/// Dipanggil saat user logout.
Future<void> onLogout() async {
  // 1. Hapus SEMUA App Attest key dari local storage
  await gpsManager._clearAllAttestKeys();

  // 2. Clear token, session, dll
  await authHandler.clearAllTokens();
  client.clearCurrentCompany();
}
```

**Yang harus dilakukan saat login user baru:**

```dart
/// Dipanggil setelah user berhasil login + pilih company.
Future<void> onLoginComplete() async {
  final companyId = client.currentCompanyId!;

  // Cek apakah key sudah ada untuk (user ini, company ini)
  final keyId = await getKeyIdForCompany(companyId);

  if (keyId == null) {
    // Belum ada → registrasi baru
    // generateKey() akan membuat key pair BARU di Secure Enclave
    await registerAppAttestKeyForCompany(companyId);
  } else {
    // Ada → cek idempotensi
    await ensureKeyStillValid(companyId, keyId);
  }
}
```

> **Catatan:** Karena storage key sekarang menyertakan `userId` (`app_attest_key_id_<userId>_<companyId>`), user B tidak akan menemukan key user A di local storage. Ini mencegah pemakaian key lintas user secara otomatis.

**Ringkasan langkah:**

| # | Langkah | Keterangan |
|---|---------|------------|
| 1 | Logout → `clearAllAttestKeys()` | Hapus semua key dari local storage |
| 2 | Login user baru → `getKeyIdForCompany(companyId)` | Akan return `null` karena storage key pakai `userId` baru |
| 3 | `generateKey()` baru | Key pair baru di Secure Enclave (keyId berbeda dari user sebelumnya) |
| 4 | `attestKey()` + `registerIosKey()` | Registrasi key baru ke backend dengan userID baru |
| 5 | Submit absensi normal | Gunakan `generateAssertion()` dengan keyId baru |

---

## 14. Error Handling

| Error | HTTP Status | Endpoint | Penyebab | Solusi |
|-------|-------------|----------|----------|--------|
| `integrity_platform is required` | 400 | POST /gps-attendance | Tidak mengirim `integrityPlatform` | Pastikan field ada |
| `integrity_challenge is required` | 400 | POST /gps-attendance | Tidak memanggil `getChallenge()` atau challenge expired | Panggil `getChallenge()` tepat sebelum submit |
| `integrity_token is required for android` | 400 | POST /gps-attendance | Platform `android` tapi tidak ada token | Kirim Play Integrity token |
| `integrity_key_id and integrity_token (assertion) are required for ios` | 400 | POST /gps-attendance | Platform `ios` tapi tidak ada keyId/assertion | Sertakan assertion + keyId |
| `ios device key not registered` | 403 | POST /gps-attendance | Key belum diregistrasi untuk (user, company) ini | Panggil `registerIosKey()` terlebih dahulu. Pastikan key terdaftar untuk company yang aktif |
| `this device key has been revoked` | 403 | POST /ios/attest | Key sudah di-revoke di server | Hapus key dari local storage, lakukan `generateKey()` baru + registrasi ulang |
| `device integrity check failed` | 403 | POST /gps-attendance | Assertion tidak valid atau perangkat tidak asli | Cek key validity, register ulang jika perlu |
| `concurrent submission detected, please retry` | 409 | POST /gps-attendance | Dua request concurrent dengan assertion yang sama (sign_count conflict) | Retry dengan challenge baru + assertion baru. Lihat [13.5](#135--sign-count-conflict-concurrent-requests) |
| `upload token is invalid or expired` | 403 | POST /gps-attendance/:id/evidence | Upload token kadaluarsa (30 menit) atau sudah dipakai | Tidak bisa — harus submit ulang absensi |
| `X-Upload-Token header is required` | 403 | POST /gps-attendance/:id/evidence | Tidak menyertakan upload token header | Simpan `response.uploadToken` dan kirim sebagai header |
| `attendance log not found or evidence already submitted` | 403 | POST /gps-attendance/:id/evidence | Evidence sudah diupload atau attendance log bukan milik user | Cek ulang — evidence hanya bisa dikirim sekali |
| `front_photo is required` | 422 | POST /gps-attendance/:id/evidence | Perusahaan mewajibkan front photo tapi tidak dikirim | Cek `getSettings()` dan validasi di UI |
| `back_photos is required` | 422 | POST /gps-attendance/:id/evidence | Perusahaan mewajibkan additional photo tapi tidak dikirim | Cek `gpsAdditionalPhoto` dari `getSettings()` |
| `note is required` | 422 | POST /gps-attendance/:id/evidence | Perusahaan mewajibkan catatan tapi tidak dikirim | Cek `gpsNote` dari `getSettings()` |
| `attachments is required` | 422 | POST /gps-attendance/:id/evidence | Perusahaan mewajibkan lampiran tapi tidak dikirim | Cek `gpsAttachment` dari `getSettings()` |
| `too many attachments: max N allowed` | 422 | POST /gps-attendance/:id/evidence | Jumlah lampiran melebihi batas | Cek `maxAttachmentNumber` dari `getSettings()` |
| `service temporarily unavailable (rate limited)` | 503 | POST /gps-attendance | Apple rate limit pada Play Integrity / App Attest | Tunggu beberapa saat dan retry |

---

## 15. Referensi Model

### SubmitGpsAttendanceRequest

| Field | Type | Required | Keterangan |
|-------|------|----------|------------|
| `attendanceType` | `AttendanceType` | ✅ | CHECK_IN, CHECK_OUT, dll |
| `latitude` | `double` | ✅ | GPS latitude |
| `longitude` | `double` | ✅ | GPS longitude |
| `note` | `String?` | ❌ | Catatan |
| `deviceName` | `String?` | ❌ | Nama perangkat |
| `integrityPlatform` | `IntegrityPlatform?` | ❌ | `android`, `ios`, `debug` |
| `integrityToken` | `String?` | iOS ✅ | Assertion dari `generateAssertion()` |
| `integrityChallenge` | `String?` | ✅ (jika ada platform) | Challenge hex dari `getChallenge()` |
| `integrityKeyId` | `String?` | iOS ✅ | Key ID dari `generateKey()` |
| `debug` | `bool` | ❌ | `true` untuk bypass integrity (dev only) |

### SubmitGpsAttendanceResponse

| Field | Type | Keterangan |
|-------|------|------------|
| `attendanceLog` | `AttendanceLog` | Record absensi yang dibuat |
| `permissionRequest` | `Map<String, dynamic>?` | Approval request (jika perlu approval) |
| `uploadToken` | `String?` | Token untuk upload evidence, valid 30 menit |
| `uploadExpiresIn` | `int?` | Detik sampai token expired (1800) |

### GpsSettingsResponse

| Field | Type | Keterangan |
|-------|------|------------|
| `gpsFrontPhoto` | `FieldRequirementStatus` | `required` / `optional` / `off` |
| `gpsAdditionalPhoto` | `FieldRequirementStatus` | `required` / `optional` / `off` |
| `gpsNote` | `FieldRequirementStatus` | `required` / `optional` / `off` |
| `gpsAttachment` | `FieldRequirementStatus` | `required` / `optional` / `off` |
| `maxAttachmentNumber` | `int` | Maksimum jumlah lampiran |
| `maxAdditionalPhotoNumber` | `int` | Maksimum jumlah foto tambahan |

### IntegrityChallengeResponse

| Field | Type | Keterangan |
|-------|------|------------|
| `challenge` | `String` | 64-char hex nonce |
| `expiresIn` | `int` | TTL dalam detik (60) |

### IosAttestRequest

| Field | Type | Keterangan |
|-------|------|------------|
| `keyId` | `String` | Key ID dari `DCAppAttestService.generateKey()` |
| `attestation` | `String` | base64 attestation object dari `attestKey()` |
| `challenge` | `String` | Challenge hex dari `getChallenge()` |

---

## Rujukan

- [Dokumentasi Apple App Attest Flutter (backend)](../fio-web-desktop-backend/docs/apple_app_attest_flutter.md)
- [README fio_backend_client](README.md)
- [Apple App Attest Documentation](https://developer.apple.com/documentation/devicecheck/dcappattestservice)
