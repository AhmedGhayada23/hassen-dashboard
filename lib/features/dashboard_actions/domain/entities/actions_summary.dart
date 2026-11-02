import 'package:equatable/equatable.dart';

import 'action_status.dart';
import 'corrective_action.dart';

/// Counts derived from one list of actions, so they can never drift from it.
class ActionsSummary extends Equatable {
  final Map<ActionStatus, int> countsByStatus;
  final int lateCount;

  /// Late or due-soon actions — the red sidebar counter.
  final int attentionCount;

  const ActionsSummary({
    required this.countsByStatus,
    required this.lateCount,
    required this.attentionCount,
  });

  factory ActionsSummary.fromActions(List<CorrectiveAction> actions) =>
      ActionsSummary(
        countsByStatus: {
          for (final status in ActionStatus.values)
            status: actions.where((a) => a.status == status).length,
        },
        lateCount: actions.where((a) => a.isLate).length,
        attentionCount: actions.where((a) => a.dueStatus.needsAttention).length,
      );

  int get total => countsByStatus.values.fold(0, (sum, n) => sum + n);

  @override
  List<Object> get props => [countsByStatus, lateCount, attentionCount];
}
