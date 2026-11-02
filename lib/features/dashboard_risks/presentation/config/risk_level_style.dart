import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/risk_level.dart';

/// Colors for a risk level: a filled swatch (score badge, occupied matrix cell)
/// and a light tint (empty matrix cell), each with its text color.
class RiskLevelStyle {
  final Color filled, onFilled, empty, onEmpty;

  const RiskLevelStyle({
    required this.filled,
    required this.onFilled,
    required this.empty,
    required this.onEmpty,
  });
}

extension RiskLevelStyling on RiskLevel {
  RiskLevelStyle get style => switch (this) {
    RiskLevel.critical => const RiskLevelStyle(
      filled: HaseenColors.redStrong,
      onFilled: Colors.white,
      empty: HaseenColors.criticalSoft,
      onEmpty: HaseenColors.red,
    ),
    RiskLevel.high => const RiskLevelStyle(
      filled: HaseenColors.highStrong,
      onFilled: Colors.white,
      empty: HaseenColors.highSoft,
      onEmpty: HaseenColors.highText,
    ),
    RiskLevel.medium => const RiskLevelStyle(
      filled: HaseenColors.mediumStrong,
      onFilled: HaseenColors.navy,
      empty: HaseenColors.mediumSoft,
      onEmpty: HaseenColors.mediumText,
    ),
    RiskLevel.low => const RiskLevelStyle(
      filled: HaseenColors.green,
      onFilled: Colors.white,
      empty: HaseenColors.lowSoft,
      onEmpty: HaseenColors.successText,
    ),
  };
}
