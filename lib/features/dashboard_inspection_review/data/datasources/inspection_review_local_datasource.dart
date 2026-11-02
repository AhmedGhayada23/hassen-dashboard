import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/inspection_decision.dart';
import '../models/inspection_model.dart';

/// Serves the demo reports as raw JSON and keeps review decisions in memory
/// for the app's lifetime. Swap for a remote data source when the backend exists.
class InspectionReviewLocalDataSource {
  final List<Map<String, Object?>> _json;
  final _decisions = <String, InspectionDecision>{};

  InspectionReviewLocalDataSource({
    List<Map<String, Object?>> json = demoInspectionsJson,
  }) : _json = json;

  /// Throws [ParseException] when the payload doesn't match the expected shape.
  Future<List<InspectionModel>> getInspections() async => [
    for (final m in _parse()) _withStoredDecision(m),
  ];

  /// Throws [NotFoundException] for an unknown [id].
  Future<InspectionModel> updateDecision(
    String id,
    InspectionDecision decision,
  ) async {
    final model = _parse().where((m) => m.id == id).firstOrNull;
    if (model == null) {
      throw NotFoundException(message: 'Inspection $id not found.');
    }
    if (decision == InspectionDecision.pending) {
      _decisions.remove(id);
    } else {
      _decisions[id] = decision;
    }
    return _withStoredDecision(model);
  }

  InspectionModel _withStoredDecision(InspectionModel m) =>
      m.withDecision(_decisions[m.id] ?? m.decision);

  List<InspectionModel> _parse() {
    try {
      return [for (final item in _json) InspectionModel.fromJson(item)];
    } catch (_) {
      throw ParseException();
    }
  }

  // بيانات تجريبية
  static const demoInspectionsJson = <Map<String, Object?>>[
    {
      'id': 'INS-0418',
      'facility': 'مستشفى الشفاء',
      'inspector': 'م. أحمد',
      'date': '2026-10-28',
      'template': 'تفتيش المنشآت الصحية v2',
      'pass': 20,
      'fail': 3,
      'findings': [
        {
          'title': 'مخرج الطوارئ رقم 2 تعيقه أسرّة مخزنة',
          'severity': 'critical',
          'note': 'احتواء خلال 24 ساعة',
          'due': '24 ساعة',
        },
        {
          'title': 'طفاية حريق منتهية الصلاحية — الطابق الأول',
          'severity': 'high',
          'note': 'استبدال الطفاية وتحديث سجل الفحص',
          'due': '14 يوماً',
        },
        {
          'title': 'لوحة إرشاد باهتة عند الدرج الشرقي',
          'severity': 'medium',
          'note': 'استبدال اللوحة',
          'due': '30 يوماً',
        },
      ],
    },
    {
      'id': 'INS-0417',
      'facility': 'بلدية غزة',
      'inspector': 'م. سارة',
      'date': '2026-10-27',
      'template': 'تفتيش المباني الإدارية v1',
      'pass': 26,
      'fail': 2,
      'findings': [
        {
          'title': 'تمديدات كهربائية مكشوفة في الأرشيف',
          'severity': 'high',
          'note': 'تغطية التمديدات وفحص اللوحة',
          'due': '14 يوماً',
        },
        {
          'title': 'صندوق إسعافات أولية ناقص',
          'severity': 'low',
          'note': 'استكمال المحتويات',
          'due': 'حتى الزيارة القادمة',
        },
      ],
    },
    {
      'id': 'INS-0416',
      'facility': 'مصنع العودة',
      'inspector': 'م. خالد',
      'date': '2026-10-27',
      'template': 'تفتيش المنشآت الصناعية v3',
      'pass': 31,
      'fail': 4,
      'findings': [
        {
          'title': 'غياب حاجز حماية على آلة القص 3',
          'severity': 'high',
          'note': 'تركيب حاجز وإيقاف الآلة حتى التركيب',
          'due': '14 يوماً',
        },
        {
          'title': 'انسكاب زيوت في الممر B',
          'severity': 'medium',
          'note': 'تنظيف وتوفير مواد امتصاص',
          'due': '30 يوماً',
        },
      ],
    },
    {
      'id': 'INS-0415',
      'facility': 'بنك فلسطين',
      'inspector': 'م. ليلى',
      'date': '2026-10-26',
      'template': 'تفتيش المكاتب والفروع v1',
      'pass': 22,
      'fail': 1,
      'findings': [
        {
          'title': 'مخطط الإخلاء غير محدّث — فرع الرمال',
          'severity': 'low',
          'note': 'تحديث المخطط',
          'due': 'حتى الزيارة القادمة',
        },
      ],
    },
  ];
}
