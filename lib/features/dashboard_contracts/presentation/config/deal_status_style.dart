import 'package:flutter/painting.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/deal_status.dart';

/// Status pill text and colors.
class DealStatusStyle {
  final String label;
  final Color background, foreground;

  const DealStatusStyle(this.label, this.background, this.foreground);
}

extension DealStatusStyling on DealStatus {
  DealStatusStyle get style => switch (this) {
    DealStatus.pending => const DealStatusStyle(
      'بانتظار القرار',
      HaseenColors.warningSoft,
      HaseenColors.warningTextDark,
    ),
    DealStatus.accepted => const DealStatusStyle(
      'مقبول',
      HaseenColors.successSoft,
      HaseenColors.successText,
    ),
    DealStatus.rejected => const DealStatusStyle(
      'مرفوض',
      HaseenColors.dangerSoft,
      HaseenColors.red,
    ),
  };
}
