import 'package:flutter/painting.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/action_status.dart';

/// Kanban column title and dot color for each workflow stage.
class ActionStatusStyle {
  final String label;
  final Color dot;

  const ActionStatusStyle(this.label, this.dot);
}

extension ActionStatusStyling on ActionStatus {
  ActionStatusStyle get style => switch (this) {
    ActionStatus.open => const ActionStatusStyle(
      'مفتوحة لدى المنشأة',
      HaseenColors.neutralBar,
    ),
    ActionStatus.inProgress => const ActionStatusStyle(
      'قيد التنفيذ',
      HaseenColors.gold,
    ),
    ActionStatus.pendingClosure => const ActionStatusStyle(
      'مطلوب إغلاقها',
      HaseenColors.teal,
    ),
    ActionStatus.closed => const ActionStatusStyle('مغلقة', HaseenColors.green),
  };
}
