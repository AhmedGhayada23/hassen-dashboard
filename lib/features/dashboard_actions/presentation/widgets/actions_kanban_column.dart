import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/action_status.dart';
import '../../domain/entities/corrective_action.dart';
import '../config/action_status_style.dart';
import '../config/actions_layout_config.dart';
import 'corrective_action_card.dart';

/// One workflow stage: dot, title and count, then its action cards.
class ActionsKanbanColumn extends StatelessWidget {
  final ActionStatus status;
  final List<CorrectiveAction> actions;
  final ValueChanged<CorrectiveAction> onActionTap;

  const ActionsKanbanColumn({
    super.key,
    required this.status,
    required this.actions,
    required this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    final style = status.style;
    return Container(
      constraints: BoxConstraints(
        minHeight: ActionsLayoutConfig.columnMinHeight,
      ),
      padding: EdgeInsets.all(ActionsLayoutConfig.columnPadding),
      decoration: BoxDecoration(
        color: HaseenColors.soft,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
            child: Row(
              children: [
                Container(
                  width: 8.r,
                  height: 8.r,
                  decoration: BoxDecoration(
                    color: style.dot,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    style.label,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: HaseenColors.navy,
                    ),
                  ),
                ),
                Text(
                  '${actions.length}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: HaseenColors.muted,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: ActionsLayoutConfig.cardGap),
          for (final action in actions) ...[
            CorrectiveActionCard(
              action: action,
              onTap: () => onActionTap(action),
            ),
            SizedBox(height: ActionsLayoutConfig.cardGap),
          ],
        ],
      ),
    );
  }
}
