import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/errors/failure.dart';
import 'package:hassen_dashboard/features/dashboard_reports/data/datasources/reports_local_datasource.dart';
import 'package:hassen_dashboard/features/dashboard_reports/data/models/report_activity_model.dart';
import 'package:hassen_dashboard/features/dashboard_reports/data/models/report_facility_model.dart';
import 'package:hassen_dashboard/features/dashboard_reports/domain/entities/monthly_report.dart';
import 'package:hassen_dashboard/features/dashboard_reports/domain/entities/report_activity.dart';
import 'package:hassen_dashboard/features/dashboard_reports/domain/entities/report_delivery.dart';
import 'package:hassen_dashboard/features/dashboard_reports/domain/entities/report_facility.dart';
import 'package:hassen_dashboard/features/dashboard_reports/domain/entities/report_month.dart';
import 'package:hassen_dashboard/features/dashboard_reports/domain/failures/report_failures.dart';
import 'package:hassen_dashboard/features/dashboard_reports/domain/repositories/reports_repository.dart';
import 'package:hassen_dashboard/features/dashboard_reports/domain/usecases/send_monthly_report.dart';

import '../helpers/fake_reports_remote_datasource.dart';
import '../helpers/reports_cubit_factory.dart';

void main() {
  group('months', () {
    test('this month and the five before it, newest first', () async {
      final months = await ReportsLocalDataSource(
        clock: () => reportsToday,
      ).getMonths();

      expect(months.take(3), [november, october, september]);
      expect(months.map((m) => m.id).last, '2026-06');
      expect(months, hasLength(6));
    });

    test('a year boundary is crossed cleanly', () async {
      final months = await ReportsLocalDataSource(
        clock: () => DateTime(2027, 1, 15),
        count: 3,
      ).getMonths();

      expect(months.map((m) => (m.id, m.label)), [
        ('2027-01', 'يناير 2027'),
        ('2026-12', 'ديسمبر 2026'),
        ('2026-11', 'نوفمبر 2026'),
      ]);
    });
  });

  group('facilities from clients', () {
    test('accepted deals, and clients contracted before decisions', () {
      expect(
        ReportFacilityModel.fromClient('c1', const {
          'name': 'بنك فلسطين',
          'type': 'خدمات مصرفية',
          'deal_status': 'accepted',
          'contract': '2026-02-01 ← 2027-01-31',
        })?.toEntity(),
        const ReportFacility(
          id: 'c1',
          name: 'بنك فلسطين',
          sector: 'خدمات مصرفية',
          contractPeriod: '2026-02-01 ← 2027-01-31',
        ),
      );
      expect(
        ReportFacilityModel.fromClient('c2', const {
          'name': 'بلدية غزة',
          'stage': 'contracted',
        })?.contractPeriod,
        '—',
      );
    });

    test('pending, rejected or unnamed clients get no report', () {
      for (final json in const [
        {'name': 'x', 'stage': 'quotation'},
        {'name': 'x', 'deal_status': 'pending', 'stage': 'contracted'},
        {'name': 'x', 'deal_status': 'rejected'},
        {'name': ' ', 'deal_status': 'accepted'},
      ]) {
        expect(
          ReportFacilityModel.fromClient('c', json),
          isNull,
          reason: '$json',
        );
      }
    });
  });

  group('activities from Firebase records', () {
    test('a visit is an inspection named by its type and template', () {
      final visit = ReportActivityModel.fromVisit(const {
        'facility': 'مستشفى الشفاء',
        'date': '2026-10-03',
        'type': 'تفتيش دوري',
        'status': 'done',
        'inspector_name': 'م. أحمد',
        'tasks': [
          {'id': 'tpl', 'title': 'تنفيذ نموذج الفحص: تفتيش المنشآت الصحية v2'},
        ],
      })!;

      expect(visit.facility, 'مستشفى الشفاء');
      expect(
        visit.toEntity(),
        const ReportActivity(
          date: '2026-10-03',
          type: ActivityType.inspection,
          description: 'تفتيش دوري — تفتيش المنشآت الصحية v2',
          owner: 'م. أحمد',
          status: ActivityStatus.completed,
        ),
      );
    });

    test('a pre-contract visit is a check; visit status maps through', () {
      ReportActivityModel visit(String type, String status) =>
          ReportActivityModel.fromVisit({
            'facility': 'f',
            'date': '2026-10-01',
            'type': type,
            'status': status,
          })!;

      expect(visit('فحص أولي', 'pre').type, ActivityType.check);
      expect(visit('متابعة ملاحظات', 'now').type, ActivityType.inspection);
      expect(
        [
          for (final s in ['done', 'now', 'planned', 'pre'])
            visit('تفتيش دوري', s).status,
        ],
        [
          ActivityStatus.completed,
          ActivityStatus.inProgress,
          ActivityStatus.scheduled,
          ActivityStatus.scheduled,
        ],
      );
      expect(
        ReportActivityModel.fromVisit(const {'facility': 'f'}),
        isNull,
        reason: 'no date',
      );
    });

    test('a risk is an incident, dated when registered', () {
      final risk = ReportActivityModel.fromRisk(const {
        'facility': 'مستشفى الشفاء',
        'hazard': 'إعاقة مسار الإخلاء',
        'owner': 'مسؤول السلامة',
        'status': 'open',
      }, DateTime(2026, 10, 12, 9))!;

      expect(
        risk.toEntity(),
        const ReportActivity(
          date: '2026-10-12',
          type: ActivityType.incident,
          description: 'بلاغ: إعاقة مسار الإخلاء',
          owner: 'مسؤول السلامة',
          status: ActivityStatus.handling,
        ),
      );
      ActivityStatus statusOf(String s) => ReportActivityModel.fromRisk({
        'facility': 'f',
        'hazard': 'h',
        'status': s,
      }, DateTime(2026))!.status;
      expect(statusOf('in_treatment'), ActivityStatus.inProgress);
      expect(statusOf('monitoring'), ActivityStatus.closed);
      expect(
        ReportActivityModel.fromRisk(const {
          'facility': 'f',
          'hazard': 'h',
        }, null),
        isNull,
        reason: 'no registration date',
      );
    });

    test('a corrective action is a repair; late and open reads overdue', () {
      ActivityStatus statusOf(String status, {String due = 'ok'}) =>
          ReportActivityModel.fromAction({
            'facility': 'f',
            'title': 't',
            'status': status,
            'due_status': due,
          }, DateTime(2026, 10, 1))!.status;

      expect(statusOf('open'), ActivityStatus.open);
      expect(statusOf('in_progress'), ActivityStatus.inProgress);
      expect(statusOf('pending_closure'), ActivityStatus.awaitingVerification);
      expect(statusOf('closed'), ActivityStatus.closed);
      expect(statusOf('open', due: 'late'), ActivityStatus.overdue);
      expect(statusOf('closed', due: 'late'), ActivityStatus.closed);
      expect(
        ReportActivityModel.fromAction(const {
          'facility': 'f',
          'title': 't',
        }, DateTime(2026))!.toEntity().owner,
        '—',
      );
    });
  });

  group('repository', () {
    late FakeReportsRemoteDataSource remote;
    late ReportsRepository repository;

    setUp(() {
      remote = FakeReportsRemoteDataSource();
      repository = buildReportsRepository(remote);
    });

    Future<List<MonthlyReport>> reportsFor(ReportMonth month) async =>
        (await repository.getMonthlyReports(month)).getOrElse(() => []);

    test('one report per contracted client, oldest first', () async {
      final reports = await reportsFor(october);

      expect(reports.map((r) => r.facility.name), [
        'بلدية غزة',
        'بنك فلسطين',
        'مستشفى الشفاء',
      ]);
    });

    test('each report holds its facility\'s month, in date order', () async {
      final reports = await reportsFor(october);
      final counts = {
        for (final r in reports)
          r.facility.name: [
            for (final t in ActivityType.values) r.countOf(t),
            r.total,
            r.openCount,
          ],
      };

      expect(counts, {
        'بلدية غزة': [1, 0, 0, 1, 2, 0],
        'بنك فلسطين': [0, 0, 0, 1, 1, 1],
        'مستشفى الشفاء': [2, 1, 0, 1, 4, 3],
      });
      final shifa = reports.last;
      expect(shifa.activities.map((a) => a.date), [
        '2026-10-03',
        '2026-10-12',
        '2026-10-28',
        '2026-10-28',
      ]);
      expect(
        shifa.activities.map((a) => a.status),
        contains(ActivityStatus.overdue),
      );
    });

    test('a month only shows what happened in it', () async {
      final inSeptember = await reportsFor(september);
      expect(
        {for (final r in inSeptember) r.facility.name: r.total},
        {'بلدية غزة': 1, 'بنك فلسطين': 0, 'مستشفى الشفاء': 0},
      );
      expect(inSeptember.first.sentOn, '2026-10-02');
      expect(inSeptember[1].status, MonthlyReportStatus.empty);

      final inNovember = await reportsFor(november);
      expect(inNovember[1].activities.single.status, ActivityStatus.scheduled);
    });

    test('sending records the delivery in Firebase, with counts', () async {
      final shifa = (await reportsFor(october)).last;

      final sent =
          (await SendMonthlyReport(repository, clock: () => reportsToday)(
            SendMonthlyReportParams(
              shifa,
              const ReportDelivery(
                to: ' safety@shifa.ps ',
                cc: 'ops@haseen.ps',
              ),
            ),
          )).getOrElse(() => throw StateError('not sent'));

      expect(sent.sentOn, '2026-11-02');
      expect(remote.deliveries['c-shifa_2026-10'], {
        'client_id': 'c-shifa',
        'facility': 'مستشفى الشفاء',
        'month': '2026-10',
        'to': 'safety@shifa.ps',
        'cc': 'ops@haseen.ps',
        'sent_on': '2026-11-02',
        'file_name': 'HASEEN-2026-10-مستشفى-الشفاء.pdf',
        'counts': {
          'inspections': 2,
          'incidents': 1,
          'checks': 0,
          'repairs': 1,
          'total': 4,
          'open': 3,
        },
      });
      expect((await reportsFor(october)).last.sentOn, '2026-11-02');
    });

    test('a bad address is refused, nothing recorded', () async {
      final shifa = (await reportsFor(october)).last;

      expect(
        await SendMonthlyReport(repository)(
          SendMonthlyReportParams(shifa, const ReportDelivery(to: 'nope')),
        ),
        const Left<Failure, MonthlyReport>(InvalidReportRecipientFailure()),
      );
      expect(remote.deliveries.keys, ['c-gaza_2026-09']);
    });

    test('Firestore errors become failures the page can explain', () async {
      Future<Failure> failureFor(String code) async {
        remote.error = FirebaseException(plugin: 'cloud_firestore', code: code);
        return (await repository.getMonthlyReports(
          october,
        )).fold((f) => f, (_) => throw StateError('no failure'));
      }

      expect(await failureFor('permission-denied'), const ForbiddenFailure());
      expect(await failureFor('unavailable'), const NetworkFailure());
      expect(await failureFor('internal'), isA<UnknownFailure>());
    });

    test('email addresses are checked as in the original', () {
      expect(
        [
          for (final e in ['a@b.ps', ' a@b.ps ', 'a@b', 'a b@c.ps', '@b.ps'])
            ReportDelivery.isValidEmail(e),
        ],
        [true, true, false, false, false],
      );
    });
  });
}
