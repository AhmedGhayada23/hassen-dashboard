import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/inspector.dart';
import '../../domain/entities/visit.dart';
import '../../domain/entities/visit_day.dart';
import '../../domain/entities/visit_facility.dart';
import '../../domain/entities/visit_schedule.dart';
import '../../domain/entities/visit_scheduling_options.dart';
import '../../domain/entities/visit_task.dart';
import 'schedule_visit_form_state.dart';

/// Drives the "schedule a visit" dialog. Opens on the first facility and
/// type — or on [facility] with the type its contract status calls for —
/// today (or the week's first day) at 10:00, with the suggested inspector
/// picked and the tasks the facility and type call for.
class ScheduleVisitFormCubit extends Cubit<ScheduleVisitFormState> {
  static const defaultHour = 10;
  static const defaultMinute = 0;

  final VisitSchedulingOptions options;

  ScheduleVisitFormCubit({
    required VisitSchedule schedule,
    required this.options,
    VisitFacility? facility,
  }) : super(_initial(schedule, options, facility));

  static ScheduleVisitFormState _initial(
    VisitSchedule schedule,
    VisitSchedulingOptions options,
    VisitFacility? chosen,
  ) {
    final facility = chosen ?? options.facilities.first;
    final type = chosen == null
        ? options.visitTypes.first
        : options.defaultTypeFor(chosen);
    final draft = ScheduleVisitFormState(
      schedule: schedule,
      facility: facility,
      type: type,
      day: schedule.today ?? schedule.days.first,
      hour: defaultHour,
      minute: defaultMinute,
      inspector: schedule.inspectors.first,
      autoTasks: options.autoTasksFor(facility, type),
    );
    return draft.copyWith(inspector: draft.suggestedInspector);
  }

  /// Also switches the type to the one the facility's contract status calls
  /// for, and starts its tasks afresh, all ticked.
  void selectFacility(VisitFacility facility) {
    final type = options.defaultTypeFor(facility);
    emit(
      state.copyWith(
        facility: facility,
        type: type,
        autoTasks: options.autoTasksFor(facility, type),
        excludedTaskIds: const {},
      ),
    );
  }

  /// Also redraws the automatic tasks; unticked ones stay unticked.
  void selectType(String type) => emit(
    state.copyWith(
      type: type,
      autoTasks: options.autoTasksFor(state.facility, type),
    ),
  );

  void selectDay(VisitDay day) => emit(state.copyWith(day: day));

  void selectTime(int hour, int minute) =>
      emit(state.copyWith(hour: hour, minute: minute));

  void selectInspector(Inspector inspector) =>
      emit(state.copyWith(inspector: inspector));

  /// Picks the least-loaded inspector who is free at the chosen slot.
  void assignSuggestedInspector() =>
      emit(state.copyWith(inspector: state.suggestedInspector));

  /// Ticks or unticks one of the automatic tasks.
  void toggleTask(VisitTask task, {required bool included}) => emit(
    state.copyWith(
      excludedTaskIds: included
          ? ({...state.excludedTaskIds}..remove(task.id))
          : {...state.excludedTaskIds, task.id},
    ),
  );

  /// Adds a task typed in by hand; blank text is ignored.
  void addTask(String title) {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;
    emit(state.copyWith(extraTasks: [...state.extraTasks, trimmed]));
  }

  /// Removes the hand-added task at [index].
  void removeTask(int index) =>
      emit(state.copyWith(extraTasks: [...state.extraTasks]..removeAt(index)));

  /// The visit to book, with its tasks and [note], or null while the
  /// inspector is busy at that slot.
  Visit? submit({String note = ''}) {
    if (state.hasConflict) return null;
    return options.buildVisit(
      inspector: state.inspector,
      day: state.day,
      time: state.time,
      facility: state.facility,
      type: state.type,
      tasks: state.tasks,
      note: note,
    );
  }
}
