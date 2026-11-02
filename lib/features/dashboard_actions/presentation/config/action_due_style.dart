import 'package:flutter/painting.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/action_due_status.dart';

/// Due pill colors, plus the card outline (late cards get a red outline).
class ActionDueStyle {
  final Color background, foreground, cardBorder;

  const ActionDueStyle(
    this.background,
    this.foreground, {
    this.cardBorder = HaseenColors.line,
  });
}

extension ActionDueStyling on ActionDueStatus {
  ActionDueStyle get style => switch (this) {
    ActionDueStatus.late => const ActionDueStyle(
      HaseenColors.dangerSoft,
      HaseenColors.red,
      cardBorder: HaseenColors.dangerBorder,
    ),
    ActionDueStatus.soon => const ActionDueStyle(
      HaseenColors.warningSoft,
      HaseenColors.warningTextDark,
    ),
    ActionDueStatus.ok => const ActionDueStyle(
      HaseenColors.soft,
      HaseenColors.neutralText,
    ),
    ActionDueStatus.done => const ActionDueStyle(
      HaseenColors.successSoft,
      HaseenColors.successText,
    ),
  };
}
