import '../../domain/entities/inspection.dart';
import '../../domain/entities/inspection_decision.dart';
import 'finding_model.dart';

class InspectionModel {
  final String id;
  final String facility;
  final String inspector;
  final DateTime date;
  final String template;
  final int passCount;
  final int failCount;
  final List<FindingModel> findings;
  final InspectionDecision decision;

  const InspectionModel({
    required this.id,
    required this.facility,
    required this.inspector,
    required this.date,
    required this.template,
    required this.passCount,
    required this.failCount,
    required this.findings,
    this.decision = InspectionDecision.pending,
  });

  factory InspectionModel.fromJson(Map<String, Object?> json) =>
      InspectionModel(
        id: json['id'] as String,
        facility: json['facility'] as String,
        inspector: json['inspector'] as String,
        date: DateTime.parse(json['date'] as String),
        template: json['template'] as String,
        passCount: json['pass'] as int,
        failCount: json['fail'] as int,
        findings: [
          for (final f in json['findings'] as List)
            FindingModel.fromJson(f as Map<String, Object?>),
        ],
        decision: InspectionDecision.values.byName(
          json['decision'] as String? ?? 'pending',
        ),
      );

  InspectionModel withDecision(InspectionDecision decision) => InspectionModel(
    id: id,
    facility: facility,
    inspector: inspector,
    date: date,
    template: template,
    passCount: passCount,
    failCount: failCount,
    findings: findings,
    decision: decision,
  );

  Inspection toEntity() => Inspection(
    id: id,
    facility: facility,
    inspector: inspector,
    date: date,
    template: template,
    passCount: passCount,
    failCount: failCount,
    findings: [for (final f in findings) f.toEntity()],
    decision: decision,
  );
}
