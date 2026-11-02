import 'package:flutter/painting.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/finding_severity.dart';

/// Arabic label and badge colors for each severity.
class FindingSeverityStyle {
  final String label;
  final Color background, foreground;

  const FindingSeverityStyle(this.label, this.background, this.foreground);
}

extension FindingSeverityStyling on FindingSeverity {
  FindingSeverityStyle get style => switch (this) {
    FindingSeverity.critical => const FindingSeverityStyle(
      'حرج',
      HaseenColors.criticalSoft,
      HaseenColors.red,
    ),
    FindingSeverity.high => const FindingSeverityStyle(
      'عالٍ',
      HaseenColors.highSoft,
      HaseenColors.highText,
    ),
    FindingSeverity.medium => const FindingSeverityStyle(
      'متوسط',
      HaseenColors.mediumSoft,
      HaseenColors.mediumText,
    ),
    FindingSeverity.low => const FindingSeverityStyle(
      'منخفض',
      HaseenColors.lowSoft,
      HaseenColors.successText,
    ),
  };
}
