import 'package:flutter/painting.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/action_severity.dart';

/// Arabic label and text color for each severity.
class ActionSeverityStyle {
  final String label;
  final Color color;

  const ActionSeverityStyle(this.label, this.color);
}

extension ActionSeverityStyling on ActionSeverity {
  ActionSeverityStyle get style => switch (this) {
    ActionSeverity.critical => const ActionSeverityStyle(
      'حرج',
      HaseenColors.red,
    ),
    ActionSeverity.high => const ActionSeverityStyle(
      'عالٍ',
      HaseenColors.highText,
    ),
    ActionSeverity.medium => const ActionSeverityStyle(
      'متوسط',
      HaseenColors.mediumText,
    ),
    ActionSeverity.low => const ActionSeverityStyle(
      'منخفض',
      HaseenColors.successText,
    ),
  };
}
