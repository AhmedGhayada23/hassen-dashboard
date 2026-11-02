import '../../domain/entities/finding.dart';
import '../../domain/entities/finding_severity.dart';

class FindingModel {
  final String title;
  final FindingSeverity severity;
  final String note;
  final String due;

  const FindingModel({
    required this.title,
    required this.severity,
    required this.note,
    required this.due,
  });

  factory FindingModel.fromJson(Map<String, Object?> json) => FindingModel(
    title: json['title'] as String,
    severity: FindingSeverity.values.byName(json['severity'] as String),
    note: json['note'] as String,
    due: json['due'] as String,
  );

  Finding toEntity() =>
      Finding(title: title, severity: severity, note: note, due: due);
}
