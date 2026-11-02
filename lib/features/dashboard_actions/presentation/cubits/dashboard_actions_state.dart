import 'package:equatable/equatable.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/action_status.dart';
import '../../domain/entities/actions_summary.dart';
import '../../domain/entities/corrective_action.dart';

sealed class DashboardActionsState extends Equatable {
  const DashboardActionsState();

  @override
  List<Object?> get props => [];
}

final class DashboardActionsInitial extends DashboardActionsState {
  const DashboardActionsInitial();
}

final class DashboardActionsLoading extends DashboardActionsState {
  const DashboardActionsLoading();
}

final class DashboardActionsFailure extends DashboardActionsState {
  final Failure failure;

  const DashboardActionsFailure(this.failure);

  @override
  List<Object?> get props => [failure];
}

final class DashboardActionsLoaded extends DashboardActionsState {
  final List<CorrectiveAction> actions;

  /// Set when the last status change could not be saved; cleared by the next change.
  final Failure? actionFailure;

  const DashboardActionsLoaded({required this.actions, this.actionFailure});

  /// One entry per [ActionStatus] in board order; each keeps the source order.
  Map<ActionStatus, List<CorrectiveAction>> get columns => {
    for (final status in ActionStatus.values)
      status: actions.where((a) => a.status == status).toList(),
  };

  ActionsSummary get summary => ActionsSummary.fromActions(actions);

  @override
  List<Object?> get props => [actions, actionFailure];
}
