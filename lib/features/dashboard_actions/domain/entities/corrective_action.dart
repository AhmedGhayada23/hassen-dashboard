import 'package:equatable/equatable.dart';

import 'action_due_status.dart';
import 'action_severity.dart';
import 'action_status.dart';

class CorrectiveAction extends Equatable {
  final String id;
  final String title;
  final String facility;
  final ActionSeverity severity;
  final String owner;

  /// Deadline as worded for the board (e.g. "متأخر 6 أيام", "الدليل مرفوع").
  final String dueText;
  final ActionDueStatus dueStatus;
  final ActionStatus status;

  const CorrectiveAction({
    required this.id,
    required this.title,
    required this.facility,
    required this.severity,
    required this.owner,
    required this.dueText,
    required this.dueStatus,
    required this.status,
  });

  bool get isLate => dueStatus == ActionDueStatus.late;

  CorrectiveAction withStatus(ActionStatus status) => CorrectiveAction(
    id: id,
    title: title,
    facility: facility,
    severity: severity,
    owner: owner,
    dueText: dueText,
    dueStatus: dueStatus,
    status: status,
  );

  @override
  List<Object> get props => [
    id,
    title,
    facility,
    severity,
    owner,
    dueText,
    dueStatus,
    status,
  ];
}
