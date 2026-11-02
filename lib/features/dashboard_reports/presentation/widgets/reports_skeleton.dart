import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../domain/entities/monthly_report.dart';
import '../../domain/entities/report_activity.dart';
import '../../domain/entities/report_facility.dart';
import '../../domain/entities/report_month.dart';
import 'reports_table.dart';

/// Shimmering stand-in for the reports table while Firebase loads. The
/// reports below only give the bones their shape; none of their text is
/// readable.
class ReportsSkeleton extends StatelessWidget {
  static const _month = ReportMonth(id: '0000-00', label: 'الشهر');
  static const _activity = ReportActivity(
    date: '0000-00-00',
    type: ActivityType.inspection,
    description: 'النشاط',
    owner: 'المسؤول',
    status: ActivityStatus.completed,
  );
  static final _reports = [
    for (var i = 0; i < 5; i++)
      MonthlyReport(
        facility: ReportFacility(
          id: 'skeleton-$i',
          name: 'اسم المنشأة',
          sector: 'القطاع',
          contractPeriod: '',
        ),
        month: _month,
        activities: List.filled(3, _activity),
      ),
  ];

  const ReportsSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Skeletonizer(
    child: ReportsTable(reports: _reports, onPreview: (_) {}, onSend: (_) {}),
  );
}
