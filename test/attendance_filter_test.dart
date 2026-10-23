import 'package:test/test.dart';

import 'package:fio_backend_client/fio_backend_client.dart';

void main() {
  group('ListAttendanceParams', () {
    test('multi-select filters serialize as repeated query parameters', () {
      const params = ListAttendanceParams(
        page: 2,
        pageSize: 50,
        startDate: '2026-10-01',
        endDate: '2026-10-21',
        attendanceTypes: [AttendanceType.checkIn, AttendanceType.checkOut],
        methods: [AttendanceMethod.gps],
        officeRadiusStatuses: [
          OfficeRadiusStatus.inside,
          OfficeRadiusStatus.unknown,
        ],
      );

      final query = params.toQueryParameters();

      expect(query['page'], 2);
      expect(query['page_size'], 50);
      expect(query['start_date'], '2026-10-01');
      expect(query['end_date'], '2026-10-21');
      expect(query['attendance_type'], ['CHECK_IN', 'CHECK_OUT']);
      expect(query['method'], ['gps']);
      expect(query['office_radius_status'], ['inside', 'unknown']);
      expect(query.containsKey('employee_id'), isFalse);
    });

    test('empty filters are omitted', () {
      const params = ListAttendanceParams();

      final query = params.toQueryParameters();

      expect(query.containsKey('attendance_type'), isFalse);
      expect(query.containsKey('method'), isFalse);
      expect(query.containsKey('office_radius_status'), isFalse);
      expect(query.containsKey('start_date'), isFalse);
      expect(query.containsKey('employee_id'), isFalse);
    });
  });

  group('OfficeRadiusStatus', () {
    test('parses known values and rejects unknown ones', () {
      expect(
          OfficeRadiusStatus.fromString('inside'), OfficeRadiusStatus.inside);
      expect(
          OfficeRadiusStatus.fromString('outside'), OfficeRadiusStatus.outside);
      expect(
          OfficeRadiusStatus.fromString('unknown'), OfficeRadiusStatus.unknown);
      expect(OfficeRadiusStatus.fromString('maybe'), isNull);
      expect(OfficeRadiusStatus.fromString(null), isNull);
    });
  });

  group('AttendanceLog', () {
    test('parses method, approval status and office radius status', () {
      final log = AttendanceLog.fromJson({
        'id': 'log-1',
        'company_id': 'cmp-1',
        'employee_id': 'emp-1',
        'attendance_type': 'CHECK_IN',
        'timestamp': '2026-10-21T08:30:15Z',
        'method': 'gps',
        'approval_status': 'auto_approved',
        'office_radius_status': 'outside',
        'latitude': -6.9,
        'longitude': 107.6,
      });

      expect(log.method, AttendanceMethod.gps);
      expect(log.approvalStatus, 'auto_approved');
      expect(log.officeRadiusStatus, OfficeRadiusStatus.outside);
    });

    test('office radius status is null for non-GPS records', () {
      final log = AttendanceLog.fromJson({
        'id': 'log-2',
        'company_id': 'cmp-1',
        'employee_id': 'emp-1',
        'attendance_type': 'CHECK_IN',
        'timestamp': '2026-10-21T08:30:15Z',
        'method': 'fingerprint',
      });

      expect(log.officeRadiusStatus, isNull);
    });
  });
}
