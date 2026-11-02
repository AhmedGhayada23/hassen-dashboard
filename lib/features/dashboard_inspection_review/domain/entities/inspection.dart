import 'package:equatable/equatable.dart';

import 'finding.dart';
import 'inspection_decision.dart';

/// An inspection report awaiting (or past) review.
class Inspection extends Equatable {
  final String id;
  final String facility;
  final String inspector;
  final DateTime date;
  final String template;
  final int passCount;
  final int failCount;
  final List<Finding> findings;
  final InspectionDecision decision;

  const Inspection({
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

  bool get isPending => decision == InspectionDecision.pending;

  /// Rounded share of conforming items; null when nothing was checked.
  int? get compliancePercent {
    final total = passCount + failCount;
    return total == 0 ? null : (passCount / total * 100).round();
  }

  Inspection withDecision(InspectionDecision decision) => Inspection(
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

  @override
  List<Object> get props => [
    id,
    facility,
    inspector,
    date,
    template,
    passCount,
    failCount,
    findings,
    decision,
  ];
}
