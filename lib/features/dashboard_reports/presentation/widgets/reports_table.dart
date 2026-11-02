import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/monthly_report.dart';
import '../config/reports_messages.dart';
import 'monthly_report_row.dart';

/// One row per contracted facility: its month in counts, and its report.
class ReportsTable extends StatelessWidget {
  final List<MonthlyReport> reports;
  final ValueChanged<MonthlyReport> onPreview;
  final ValueChanged<MonthlyReport> onSend;

  /// Shown in place of the rows when there are no contracted facilities.
  final String emptyMessage;

  const ReportsTable({
    super.key,
    required this.reports,
    required this.onPreview,
    required this.onSend,
    this.emptyMessage = '',
  });

  @override
  Widget build(BuildContext context) => AppCard(
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: HaseenColors.tableHeader,
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 11.h),
          child: Row(
            children: [
              for (final (i, label) in ReportsTableConfig.headers.indexed)
                Expanded(
                  flex: ReportsTableConfig.columnFlex[i],
                  child: Text(label, style: AppTextStyles.tableHeader),
                ),
            ],
          ),
        ),
        if (reports.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 28.h),
            child: Text(
              emptyMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, color: HaseenColors.muted),
            ),
          ),
        for (final report in reports)
          MonthlyReportRow(
            report: report,
            onPreview: () => onPreview(report),
            onSend: () => onSend(report),
          ),
      ],
    ),
  );
}
