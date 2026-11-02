import '../../domain/entities/report_activity.dart';

/// One line of a facility's monthly report, drawn from the Firebase record
/// behind it:
/// * a `visits` document — an inspection, or a check for a pre-contract
///   assessment, dated on its visit day;
/// * a `risks` document — an incident, dated when it was registered;
/// * a `corrective_actions` document — a repair, dated when it was raised.
class ReportActivityModel {
  /// Visit types reported as checks rather than inspections.
  static const checkVisitTypes = {'فحص أولي'};

  /// How a visit's inspection-template task is titled.
  static const _templateTaskPrefix = 'تنفيذ نموذج الفحص: ';

  /// The facility (client name) it happened at.
  final String facility;

  /// As `yyyy-MM-dd`.
  final String date;
  final ActivityType type;
  final String description;
  final String owner;
  final ActivityStatus status;

  const ReportActivityModel({
    required this.facility,
    required this.date,
    required this.type,
    required this.description,
    required this.owner,
    required this.status,
  });

  /// A booked visit: "type — template", by its inspector. Null without a
  /// facility or a date.
  static ReportActivityModel? fromVisit(Map<String, Object?> json) {
    final facility = _text(json['facility']);
    final date = _text(json['date']);
    if (facility.isEmpty || date.isEmpty) return null;
    final type = _text(json['type']);
    final template = [
      for (final t in json['tasks'] as List? ?? const [])
        if (t is Map && t['id'] == 'tpl')
          _text(t['title']).replaceFirst(_templateTaskPrefix, ''),
    ].firstOrNull;
    return ReportActivityModel(
      facility: facility,
      date: date,
      type: checkVisitTypes.contains(type)
          ? ActivityType.check
          : ActivityType.inspection,
      description: [
        if (type.isNotEmpty) type,
        if (template != null && template.isNotEmpty) template,
      ].join(' — '),
      owner: _text(json['inspector_name']),
      status: switch (json['status']) {
        'done' => ActivityStatus.completed,
        'now' => ActivityStatus.inProgress,
        _ => ActivityStatus.scheduled,
      },
    );
  }

  /// A registered risk, as an incident: "بلاغ: hazard", by its owner. A
  /// risk under monitoring counts as closed. Null without a facility, a
  /// hazard or a registration date.
  static ReportActivityModel? fromRisk(
    Map<String, Object?> json,
    DateTime? createdAt,
  ) {
    final facility = _text(json['facility']);
    final hazard = _text(json['hazard']);
    if (facility.isEmpty || hazard.isEmpty || createdAt == null) return null;
    return ReportActivityModel(
      facility: facility,
      date: isoDate(createdAt),
      type: ActivityType.incident,
      description: 'بلاغ: $hazard',
      owner: _text(json['owner']),
      status: switch (json['status']) {
        'in_treatment' => ActivityStatus.inProgress,
        'monitoring' => ActivityStatus.closed,
        _ => ActivityStatus.handling,
      },
    );
  }

  /// A corrective action, as a repair, by its owner; one past its deadline
  /// and not closed reads as overdue. Null without a facility, a title or a
  /// date raised.
  static ReportActivityModel? fromAction(
    Map<String, Object?> json,
    DateTime? createdAt,
  ) {
    final facility = _text(json['facility']);
    final title = _text(json['title']);
    if (facility.isEmpty || title.isEmpty || createdAt == null) return null;
    final status = switch (json['status']) {
      'in_progress' => ActivityStatus.inProgress,
      'pending_closure' => ActivityStatus.awaitingVerification,
      'closed' => ActivityStatus.closed,
      _ => ActivityStatus.open,
    };
    return ReportActivityModel(
      facility: facility,
      date: isoDate(createdAt),
      type: ActivityType.repair,
      description: title,
      owner: _text(json['owner']),
      status: json['due_status'] == 'late' && !status.isResolved
          ? ActivityStatus.overdue
          : status,
    );
  }

  /// `yyyy-MM-dd`.
  static String isoDate(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static String _text(Object? value) => value is String ? value.trim() : '';

  ReportActivity toEntity() => ReportActivity(
    date: date,
    type: type,
    description: description,
    owner: owner.isEmpty ? '—' : owner,
    status: status,
  );
}
