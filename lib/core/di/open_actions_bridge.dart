import '../../features/dashboard_actions/domain/entities/action_severity.dart';
import '../../features/dashboard_actions/domain/entities/action_status.dart';
import '../../features/dashboard_actions/domain/repositories/corrective_actions_repository.dart';
import '../../features/visits/data/datasources/open_actions_datasource.dart';
import '../../features/visits/domain/entities/facility_open_action.dart';

/// Hands the visits schedule the corrective actions still open, from the
/// actions board, so neither feature imports the other.
class CorrectiveActionsOpenActions implements OpenActionsDataSource {
  final CorrectiveActionsRepository _actions;

  const CorrectiveActionsOpenActions(this._actions);

  /// Empty when the board can't be read: a visit can still be booked, just
  /// without its follow-up tasks.
  @override
  Future<List<FacilityOpenAction>> getOpenActions() async =>
      (await _actions.getActions()).fold(
        (_) => const [],
        (actions) => [
          for (final a in actions)
            if (a.status != ActionStatus.closed)
              FacilityOpenAction(
                id: a.id,
                title: a.title,
                facility: a.facility,
                statusLabel: _statusLabel(a.status),
                severityLabel: _severityLabel(a.severity),
                hasEvidence: a.status == ActionStatus.pendingClosure,
              ),
        ],
      );

  // As the visit tasks word them for the inspector.
  static String _statusLabel(ActionStatus status) => switch (status) {
    ActionStatus.open => 'مفتوح',
    ActionStatus.inProgress => 'قيد التنفيذ',
    ActionStatus.pendingClosure => 'دليل مرفوع',
    ActionStatus.closed => 'مغلق',
  };

  static String _severityLabel(ActionSeverity severity) => switch (severity) {
    ActionSeverity.critical => 'حرج',
    ActionSeverity.high => 'عالٍ',
    ActionSeverity.medium => 'متوسط',
    ActionSeverity.low => 'منخفض',
  };
}
