import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/action_status.dart';
import '../../domain/usecases/get_corrective_actions.dart';
import '../../domain/usecases/update_action_status.dart';
import 'dashboard_actions_state.dart';

/// Loads the corrective actions and moves them between workflow stages.
class DashboardActionsCubit extends Cubit<DashboardActionsState> {
  final GetCorrectiveActions _getActions;
  final UpdateActionStatus _updateStatus;

  DashboardActionsCubit({
    required GetCorrectiveActions getActions,
    required UpdateActionStatus updateStatus,
  }) : _getActions = getActions,
       _updateStatus = updateStatus,
       super(const DashboardActionsInitial());

  Future<void> load() async {
    emit(const DashboardActionsLoading());
    final result = await _getActions(const NoParams());
    if (isClosed) return;
    emit(
      result.fold(
        DashboardActionsFailure.new,
        (actions) => DashboardActionsLoaded(actions: actions),
      ),
    );
  }

  /// Moves action [id] to [status]; the board regroups it into that column.
  Future<void> moveAction(String id, ActionStatus status) async {
    if (state is! DashboardActionsLoaded) return;
    final result = await _updateStatus(
      UpdateActionStatusParams(actionId: id, status: status),
    );
    final current = state;
    if (isClosed || current is! DashboardActionsLoaded) return;
    emit(
      result.fold(
        (failure) => DashboardActionsLoaded(
          actions: current.actions,
          actionFailure: failure,
        ),
        (updated) => DashboardActionsLoaded(
          actions: [
            for (final a in current.actions) a.id == updated.id ? updated : a,
          ],
        ),
      ),
    );
  }
}
