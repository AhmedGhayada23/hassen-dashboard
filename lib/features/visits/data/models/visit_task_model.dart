import '../../domain/entities/visit_task.dart';

/// One entry of a visit document's `tasks` array:
/// `{id, title, detail, source}`, with `source` one of [sourceToJson]'s codes.
class VisitTaskModel {
  final String id;
  final String title;
  final String detail;
  final VisitTaskSource source;

  const VisitTaskModel({
    required this.id,
    required this.title,
    required this.detail,
    required this.source,
  });

  /// Reads leniently: an unknown `source` reads as hand-added.
  factory VisitTaskModel.fromJson(Map<String, Object?> json) => VisitTaskModel(
    id: json['id'] as String? ?? '',
    title: (json['title'] as String? ?? '').trim(),
    detail: json['detail'] as String? ?? '',
    source: _sourceByCode[json['source']] ?? VisitTaskSource.manual,
  );

  factory VisitTaskModel.fromEntity(VisitTask task) => VisitTaskModel(
    id: task.id,
    title: task.title,
    detail: task.detail,
    source: task.source,
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'title': title,
    'detail': detail,
    'source': sourceToJson(source),
  };

  VisitTask toEntity() =>
      VisitTask(id: id, title: title, detail: detail, source: source);

  static const _sourceByCode = {
    'template': VisitTaskSource.template,
    'corrective_action': VisitTaskSource.correctiveAction,
    'manual': VisitTaskSource.manual,
  };

  static String sourceToJson(VisitTaskSource source) => switch (source) {
    VisitTaskSource.template => 'template',
    VisitTaskSource.correctiveAction => 'corrective_action',
    VisitTaskSource.manual => 'manual',
  };
}
