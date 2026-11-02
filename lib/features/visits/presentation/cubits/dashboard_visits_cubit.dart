import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/visit.dart';
import '../../domain/usecases/get_visit_schedule.dart';
import '../../domain/usecases/get_visit_scheduling_options.dart';
import '../../domain/usecases/schedule_visit.dart';
import 'dashboard_visits_state.dart';

/// Loads a week of the schedule with its booking options, moves between
/// weeks, and books new visits.
class DashboardVisitsCubit extends Cubit<DashboardVisitsState> {
  final GetVisitSchedule _getSchedule;
  final GetVisitSchedulingOptions _getOptions;
  final ScheduleVisit _scheduleVisit;

  /// The week shown, counted from the current one; kept across reloads.
  int _weekOffset = 0;

  DashboardVisitsCubit(this._getSchedule, this._getOptions, this._scheduleVisit)
    : super(const DashboardVisitsInitial());

  Future<void> load() async {
    final weekOffset = _weekOffset;
    emit(const DashboardVisitsLoading());
    final schedule = await _getSchedule(weekOffset);
    final options = await _getOptions(const NoParams());
    // A later week change wins over this one.
    if (isClosed || weekOffset != _weekOffset) return;
    emit(
      schedule.fold(
        DashboardVisitsFailure.new,
        (s) => options.fold(
          DashboardVisitsFailure.new,
          (o) => DashboardVisitsLoaded(s, o, weekOffset: weekOffset),
        ),
      ),
    );
  }

  /// Shows the week [weekOffset] weeks from the current one (0 = this week).
  Future<void> showWeek(int weekOffset) {
    _weekOffset = weekOffset;
    return load();
  }

  Future<void> showPreviousWeek() => showWeek(_weekOffset - 1);

  Future<void> showNextWeek() => showWeek(_weekOffset + 1);

  Future<void> showCurrentWeek() => showWeek(0);

  /// Books [visit] in the week shown. Ignored until the week has loaded.
  Future<void> scheduleVisit(Visit visit) async {
    final current = state;
    if (current is! DashboardVisitsLoaded) return;
    final result = await _scheduleVisit(
      ScheduleVisitParams(visit, weekOffset: current.weekOffset),
    );
    if (isClosed) return;
    emit(
      result.fold(
        (failure) => DashboardVisitsLoaded(
          current.schedule,
          current.options,
          weekOffset: current.weekOffset,
          actionFailure: failure,
        ),
        (schedule) => DashboardVisitsLoaded(
          schedule,
          current.options,
          weekOffset: current.weekOffset,
          lastScheduled: visit,
        ),
      ),
    );
  }
}
