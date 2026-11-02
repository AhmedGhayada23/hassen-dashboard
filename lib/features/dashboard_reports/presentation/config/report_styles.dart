import 'package:flutter/painting.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/monthly_report.dart';
import '../../domain/entities/report_activity.dart';

/// Pill text and colors.
class ReportPillStyle {
  final String label;
  final Color background, foreground;

  const ReportPillStyle(this.label, this.background, this.foreground);
}

const _green = (HaseenColors.successSoft, HaseenColors.successText);
const _amber = (HaseenColors.warningSoft, HaseenColors.warningTextDark);
const _blue = (HaseenColors.infoSoft, HaseenColors.infoText);
const _grey = (HaseenColors.soft, HaseenColors.neutralText);
const _red = (HaseenColors.dangerSoft, HaseenColors.red);

ReportPillStyle _pill(String label, (Color, Color) colors) =>
    ReportPillStyle(label, colors.$1, colors.$2);

extension ActivityTypeStyling on ActivityType {
  ReportPillStyle get style => switch (this) {
    ActivityType.inspection => _pill('تفتيش', _blue),
    ActivityType.incident => _pill('بلاغ', _red),
    ActivityType.check => _pill('فحص', (
      HaseenColors.tealSoft,
      HaseenColors.tealText,
    )),
    ActivityType.repair => _pill('إصلاح', _amber),
  };
}

extension ActivityStatusStyling on ActivityStatus {
  ReportPillStyle get style => switch (this) {
    ActivityStatus.completed => _pill('مكتمل', _green),
    ActivityStatus.closed => _pill('مغلق', _green),
    ActivityStatus.handling => _pill('قيد المعالجة', _amber),
    ActivityStatus.inProgress => _pill('قيد التنفيذ', _amber),
    ActivityStatus.awaitingVerification => _pill('بانتظار التحقق', _blue),
    ActivityStatus.open => _pill('مفتوح', _grey),
    ActivityStatus.overdue => _pill('متأخر', _red),
    ActivityStatus.scheduled => _pill('مجدولة', _grey),
  };
}

extension MonthlyReportStyling on MonthlyReport {
  ReportPillStyle get statusStyle => switch (status) {
    MonthlyReportStatus.sent => _pill('أُرسل $sentOn', _green),
    MonthlyReportStatus.ready => _pill('جاهز للإرسال', _amber),
    MonthlyReportStatus.empty => _pill('لا توجد أنشطة', _grey),
  };
}
