import '../../../../core/errors/exceptions.dart';
import '../models/inspection_templates_model.dart';
import '../models/visit_scheduling_options_model.dart';

/// The week the schedule shows, worked out from the clock, the visit types a
/// booking can take, and the inspection templates its tasks start from. The
/// inspectors, facilities and visits themselves live in Firebase
/// (`VisitsRemoteDataSource`).
class VisitsLocalDataSource {
  final DateTime Function() _clock;
  final Map<String, Object?> _typesJson;
  final Map<String, Object?> _templatesJson;

  const VisitsLocalDataSource({
    DateTime Function() clock = DateTime.now,
    Map<String, Object?> typesJson = visitTypesConfig,
    Map<String, Object?> templatesJson = inspectionTemplatesConfig,
  }) : _clock = clock,
       _typesJson = typesJson,
       _templatesJson = templatesJson;

  /// The working week (Saturday to Thursday) [offset] weeks from the current
  /// one, as raw JSON: `week_label`, `days` (order, label, date) and `today`
  /// (null outside the current week, and on Friday, when the coming week
  /// counts as the current one).
  Future<Map<String, Object?>> getWeek({int offset = 0}) async =>
      weekOf(_clock(), offset: offset);

  /// Throws [ParseException] when the types don't match the expected shape.
  Future<VisitTypesModel> getVisitTypes() async {
    try {
      return VisitTypesModel.fromJson(_typesJson);
    } catch (_) {
      throw ParseException();
    }
  }

  /// Throws [ParseException] when the templates don't match the expected shape.
  Future<InspectionTemplatesModel> getInspectionTemplates() async {
    try {
      return InspectionTemplatesModel.fromJson(_templatesJson);
    } catch (_) {
      throw ParseException();
    }
  }

  static Map<String, Object?> weekOf(DateTime now, {int offset = 0}) {
    // Calendar arithmetic in UTC, so a daylight-saving change can't skip a day.
    final today = DateTime.utc(now.year, now.month, now.day);
    final sinceSaturday = (today.weekday - DateTime.saturday) % 7;
    final isFriday = today.weekday == DateTime.friday;
    final saturday = today.add(
      Duration(days: (isFriday ? 1 : -sinceSaturday) + 7 * offset),
    );
    final days = [
      for (var i = 0; i < _dayNames.length; i++)
        saturday.add(Duration(days: i)),
    ];
    return {
      'week_label': 'الأسبوع ${_range(days.first, days.last)}',
      'days': [
        for (final (i, day) in days.indexed)
          {
            'order': i,
            'label': '${_dayNames[i]} ${day.day}',
            'date': isoDate(day),
          },
      ],
      'today': isFriday || offset != 0 ? null : sinceSaturday,
    };
  }

  /// `yyyy-MM-dd`, the form visits are stored and queried by.
  static String isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// "24 – 29 أكتوبر 2026", "31 أكتوبر – 5 نوفمبر 2026" or, across a new year,
  /// "27 ديسمبر 2026 – 1 يناير 2027".
  static String _range(DateTime from, DateTime to) {
    String month(DateTime d) => _monthNames[d.month - 1];
    if (from.year != to.year) {
      return '${from.day} ${month(from)} ${from.year} – '
          '${to.day} ${month(to)} ${to.year}';
    }
    if (from.month != to.month) {
      return '${from.day} ${month(from)} – ${to.day} ${month(to)} ${to.year}';
    }
    return '${from.day} – ${to.day} ${month(to)} ${to.year}';
  }

  static const _dayNames = [
    'السبت',
    'الأحد',
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
  ];

  static const _monthNames = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  // نموذج الفحص لكل قطاع (حقل type في جدول clients)، والافتراضي لغيرها،
  // ونموذج الفحص الأولي قبل التعاقد.
  static const inspectionTemplatesConfig = <String, Object?>{
    'by_sector': {
      'منشأة صحية': {'name': 'تفتيش المنشآت الصحية v2', 'items': 38},
      'منشأة صناعية': {'name': 'تفتيش المنشآت الصناعية v3', 'items': 42},
      'الطاقة والمرافق': {'name': 'تفتيش المنشآت الصناعية v3', 'items': 42},
      'خدمات مصرفية': {'name': 'تفتيش المكاتب والفروع v1', 'items': 23},
    },
    'default': {'name': 'تفتيش المباني الإدارية v1', 'items': 28},
    'pre_contract': {'name': 'الفحص الأولي قبل التعاقد v2', 'items': 30},
  };

  // أنواع الزيارات بالترتيب الأصلي.
  static const visitTypesConfig = <String, Object?>{
    'visit_types': ['تفتيش دوري', 'متابعة ملاحظات', 'فحص أولي'],
    'routine_type': 'تفتيش دوري',
    'pre_contract_type': 'فحص أولي',
  };
}
