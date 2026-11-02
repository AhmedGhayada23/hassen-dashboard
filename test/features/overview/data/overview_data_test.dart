import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/core/errors/failure.dart';
import 'package:hassen_dashboard/features/overview/data/models/overview_records.dart';
import 'package:hassen_dashboard/features/overview/data/models/overview_snapshot.dart';
import 'package:hassen_dashboard/features/overview/data/repositories/dashboard_repository_impl.dart';
import 'package:hassen_dashboard/features/overview/domain/entities/compliance_record.dart';
import 'package:hassen_dashboard/features/overview/domain/entities/contract_alert.dart';
import 'package:hassen_dashboard/features/overview/domain/entities/critical_risk.dart';
import 'package:hassen_dashboard/features/overview/domain/entities/dashboard_kpi.dart';
import 'package:hassen_dashboard/features/overview/domain/entities/dashboard_overview.dart';
import 'package:hassen_dashboard/features/overview/domain/entities/visit.dart';

import '../helpers/fake_overview_remote_datasource.dart';

void main() {
  late FakeOverviewRemoteDataSource remote;
  late FakePendingReviewsDataSource reviews;
  late DashboardRepositoryImpl repository;

  setUp(() {
    remote = FakeOverviewRemoteDataSource();
    reviews = FakePendingReviewsDataSource();
    repository = DashboardRepositoryImpl(
      remote,
      reviews,
      clock: () => overviewToday,
    );
  });

  Future<DashboardOverview> overview() async => (await repository.getOverview())
      .getOrElse(() => throw StateError('no overview'));

  group('records', () {
    test('a client: contracted, compliance and contract end', () {
      final client = OverviewClient.fromDocument(const {
        'name': ' مستشفى الشفاء ',
        'deal_status': 'accepted',
        'compliance': 82.4,
        'contract': '2026-03-01 ← 2027-02-28',
      })!;

      expect(
        (
          client.name,
          client.isContracted,
          client.compliance,
          client.contractEnd,
        ),
        ('مستشفى الشفاء', true, 82, DateTime(2027, 2, 28)),
      );
      expect(
        OverviewClient.fromDocument(const {
          'name': 'x',
          'deal_status': 'pending',
          'stage': 'contracted',
          'compliance': 140,
          'contract': '—',
        }),
        isA<OverviewClient>()
            .having((c) => c.isContracted, 'contracted', false)
            .having((c) => c.compliance, 'compliance', null)
            .having((c) => c.contractEnd, 'end', null),
      );
      expect(OverviewClient.fromDocument(const {'name': ' '}), isNull);
    });

    test('risks need a hazard and ratings in 1–5', () {
      expect(
        OverviewRisk.fromDocument(const {
          'hazard': 'h',
          'likelihood': 4,
          'severity': 5.0,
        })?.score,
        20,
      );
      expect(
        OverviewRisk.fromDocument(const {
          'hazard': 'h',
          'likelihood': 6,
          'severity': 1,
        }),
        isNull,
      );
      expect(
        OverviewRisk.fromDocument(const {'likelihood': 1, 'severity': 1}),
        isNull,
      );
    });
  });

  group('this week', () {
    test('Saturday to Thursday; on Friday, the week about to start', () {
      expect(OverviewSnapshot.weekOf(DateTime(2026, 11, 1)), (
        '2026-10-31',
        '2026-11-05',
      ));
      expect(OverviewSnapshot.weekOf(DateTime(2026, 10, 31)), (
        '2026-10-31',
        '2026-11-05',
      ));
      expect(OverviewSnapshot.weekOf(DateTime(2026, 10, 30)), (
        '2026-10-31',
        '2026-11-05',
      ));
      expect(OverviewSnapshot.weekOf(DateTime(2026, 10, 29)), (
        '2026-10-24',
        '2026-10-29',
      ));
    });

    test('only this week\'s visits are asked for', () async {
      await overview();

      expect(remote.lastVisitRange, ('2026-10-31', '2026-11-05'));
    });
  });

  group('the overview from the pages\' records', () {
    test(
      'six KPIs, counted from clients, visits, reviews, actions, risks',
      () async {
        final kpis = (await overview()).kpis;

        expect(
          [for (final k in kpis) (k.label, k.value, k.subtitle, k.tone)],
          [
            ('عملاء متعاقدون', 3, 'من أصل 5 في السجل', KpiTone.neutral),
            ('زيارات هذا الأسبوع', 4, '2 منجزة · 1 جارية', KpiTone.neutral),
            ('بانتظار الاعتماد', 2, 'نتائج تفتيش', KpiTone.warning),
            ('إجراءات متأخرة', 2, 'من 3 مفتوحة', KpiTone.danger),
            ('مخاطر حرجة مفتوحة', 2, 'من 4 في سجل المخاطر', KpiTone.danger),
            ('عقود تنتهي قريباً', 1, 'خلال 60 يوماً', KpiTone.warning),
          ],
        );
      },
    );

    test('a KPI with nothing to flag stays neutral', () async {
      remote
        ..actions = []
        ..risks = [];
      reviews.reviews = [];

      final kpis = (await overview()).kpis;

      expect(kpis[2].tone, KpiTone.neutral);
      expect(kpis[3].tone, KpiTone.neutral);
      expect(kpis[4].tone, KpiTone.neutral);
    });

    test('compliance of contracted clients that have one', () async {
      expect((await overview()).compliance, const [
        ComplianceRecord(facility: 'مستشفى الشفاء', percentage: 82),
        ComplianceRecord(facility: 'بلدية غزة', percentage: 76),
      ]);
    });

    test('open critical risks, highest score first', () async {
      expect((await overview()).criticalRisks, const [
        CriticalRisk(
          score: 20,
          title: 'إعاقة مسار الإخلاء',
          facility: 'مستشفى الشفاء',
          owner: 'مسؤول السلامة',
        ),
        CriticalRisk(
          score: 15,
          title: 'آلة قص دون حاجز حماية',
          facility: 'مصنع العودة',
          owner: 'مدير الإنتاج',
        ),
      ]);
    });

    test('today\'s visits by time, with their status', () async {
      expect((await overview()).todayVisits, const [
        Visit(
          time: '09:00',
          facility: 'مستشفى الشفاء',
          inspector: 'م. أحمد',
          status: VisitStatus.done,
        ),
        Visit(
          time: '11:30',
          facility: 'بلدية غزة',
          inspector: 'م. سارة',
          status: VisitStatus.inProgress,
        ),
      ]);
    });

    test('contracts ending within 60 days, soonest first', () async {
      expect((await overview()).contractAlerts, [
        ContractAlert(
          client: 'بلدية غزة',
          endDate: DateTime(2026, 12, 15),
          daysRemaining: 44,
        ),
      ]);
    });

    test('pending reviews come from the review page; the bell follows '
        'what needs attention', () async {
      final first = await overview();
      expect(first.pendingReviews.map((r) => r.id), ['INS-0418', 'INS-0417']);
      expect(first.hasUnreadNotifications, isTrue);

      remote
        ..actions = []
        ..risks = [];
      reviews.reviews = [];
      expect((await overview()).hasUnreadNotifications, isFalse);
    });

    test('an empty Firebase is an empty overview, not an error', () async {
      remote
        ..clients = []
        ..visits = []
        ..risks = []
        ..actions = [];
      reviews.reviews = [];

      final empty = await overview();

      expect([for (final k in empty.kpis) k.value], [0, 0, 0, 0, 0, 0]);
      expect(empty.todayVisits, isEmpty);
      expect(empty.compliance, isEmpty);
    });
  });

  test('Firestore errors become failures the page can explain', () async {
    Future<Failure> failureFor(String code) async {
      remote.error = FirebaseException(plugin: 'cloud_firestore', code: code);
      return (await repository.getOverview()).fold(
        (f) => f,
        (_) => throw StateError('no failure'),
      );
    }

    expect(await failureFor('permission-denied'), const ForbiddenFailure());
    expect(await failureFor('unavailable'), const NetworkFailure());
    expect(await failureFor('internal'), isA<UnknownFailure>());
  });
}
