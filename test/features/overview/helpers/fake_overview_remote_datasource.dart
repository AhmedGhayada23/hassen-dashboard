import 'package:hassen_dashboard/features/overview/data/datasources/overview_remote_datasource.dart';
import 'package:hassen_dashboard/features/overview/data/datasources/pending_reviews_datasource.dart';
import 'package:hassen_dashboard/features/overview/data/models/overview_records.dart';
import 'package:hassen_dashboard/features/overview/domain/entities/inspection_review.dart';

/// Today in the overview tests: Sunday 1 November 2026, so this week runs
/// Saturday 31 October to Thursday 5 November.
final overviewToday = DateTime(2026, 11, 1, 10);

/// In-memory stand-in for the Firestore collections the overview reads,
/// as raw documents. Throws [error] when set.
class FakeOverviewRemoteDataSource implements OverviewRemoteDataSource {
  List<Map<String, Object?>> clients = [
    {
      'name': 'مستشفى الشفاء',
      'deal_status': 'accepted',
      'compliance': 82,
      'contract': '2026-03-01 ← 2027-02-28',
    },
    {
      'name': 'بلدية غزة',
      'stage': 'contracted',
      'compliance': 76,
      'contract': '2025-12-16 ← 2026-12-15',
    },
    {
      'name': 'بنك فلسطين',
      'deal_status': 'accepted',
      'contract': '2026-02-01 ← 2027-01-31',
    },
    {'name': 'مجمع تجاري', 'stage': 'quotation'},
    {'name': 'شركة نقل', 'deal_status': 'rejected', 'stage': 'quotation'},
  ];

  List<Map<String, Object?>> visits = [
    {
      'date': '2026-11-01',
      'time': '11:30',
      'facility': 'بلدية غزة',
      'inspector_name': 'م. سارة',
      'status': 'now',
    },
    {
      'date': '2026-11-01',
      'time': '09:00',
      'facility': 'مستشفى الشفاء',
      'inspector_name': 'م. أحمد',
      'status': 'done',
    },
    {
      'date': '2026-10-31',
      'time': '10:00',
      'facility': 'بنك فلسطين',
      'inspector_name': 'م. ليلى',
      'status': 'done',
    },
    {
      'date': '2026-11-04',
      'time': '13:00',
      'facility': 'مستشفى الشفاء',
      'inspector_name': 'م. أحمد',
      'status': 'planned',
    },
    // Last week: outside the range asked for.
    {
      'date': '2026-10-28',
      'time': '09:00',
      'facility': 'بلدية غزة',
      'status': 'done',
    },
  ];

  List<Map<String, Object?>> risks = [
    {
      'hazard': 'إعاقة مسار الإخلاء',
      'facility': 'مستشفى الشفاء',
      'owner': 'مسؤول السلامة',
      'likelihood': 4,
      'severity': 5,
      'status': 'open',
    },
    {
      'hazard': 'آلة قص دون حاجز حماية',
      'facility': 'مصنع العودة',
      'owner': 'مدير الإنتاج',
      'likelihood': 3,
      'severity': 5,
      'status': 'in_treatment',
    },
    // Critical but under monitoring: not open.
    {
      'hazard': 'تسرب غاز',
      'facility': 'بنك فلسطين',
      'likelihood': 5,
      'severity': 5,
      'status': 'monitoring',
    },
    {
      'hazard': 'انسكاب زيوت',
      'facility': 'مصنع العودة',
      'likelihood': 3,
      'severity': 3,
      'status': 'open',
    },
  ];

  List<Map<String, Object?>> actions = [
    {'title': 'a', 'status': 'open', 'due_status': 'late'},
    {'title': 'b', 'status': 'in_progress', 'due_status': 'late'},
    {'title': 'c', 'status': 'in_progress', 'due_status': 'soon'},
    {'title': 'd', 'status': 'closed', 'due_status': 'late'},
  ];

  Object? error;
  (String, String)? lastVisitRange;

  @override
  Future<List<OverviewClient>> getClients() async {
    if (error case final e?) throw e;
    return [for (final c in clients) ?OverviewClient.fromDocument(c)];
  }

  @override
  Future<List<OverviewVisit>> getVisits({
    required String from,
    required String to,
  }) async {
    if (error case final e?) throw e;
    lastVisitRange = (from, to);
    return [
      for (final v in visits)
        if ((v['date']! as String).compareTo(from) >= 0 &&
            (v['date']! as String).compareTo(to) <= 0)
          ?OverviewVisit.fromDocument(v),
    ];
  }

  @override
  Future<List<OverviewRisk>> getRisks() async {
    if (error case final e?) throw e;
    return [for (final r in risks) ?OverviewRisk.fromDocument(r)];
  }

  @override
  Future<List<OverviewAction>> getActions() async {
    if (error case final e?) throw e;
    return [for (final a in actions) ?OverviewAction.fromDocument(a)];
  }
}

/// Serves [reviews] — two pending reports by default.
class FakePendingReviewsDataSource implements PendingReviewsDataSource {
  List<InspectionReview> reviews = const [
    InspectionReview(
      id: 'INS-0418',
      facility: 'مستشفى الشفاء',
      inspector: 'م. أحمد',
      nonConformities: 3,
      isCritical: true,
    ),
    InspectionReview(
      id: 'INS-0417',
      facility: 'بلدية غزة',
      inspector: 'م. سارة',
      nonConformities: 2,
    ),
  ];

  @override
  Future<List<InspectionReview>> getPendingReviews() async => [...reviews];
}
