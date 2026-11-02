import 'package:equatable/equatable.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/visit.dart';
import '../../domain/entities/visit_schedule.dart';
import '../../domain/entities/visit_scheduling_options.dart';

sealed class DashboardVisitsState extends Equatable {
  const DashboardVisitsState();

  @override
  List<Object?> get props => [];
}

final class DashboardVisitsInitial extends DashboardVisitsState {
  const DashboardVisitsInitial();
}

final class DashboardVisitsLoading extends DashboardVisitsState {
  const DashboardVisitsLoading();
}

final class DashboardVisitsLoaded extends DashboardVisitsState {
  final VisitSchedule schedule;
  final VisitSchedulingOptions options;

  /// How many weeks [schedule] is from the current one (0 = this week).
  final int weekOffset;

  /// The visit just booked, for a one-off confirmation; cleared by the next change.
  final Visit? lastScheduled;

  /// Set when the last booking failed; cleared by the next change.
  final Failure? actionFailure;

  const DashboardVisitsLoaded(
    this.schedule,
    this.options, {
    this.weekOffset = 0,
    this.lastScheduled,
    this.actionFailure,
  });

  @override
  List<Object?> get props => [
    schedule,
    options,
    weekOffset,
    lastScheduled,
    actionFailure,
  ];
}

final class DashboardVisitsFailure extends DashboardVisitsState {
  final Failure failure;

  const DashboardVisitsFailure(this.failure);

  @override
  List<Object?> get props => [failure];
}
