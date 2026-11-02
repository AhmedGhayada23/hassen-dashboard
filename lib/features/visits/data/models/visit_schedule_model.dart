import '../../domain/entities/visit_schedule.dart';
import 'inspector_model.dart';
import 'visit_day_model.dart';
import 'visit_model.dart';

/// The week (local) laid out with the inspectors and visits (Firebase).
class VisitScheduleModel {
  final String weekLabel;
  final List<InspectorModel> inspectors;
  final List<VisitDayModel> days;
  final int? todayOrder;
  final List<VisitModel> visits;

  const VisitScheduleModel({
    required this.weekLabel,
    required this.inspectors,
    required this.days,
    required this.todayOrder,
    required this.visits,
  });

  /// Throws [FormatException] when the week is malformed or `today` is set
  /// but not one of its days. Visits whose inspector or date is not in the
  /// schedule (an account removed, say) are left out rather than failing the
  /// page.
  factory VisitScheduleModel.fromParts({
    required Map<String, Object?> weekJson,
    required List<InspectorModel> inspectors,
    required List<VisitModel> visits,
  }) {
    final days = [
      for (final item in weekJson['days'] as List)
        VisitDayModel.fromJson(item as Map<String, Object?>),
    ];
    final todayOrder = weekJson['today'] as int?;
    if (todayOrder != null && !days.any((d) => d.order == todayOrder)) {
      throw FormatException('Unknown today: $todayOrder');
    }
    final inspectorIds = {for (final i in inspectors) i.id};
    final dates = {for (final d in days) d.date};
    return VisitScheduleModel(
      weekLabel: weekJson['week_label'] as String,
      inspectors: inspectors,
      days: days,
      todayOrder: todayOrder,
      visits: [
        for (final v in visits)
          if (inspectorIds.contains(v.inspectorId) && dates.contains(v.date)) v,
      ],
    );
  }

  /// The first and last dates of the week, for fetching only its visits.
  static (String from, String to) dateRangeOf(Map<String, Object?> weekJson) {
    final days = weekJson['days'] as List;
    String dateOf(Object? day) =>
        (day as Map<String, Object?>)['date'] as String;
    return (dateOf(days.first), dateOf(days.last));
  }

  VisitSchedule toEntity() {
    final inspectorsById = {for (final m in inspectors) m.id: m.toEntity()};
    final daysByDate = {for (final m in days) m.date: m.toEntity()};
    return VisitSchedule(
      weekLabel: weekLabel,
      inspectors: inspectorsById.values.toList(),
      days: daysByDate.values.toList(),
      today: [
        for (final d in daysByDate.values)
          if (d.order == todayOrder) d,
      ].firstOrNull,
      visits: [
        for (final v in visits)
          v.toEntity(
            inspector: inspectorsById[v.inspectorId]!,
            day: daysByDate[v.date]!,
          ),
      ],
    );
  }
}
