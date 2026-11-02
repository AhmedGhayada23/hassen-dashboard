import '../../domain/entities/inspector.dart';
import '../../domain/entities/visit.dart';
import '../../domain/entities/visit_day.dart';
import '../../domain/entities/visit_status.dart';
import 'visit_task_model.dart';

/// A document of the Firestore `visits` collection: the inspector is
/// referenced by account uid and the day by its calendar `date` (`yyyy-MM-dd`);
/// `tasks` is what the inspector sees on opening the visit in the field app.
class VisitModel {
  final String inspectorId;
  final String inspectorName;
  final String date;
  final String time;
  final String facility;
  final String type;
  final VisitStatus status;
  final List<VisitTaskModel> tasks;
  final String note;

  const VisitModel({
    required this.inspectorId,
    this.inspectorName = '',
    required this.date,
    required this.time,
    required this.facility,
    required this.type,
    required this.status,
    this.tasks = const [],
    this.note = '',
  });

  /// Reads leniently: an unknown `status` reads as planned, and tasks without
  /// a title are dropped.
  factory VisitModel.fromDocument(Map<String, Object?> json) => VisitModel(
    inspectorId: json['inspector_id'] as String? ?? '',
    inspectorName: json['inspector_name'] as String? ?? '',
    date: json['date'] as String? ?? '',
    time: json['time'] as String? ?? '',
    facility: json['facility'] as String? ?? '',
    type: json['type'] as String? ?? '',
    status: _statusByCode[json['status']] ?? VisitStatus.planned,
    tasks: [
      for (final item in json['tasks'] as List? ?? const [])
        if (item is Map<String, Object?>)
          if (VisitTaskModel.fromJson(item) case final task
              when task.title.isNotEmpty)
            task,
    ],
    note: json['note'] as String? ?? '',
  );

  factory VisitModel.fromEntity(Visit visit) => VisitModel(
    inspectorId: visit.inspector.id,
    inspectorName: visit.inspector.name,
    date: visit.day.date,
    time: visit.time,
    facility: visit.facility,
    type: visit.type,
    status: visit.status,
    tasks: [for (final t in visit.tasks) VisitTaskModel.fromEntity(t)],
    note: visit.note,
  );

  /// The document stored; `inspector_name` keeps it readable in the console.
  Map<String, Object?> toJson() => {
    'inspector_id': inspectorId,
    'inspector_name': inspectorName,
    'date': date,
    'time': time,
    'facility': facility,
    'type': type,
    'status': statusToJson(status),
    'tasks': [for (final t in tasks) t.toJson()],
    'note': note,
  };

  /// One `tasks` document per task, in order, each carrying the visit it
  /// belongs to ([visitId]) and the visit's details, so the field app can
  /// list and update tasks without reading the visit. Every task starts
  /// [pendingTaskStatus].
  List<Map<String, Object?>> taskDocuments(String visitId) => [
    for (final (i, task) in tasks.indexed)
      {
        'visit_id': visitId,
        'task_id': task.id,
        'order': i + 1,
        'title': task.title,
        'detail': task.detail,
        'source': VisitTaskModel.sourceToJson(task.source),
        'status': pendingTaskStatus,
        'inspector_id': inspectorId,
        'inspector_name': inspectorName,
        'facility': facility,
        'visit_type': type,
        'visit_status': statusToJson(status),
        'date': date,
        'time': time,
      },
  ];

  /// A task not yet done by the inspector.
  static const pendingTaskStatus = 'pending';

  static const _statusByCode = {
    'done': VisitStatus.done,
    'now': VisitStatus.inProgress,
    'planned': VisitStatus.planned,
    'pre': VisitStatus.preContract,
  };

  static String statusToJson(VisitStatus status) => switch (status) {
    VisitStatus.done => 'done',
    VisitStatus.inProgress => 'now',
    VisitStatus.planned => 'planned',
    VisitStatus.preContract => 'pre',
  };

  Visit toEntity({required Inspector inspector, required VisitDay day}) =>
      Visit(
        inspector: inspector,
        day: day,
        time: time,
        facility: facility,
        type: type,
        status: status,
        tasks: [for (final t in tasks) t.toEntity()],
        note: note,
      );
}
