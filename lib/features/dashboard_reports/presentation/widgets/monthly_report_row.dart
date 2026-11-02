import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/monthly_report.dart';
import '../../domain/entities/report_activity.dart';
import '../config/report_styles.dart';
import '../config/reports_messages.dart';

/// A facility's month: counts by type, total, report status, and the
/// preview / email buttons.
class MonthlyReportRow extends StatelessWidget {
  static const previewLabel = 'معاينة';
  static const sendLabel = 'إرسال عبر الإيميل';
  static const resendLabel = 'إعادة إرسال';

  final MonthlyReport report;
  final VoidCallback onPreview;
  final VoidCallback onSend;

  const MonthlyReportRow({
    super.key,
    required this.report,
    required this.onPreview,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final flex = ReportsTableConfig.columnFlex;
    final status = report.statusStyle;
    Widget number(int value, {bool bold = false}) => Text(
      '$value',
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
        color: HaseenColors.navy,
      ),
    );
    final label = TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w700);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(6.r),
    );
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: HaseenColors.soft)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: flex[0],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  report.facility.name,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: HaseenColors.navy,
                  ),
                ),
                Text(
                  report.facility.sector,
                  style: TextStyle(fontSize: 12.sp, color: HaseenColors.muted),
                ),
              ],
            ),
          ),
          for (final (i, type) in const [
            ActivityType.inspection,
            ActivityType.incident,
            ActivityType.check,
            ActivityType.repair,
          ].indexed)
            Expanded(flex: flex[i + 1], child: number(report.countOf(type))),
          Expanded(flex: flex[5], child: number(report.total, bold: true)),
          Expanded(
            flex: flex[6],
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: StatusBadge(
                status.label,
                status.background,
                status.foreground,
              ),
            ),
          ),
          Expanded(
            flex: flex[7],
            child: Wrap(
              spacing: 6.w,
              runSpacing: 6.h,
              children: [
                OutlinedButton.icon(
                  onPressed: onPreview,
                  icon: Icon(Icons.visibility_outlined, size: 15.sp),
                  label: Text(previewLabel, style: label),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: HaseenColors.navy,
                    minimumSize: Size(0, 32.h),
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    side: const BorderSide(color: HaseenColors.fieldBorder),
                    shape: shape,
                  ),
                ),
                FilledButton.icon(
                  onPressed: onSend,
                  icon: Icon(Icons.mail_outline, size: 15.sp),
                  label: Text(
                    report.isSent ? resendLabel : sendLabel,
                    style: label,
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: HaseenColors.navy,
                    minimumSize: Size(0, 32.h),
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    shape: shape,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
