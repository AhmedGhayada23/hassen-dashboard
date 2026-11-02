import 'package:flutter/material.dart';

import '../../domain/entities/action_status.dart';
import '../../domain/entities/corrective_action.dart';
import '../config/actions_layout_config.dart';
import 'actions_kanban_column.dart';

/// Four equal-height columns; scrolls horizontally when they don't fit.
class ActionsKanbanBoard extends StatelessWidget {
  final Map<ActionStatus, List<CorrectiveAction>> columns;
  final ValueChanged<CorrectiveAction> onActionTap;

  const ActionsKanbanBoard({
    super.key,
    required this.columns,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = ActionsLayoutConfig.columnWidth(constraints.maxWidth);
      final entries = columns.entries.toList();
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < entries.length; i++) ...[
                if (i > 0) SizedBox(width: ActionsLayoutConfig.columnGap),
                SizedBox(
                  width: width,
                  child: ActionsKanbanColumn(
                    status: entries[i].key,
                    actions: entries[i].value,
                    onActionTap: onActionTap,
                  ),
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}
