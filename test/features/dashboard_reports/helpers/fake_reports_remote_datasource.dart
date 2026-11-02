import 'package:hassen_dashboard/features/dashboard_reports/data/datasources/reports_remote_datasource.dart';
import 'package:hassen_dashboard/features/dashboard_reports/data/models/report_activity_model.dart';
import 'package:hassen_dashboard/features/dashboard_reports/data/models/report_facility_model.dart';

/// A Firestore document with its `created_at`, null when it has none.
typedef Doc = ({String id, Map<String, Object?> json, DateTime? createdAt});

/// In-memory stand-in for the Firestore collections reports are built from,
/// filtered the way the real source filters them. Seeded with three
/// contracted clients (and two that aren't) and their October 2026.
/// Records deliveries; throws [error] when set.
class FakeReportsRemoteDataSource implements ReportsRemoteDataSource {
  List<Doc> clients = [
    (
      id: 'c-gaza',
      json: {
        'name': 'بلدية غزة',
        'type': 'مؤسسة حكومية',
        'stage': 'contracted',
        'contract': '2025-12-16 ← 2026-12-15',
      },
      createdAt: DateTime(2025, 12, 1),
    ),
    (
      id: 'c-shifa',
      json: {
        'name': 'مستشفى الشفاء',
        'type': 'منشأة صحية',
        'stage': 'contracted',
        'deal_status': 'accepted',
        'contract': '2026-03-01 ← 2027-02-28',
      },
      createdAt: DateTime(2026, 2, 15),
    ),
    (
      id: 'c-bank',
      json: {
        'name': 'بنك فلسطين',
        'type': 'خدمات مصرفية',
        'deal_status': 'accepted',
        'contract': '2026-02-01 ← 2027-01-31',
      },
      createdAt: DateTime(2026, 1, 10),
    ),
    (
      id: 'c-mall',
      json: {'name': 'مجمع تجاري', 'stage': 'quotation'},
      createdAt: DateTime(2026, 10, 20),
    ),
    (
      id: 'c-transport',
      json: {
        'name': 'شركة نقل',
        'stage': 'quotation',
        'deal_status': 'rejected',
      },
      createdAt: DateTime(2025, 12, 2),
    ),
  ];

  List<Map<String, Object?>> visits = [
    {
      'facility': 'مستشفى الشفاء',
      'date': '2026-10-03',
      'type': 'تفتيش دوري',
      'status': 'done',
      'inspector_name': 'م. أحمد',
      'tasks': [
        {'id': 'tpl', 'title': 'تنفيذ نموذج الفحص: تفتيش المنشآت الصحية v2'},
        {'id': 'manual-1', 'title': 'فحص غرفة المولد'},
      ],
    },
    {
      'facility': 'مستشفى الشفاء',
      'date': '2026-10-28',
      'type': 'متابعة ملاحظات',
      'status': 'planned',
      'inspector_name': 'م. أحمد',
    },
    {
      'facility': 'بلدية غزة',
      'date': '2026-10-08',
      'type': 'تفتيش دوري',
      'status': 'done',
      'inspector_name': 'م. سارة',
    },
    {
      'facility': 'مجمع تجاري',
      'date': '2026-10-20',
      'type': 'فحص أولي',
      'status': 'pre',
      'inspector_name': 'م. سارة',
    },
    {
      'facility': 'بنك فلسطين',
      'date': '2026-11-04',
      'type': 'تفتيش دوري',
      'status': 'planned',
      'inspector_name': 'م. ليلى',
    },
  ];

  List<Doc> risks = [
    (
      id: 'r1',
      json: {
        'facility': 'مستشفى الشفاء',
        'hazard': 'إعاقة مسار الإخلاء',
        'owner': 'مسؤول السلامة',
        'status': 'open',
      },
      createdAt: DateTime(2026, 10, 12, 9),
    ),
    (
      id: 'r2',
      json: {
        'facility': 'بلدية غزة',
        'hazard': 'تمديدات كهربائية مكشوفة',
        'owner': 'مدير الخدمات العامة',
        'status': 'monitoring',
      },
      createdAt: DateTime(2026, 9, 20),
    ),
    (
      id: 'r3',
      json: {'facility': 'بنك فلسطين', 'hazard': 'بلا تاريخ'},
      createdAt: null,
    ),
  ];

  List<Doc> actions = [
    (
      id: 'CA-0431',
      json: {
        'facility': 'مستشفى الشفاء',
        'title': 'إزالة الأسرّة من أمام مخرج الطوارئ 2',
        'owner': 'مسؤول السلامة',
        'status': 'open',
        'due_status': 'late',
      },
      createdAt: DateTime(2026, 10, 28),
    ),
    (
      id: 'CA-0390',
      json: {
        'facility': 'بنك فلسطين',
        'title': 'استبدال طفايات منتهية',
        'owner': 'مدير المرافق',
        'status': 'pending_closure',
        'due_status': 'ok',
      },
      createdAt: DateTime(2026, 10, 26),
    ),
    (
      id: 'CA-0377',
      json: {
        'facility': 'بلدية غزة',
        'title': 'تحديث لوحات الإرشاد',
        'owner': 'مسؤول المرافق',
        'status': 'closed',
        'due_status': 'late',
      },
      createdAt: DateTime(2026, 10, 20),
    ),
  ];

  /// Document id → stored delivery.
  final Map<String, Map<String, Object?>> deliveries = {
    'c-gaza_2026-09': {
      'client_id': 'c-gaza',
      'month': '2026-09',
      'sent_on': '2026-10-02',
    },
  };

  Object? error;

  @override
  Future<List<ReportFacilityModel>> getFacilities() async {
    if (error case final e?) throw e;
    final ordered = clients.toList()
      ..sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
    return [
      for (final c in ordered) ?ReportFacilityModel.fromClient(c.id, c.json),
    ];
  }

  @override
  Future<List<ReportActivityModel>> getActivities(String month) async {
    if (error case final e?) throw e;
    final raised = [
      for (final r in risks) ?ReportActivityModel.fromRisk(r.json, r.createdAt),
      for (final a in actions)
        ?ReportActivityModel.fromAction(a.json, a.createdAt),
    ];
    return [
      for (final v in visits)
        if ((v['date'] as String).startsWith(month))
          ?ReportActivityModel.fromVisit(v),
      ...raised.where((a) => a.date.startsWith(month)),
    ];
  }

  @override
  Future<Map<String, String>> getSentDates(String month) async {
    if (error case final e?) throw e;
    return {
      for (final d in deliveries.values)
        if (d['month'] == month)
          d['client_id']! as String: d['sent_on']! as String,
    };
  }

  @override
  Future<void> recordDelivery(String id, Map<String, Object?> document) async {
    if (error case final e?) throw e;
    deliveries[id] = document;
  }
}
