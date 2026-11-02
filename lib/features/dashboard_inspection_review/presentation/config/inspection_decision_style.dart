import 'package:flutter/painting.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/inspection_decision.dart';

/// List pill label and colors for each review decision.
class InspectionDecisionStyle {
  final String label;
  final Color background, foreground;

  const InspectionDecisionStyle(this.label, this.background, this.foreground);
}

extension InspectionDecisionStyling on InspectionDecision {
  InspectionDecisionStyle get style => switch (this) {
    InspectionDecision.approved => const InspectionDecisionStyle(
      'معتمد',
      HaseenColors.successSoft,
      HaseenColors.successText,
    ),
    InspectionDecision.returned => const InspectionDecisionStyle(
      'أُعيد للمفتش',
      HaseenColors.soft,
      HaseenColors.neutralText,
    ),
    InspectionDecision.pending => const InspectionDecisionStyle(
      'بانتظار',
      HaseenColors.warningSoft,
      HaseenColors.warningTextDark,
    ),
  };
}
