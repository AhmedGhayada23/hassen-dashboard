import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/asset_paths.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/monthly_report.dart';
import '../../domain/entities/report_activity.dart';
import '../config/reports_messages.dart';
import 'report_activity_table.dart';

/// Shows [report] as the facility will receive it; completes with true when
/// "إرسال عبر الإيميل" is chosen.
Future<bool> showMonthlyReportPreview(
  BuildContext context,
  MonthlyReport report,
) async =>
    await showDialog<bool>(
      context: context,
      barrierColor: HaseenColors.navy.withValues(alpha: .6),
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: MonthlyReportPreview(report: report),
      ),
    ) ??
    false;

/// The monthly report as a document: letterhead, facility facts, counts by
/// type, the activity table, what carries over, and a footer — under a bar
/// with the file name, "send" and "close".
class MonthlyReportPreview extends StatelessWidget {
  final MonthlyReport report;

  const MonthlyReportPreview({super.key, required this.report});

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: Colors.transparent,
    elevation: 0,
    insetPadding: EdgeInsets.all(20.r),
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 820.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.description_outlined,
                color: Colors.white,
                size: 18.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  report.fileName,
                  textDirection: TextDirection.ltr,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                style: FilledButton.styleFrom(
                  backgroundColor: HaseenColors.gold,
                  foregroundColor: HaseenColors.navy,
                  minimumSize: Size(0, 36.h),
                ),
                child: Text(
                  'إرسال عبر الإيميل',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13.sp,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              IconButton(
                tooltip: 'إغلاق',
                onPressed: () => Navigator.pop(context, false),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Flexible(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 44.w, vertical: 40.h),
                child: _ReportSheet(report: report),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _ReportSheet extends StatelessWidget {
  final MonthlyReport report;

  const _ReportSheet({required this.report});

  @override
  Widget build(BuildContext context) {
    final muted = TextStyle(fontSize: 12.sp, color: HaseenColors.muted);
    final footer = TextStyle(fontSize: 11.sp, color: HaseenColors.hint);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.only(bottom: 14.h),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: HaseenColors.navy, width: 2),
            ),
          ),
          child: Row(
            children: [
              Image.asset(
                AssetPaths.haseenLogo,
                width: 40.r,
                height: 40.r,
                errorBuilder: (_, _, _) => SizedBox(width: 40.r),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الحصين HASEEN',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: HaseenColors.navy,
                      ),
                    ),
                    Text('خدمات السلامة والصحة المهنية', style: muted),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'التقرير الشهري',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: HaseenColors.navy,
                    ),
                  ),
                  Text(
                    report.month.label,
                    style: muted.copyWith(fontSize: 12.5.sp),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 20.h),
        Row(
          children: [
            _Fact(label: 'المنشأة', value: report.facility.name),
            _Fact(label: 'القطاع', value: report.facility.sector),
            _Fact(label: 'فترة العقد', value: report.facility.contractPeriod),
          ],
        ),
        SizedBox(height: 20.h),
        Row(
          children: [
            for (final (i, (label, type)) in const [
              ('تفتيش', ActivityType.inspection),
              ('بلاغات', ActivityType.incident),
              ('فحوصات', ActivityType.check),
              ('إصلاحات', ActivityType.repair),
            ].indexed) ...[
              if (i > 0) SizedBox(width: 10.w),
              Expanded(
                child: _CountBox(label: label, count: report.countOf(type)),
              ),
            ],
          ],
        ),
        SizedBox(height: 20.h),
        ReportActivityTable(activities: report.activities),
        if (report.activities.isEmpty)
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Text(
              ReportsMessages.noActivities,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, color: HaseenColors.muted),
            ),
          ),
        SizedBox(height: 16.h),
        Text(
          ReportsMessages.carriedOver(report),
          style: TextStyle(fontSize: 12.5.sp, color: HaseenColors.neutralText),
        ),
        SizedBox(height: 20.h),
        const Divider(color: HaseenColors.line, height: 1),
        SizedBox(height: 10.h),
        Text('أُعدّ تلقائياً من منصة الحصين', style: footer),
      ],
    );
  }
}

class _Fact extends StatelessWidget {
  final String label, value;

  const _Fact({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: HaseenColors.muted),
        ),
        SizedBox(height: 2.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: HaseenColors.navy,
          ),
        ),
      ],
    ),
  );
}

class _CountBox extends StatelessWidget {
  final String label;
  final int count;

  const _CountBox({required this.label, required this.count});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
    decoration: BoxDecoration(
      border: Border.all(color: HaseenColors.line),
      borderRadius: BorderRadius.circular(8.r),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$count',
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
            color: HaseenColors.navy,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: HaseenColors.muted),
        ),
      ],
    ),
  );
}
