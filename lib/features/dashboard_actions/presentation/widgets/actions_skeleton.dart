import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../shared/dashboard_shell/presentation/config/dashboard_layout_config.dart';
import '../../domain/entities/action_due_status.dart';
import '../../domain/entities/action_severity.dart';
import '../../domain/entities/action_status.dart';
import '../../domain/entities/corrective_action.dart';
import 'actions_kanban_board.dart';

/// Shimmering stand-in for the board while Firebase loads: the real columns
/// and cards, drawn as bones. The actions below only give the bones their
/// shape; none of their text is readable.
class ActionsSkeleton extends StatelessWidget {
  static final _columns = {
    for (final (status, count) in const [
      (ActionStatus.open, 2),
      (ActionStatus.inProgress, 3),
      (ActionStatus.pendingClosure, 2),
      (ActionStatus.closed, 1),
    ])
      status: [
        for (var i = 0; i < count; i++)
          CorrectiveAction(
            id: 'CA-0000',
            title: 'عنوان الإجراء التصحيحي المطلوب',
            facility: 'اسم المنشأة',
            severity: ActionSeverity.high,
            owner: 'المسؤول',
            dueText: '00 يوماً',
            dueStatus: ActionDueStatus.ok,
            status: status,
          ),
      ],
  };

  const ActionsSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Skeletonizer(
    child: SingleChildScrollView(
      padding: DashboardLayoutConfig.contentPadding,
      physics: const NeverScrollableScrollPhysics(),
      child: ActionsKanbanBoard(columns: _columns, onActionTap: (_) {}),
    ),
  );
}
