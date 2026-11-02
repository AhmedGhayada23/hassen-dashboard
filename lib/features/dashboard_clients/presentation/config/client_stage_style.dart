import 'package:flutter/painting.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/client_stage.dart';

/// Arabic label and pill colors for each pipeline stage.
class ClientStageStyle {
  final String label;
  final Color background, foreground;

  const ClientStageStyle(this.label, this.background, this.foreground);
}

extension ClientStageStyling on ClientStage {
  ClientStageStyle get style => switch (this) {
    ClientStage.potential => const ClientStageStyle(
      'محتمل',
      HaseenColors.soft,
      HaseenColors.neutralText,
    ),
    ClientStage.inspection => const ClientStageStyle(
      'معاينة',
      HaseenColors.infoSoft,
      HaseenColors.infoText,
    ),
    ClientStage.quotation => const ClientStageStyle(
      'عرض سعر',
      HaseenColors.warningSoft,
      HaseenColors.warningTextDark,
    ),
    ClientStage.contracted => const ClientStageStyle(
      'متعاقد',
      HaseenColors.successSoft,
      HaseenColors.successText,
    ),
  };
}

extension NewClientStageText on ClientStage {
  /// One-line hint under the stage on the "new client" form.
  String get newClientDescription => switch (this) {
    ClientStage.potential => 'تواصل أولي فقط',
    ClientStage.inspection => 'زيارة معاينة مخططة',
    ClientStage.quotation => 'جاري إعداد عرض السعر',
    ClientStage.contracted => '',
  };
}

/// Filter chips in display order; null is "الكل" (all stages).
const clientStageFilters = <ClientStage?>[
  null,
  ClientStage.contracted,
  ClientStage.quotation,
  ClientStage.inspection,
  ClientStage.potential,
];

String clientStageFilterLabel(ClientStage? stage) =>
    stage?.style.label ?? 'الكل';
