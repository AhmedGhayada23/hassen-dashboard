import 'package:equatable/equatable.dart';

import 'inspector.dart';
import 'visit.dart';
import 'visit_day.dart';
import 'visit_facility.dart';
import 'visit_status.dart';
import 'visit_task.dart';
import 'visit_task_catalog.dart';

/// What a new visit can be booked for, the rules tying type to status, and
/// where its tasks come from.
class VisitSchedulingOptions extends Equatable {
  final List<VisitFacility> facilities;
  final List<String> visitTypes;

  /// Suggested for contracted facilities.
  final String routineType;

  /// Suggested for facilities without a contract; booked as [VisitStatus.preContract].
  final String preContractType;
  final VisitTaskCatalog taskCatalog;

  const VisitSchedulingOptions({
    required this.facilities,
    required this.visitTypes,
    required this.routineType,
    required this.preContractType,
    this.taskCatalog = const VisitTaskCatalog(),
  });

  String defaultTypeFor(VisitFacility facility) =>
      facility.isContracted ? routineType : preContractType;

  VisitStatus statusFor(String type) =>
      type == preContractType ? VisitStatus.preContract : VisitStatus.planned;

  /// The tasks a visit of [type] to [facility] starts with.
  List<VisitTask> autoTasksFor(VisitFacility facility, String type) =>
      taskCatalog.autoTasksFor(
        facility,
        isPreContract: type == preContractType,
      );

  Visit buildVisit({
    required Inspector inspector,
    required VisitDay day,
    required String time,
    required VisitFacility facility,
    required String type,
    List<VisitTask> tasks = const [],
    String note = '',
  }) => Visit(
    inspector: inspector,
    day: day,
    time: time,
    facility: facility.name,
    type: type,
    status: statusFor(type),
    tasks: tasks,
    note: note.trim(),
  );

  @override
  List<Object> get props => [
    facilities,
    visitTypes,
    routineType,
    preContractType,
    taskCatalog,
  ];
}
