import 'package:flutter/painting.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/visit_status.dart';

/// How a visit status is drawn: chip/pill background, side bar, text color.
class VisitStatusStyle {
  final String label;
  final Color background, bar, foreground;

  const VisitStatusStyle(
    this.label,
    this.background,
    this.bar,
    this.foreground,
  );
}

extension VisitStatusStyling on VisitStatus {
  VisitStatusStyle get style => switch (this) {
    VisitStatus.done => const VisitStatusStyle(
      'منجزة',
      HaseenColors.successSoft,
      HaseenColors.green,
      HaseenColors.successText,
    ),
    VisitStatus.inProgress => const VisitStatusStyle(
      'جارية',
      HaseenColors.warningSoft,
      HaseenColors.gold,
      HaseenColors.warningTextDark,
    ),
    VisitStatus.planned => const VisitStatusStyle(
      'مجدولة',
      HaseenColors.bg,
      HaseenColors.neutralBar,
      HaseenColors.neutralText,
    ),
    VisitStatus.preContract => const VisitStatusStyle(
      'فحص أولي قبل التعاقد',
      HaseenColors.dangerTint,
      HaseenColors.redStrong,
      HaseenColors.red,
    ),
  };
}
