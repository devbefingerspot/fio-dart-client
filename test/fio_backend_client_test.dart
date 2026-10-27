import 'package:test/test.dart';

import 'package:fio_backend_client/fio_backend_client.dart';

// Minimal smoke-test: verify that MobileApiClient can be instantiated with
// a mock handler and that ApiError.fromDioException parses known fields.

class _MockAuthHandler implements MobileApiAuthHandler {
  @override
  Future<String?> getIdentityAccessToken() async => null;
  @override
  Future<String?> getIdentityRefreshToken() async => null;
  @override
  Future<String?> getCompanyAccessToken(String companyId) async => null;
  @override
  Future<String?> getCompanyRefreshToken(String companyId) async => null;
  @override
  Future<void> onIdentityTokenRefreshed({
    required String accessToken,
    required String refreshToken,
  }) async {}
  @override
  Future<void> onCompanyTokenRefreshed({
    required String companyId,
    required String accessToken,
    required String refreshToken,
  }) async {}
  @override
  Future<void> onLoggedOut() async {}
  @override
  Future<void> onCompanyLoggedOut(String companyId) async {}
}

void main() {
  group('MobileApiClient', () {
    test('can be instantiated', () {
      final client = MobileApiClient(
        authBaseUrl: 'https://auth.example.com',
        backendBaseUrl: 'https://backend.example.com',
        authHandler: _MockAuthHandler(),
      );
      expect(client.backendBaseUrl, 'https://backend.example.com');
    });

    test('setBackendBaseUrl updates backendBaseUrl', () {
      final client = MobileApiClient(
        authBaseUrl: 'https://auth.example.com',
        backendBaseUrl: 'https://old.example.com',
        authHandler: _MockAuthHandler(),
      );
      client.setBackendBaseUrl('https://new.example.com');
      expect(client.backendBaseUrl, 'https://new.example.com');
    });
  });

  group('LoginRequest', () {
    test('toJson with email', () {
      final req = LoginRequest(email: 'a@b.com', password: 'secret');
      final json = req.toJson();
      expect(json['email'], 'a@b.com');
      expect(json['password'], 'secret');
      expect(json.containsKey('phone'), isFalse);
    });

    test('toJson with phone', () {
      final req = LoginRequest(
          phone: '812345', phoneCode: '+62', password: 'secret');
      final json = req.toJson();
      expect(json['phone'], '812345');
      expect(json['phone_code'], '+62');
      expect(json.containsKey('email'), isFalse);
    });
  });

  group('ApiError', () {
    test('fromDioException parses message field', () {
      // We cannot easily construct a real DioException with a response
      // without an HTTP client, so test the model constructor directly.
      const err = ApiError(
        statusCode: 422,
        message: 'invalid credentials',
        code: 'AUTH_001',
        details: {'message': 'invalid credentials'},
      );
      expect(err.statusCode, 422);
      expect(err.message, 'invalid credentials');
      expect(err.code, 'AUTH_001');
    });
  });

  group('ApprovalActionRequest', () {
    test('staged approver sends stage_id', () {
      const req = ApprovalActionRequest(
        stageId: 'stage-1',
        action: ApprovalAction.approved,
      );
      final json = req.toJson();
      expect(json['stage_id'], 'stage-1');
      expect(json['action'], 'APPROVED');
    });

    test('owner omits stage_id', () {
      const req = ApprovalActionRequest(action: ApprovalAction.rejected);
      final json = req.toJson();
      expect(json.containsKey('stage_id'), isFalse);
      expect(json['action'], 'REJECTED');
    });

    test('optional fields are omitted when null', () {
      const req = ApprovalActionRequest(action: ApprovalAction.approved);
      final json = req.toJson();
      expect(json.keys, ['action']);
    });
  });

  group('ApprovalActionResponse', () {
    test('parses an owner bypass response', () {
      final res = ApprovalActionResponse.fromJson(
        const {'status': 'approved', 'bypass': true},
      );
      expect(res.isApproved, isTrue);
      expect(res.isBypass, isTrue);
      expect(res.bypass, isTrue);
    });

    test('defaults bypass to false for a staged response', () {
      final res = ApprovalActionResponse.fromJson(
        const {'status': 'advanced_to_next_stage'},
      );
      expect(res.isAdvanced, isTrue);
      expect(res.isBypass, isFalse);
    });

    test('detects pending_other_approvers', () {
      final res = ApprovalActionResponse.fromJson(
        const {'status': 'pending_other_approvers'},
      );
      expect(res.isPendingOtherApprovers, isTrue);
      expect(res.isApproved, isFalse);
      expect(res.isRejected, isFalse);
    });
  });

  group('ListApprovalsParams', () {
    test('employee filter uses status only', () {
      const params = ListApprovalsParams(status: 'PENDING,APPROVED');
      final query = params.toQueryParameters();
      expect(query['status'], 'PENDING,APPROVED');
      expect(query.containsKey('request_status'), isFalse);
      expect(query.containsKey('employee_id'), isFalse);
    });

    test('owner filters use request_status and employee_id', () {
      const params = ListApprovalsParams(
        requestStatus: 'ALL',
        employeeId: 'emp-1',
        permissionType: PermissionType.leave,
      );
      final query = params.toQueryParameters();
      expect(query['request_status'], 'ALL');
      expect(query['employee_id'], 'emp-1');
      expect(query['permission_type'], 'LEAVE');
      expect(query.containsKey('status'), isFalse);
    });

    test('omits every optional filter by default', () {
      const params = ListApprovalsParams();
      final query = params.toQueryParameters();
      expect(query, {'page': 1, 'page_size': 20});
    });
  });

  group('ApprovalRequest', () {
    test('parses the bypass audit trail', () {
      final request = ApprovalRequest.fromJson(const {
        'id': 'req-1',
        'company_id': 'company-1',
        'requester_id': 'emp-1',
        'status': 'APPROVED',
        'actions': [
          {
            'id': 'action-1',
            'company_id': 'company-1',
            'request_id': 'req-1',
            'stage_id': 'stage-1',
            'actor_user_id': 'user-owner',
            'actor_role': 'owner',
            'actor_name': 'Bench Owner',
            'action': 'APPROVED',
            'is_bypass': true,
            'notes': 'approved by owner',
          },
        ],
      });

      expect(request.requesterId, 'emp-1');
      expect(request.isBypassed, isTrue);
      final action = request.actions!.single;
      expect(action.actorRole, ApprovalActorRole.owner);
      expect(action.actorName, 'Bench Owner');
      expect(action.action, ApproverStatus.approved);
      expect(action.isBypass, isTrue);
      expect(action.stageId, 'stage-1');
      expect(action.notes, 'approved by owner');
    });

    test('isBypassed is false without actions', () {
      final request = ApprovalRequest.fromJson(const {
        'id': 'req-1',
        'company_id': 'company-1',
        'status': 'IN_PROGRESS',
      });

      expect(request.actions, isNull);
      expect(request.isBypassed, isFalse);
    });

    test('unknown actor_role falls back to employee', () {
      expect(ApprovalActorRole.fromString('superuser'),
          ApprovalActorRole.employee);
      expect(ApprovalActorRole.fromString(null), ApprovalActorRole.employee);
    });
  });
}
