import 'package:equatable/equatable.dart';

import '../../domain/entities/inspector.dart';
import '../../domain/entities/visit_day.dart';
import '../../domain/entities/visit_facility.dart';
import '../../domain/entities/visit_schedule.dart';
import '../../domain/entities/visit_task.dart';

/// The "schedule a visit" form: the current choices, checked against [schedule].
class ScheduleVisitFormState extends Equatable {
  final VisitSchedule schedule;
  final VisitFacility facility;
  final String type;
  final VisitDay day;
  final int hour;
  final int minute;
  final Inspector inspector;

  /// The tasks the facility and type call for, before any are left out.
  final List<VisitTask> autoTasks;

  /// Ids of [autoTasks] unticked by the manager.
  final Set<String> excludedTaskIds;

  /// Tasks typed in by the manager, in the order added.
  final List<String> extraTasks;

  const ScheduleVisitFormState({
    required this.schedule,
    required this.facility,
    required this.type,
    required this.day,
    required this.hour,
    required this.minute,
    required this.inspector,
    this.autoTasks = const [],
    this.excludedTaskIds = const {},
    this.extraTasks = const [],
  });

  /// `HH:mm`, the format visits are stored and compared in.
  String get time =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  Inspector get suggestedInspector => schedule.suggestedInspector(day, time);

  bool isBusy(Inspector inspector) => schedule.hasClash(inspector, day, time);

  bool get hasConflict => isBusy(inspector);

  bool isIncluded(VisitTask task) => !excludedTaskIds.contains(task.id);

  /// The tasks hand-added, as booked.
  List<VisitTask> get manualTasks => [
    for (final (i, title) in extraTasks.indexed)
      VisitTask(
        id: 'manual-${i + 1}',
        title: title,
        source: VisitTaskSource.manual,
      ),
  ];

  /// What the inspector will see: the ticked automatic tasks, then the
  /// hand-added ones.
  List<VisitTask> get tasks => [...autoTasks.where(isIncluded), ...manualTasks];

  ScheduleVisitFormState copyWith({
    VisitFacility? facility,
    String? type,
    VisitDay? day,
    int? hour,
    int? minute,
    Inspector? inspector,
    List<VisitTask>? autoTasks,
    Set<String>? excludedTaskIds,
    List<String>? extraTasks,
  }) => ScheduleVisitFormState(
    schedule: schedule,
    facility: facility ?? this.facility,
    type: type ?? this.type,
    day: day ?? this.day,
    hour: hour ?? this.hour,
    minute: minute ?? this.minute,
    inspector: inspector ?? this.inspector,
    autoTasks: autoTasks ?? this.autoTasks,
    excludedTaskIds: excludedTaskIds ?? this.excludedTaskIds,
    extraTasks: extraTasks ?? this.extraTasks,
  );

  @override
  List<Object> get props => [
    schedule,
    facility,
    type,
    day,
    hour,
    minute,
    inspector,
    autoTasks,
    excludedTaskIds,
    extraTasks,
  ];
}
