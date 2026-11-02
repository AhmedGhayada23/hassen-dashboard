import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../shared/dashboard_shell/presentation/config/dashboard_layout_config.dart';
import '../../domain/entities/inspector.dart';
import '../../domain/entities/visit.dart';
import '../../domain/entities/visit_day.dart';
import '../../domain/entities/visit_schedule.dart';
import '../../domain/entities/visit_status.dart';
import 'visits_legend.dart';
import 'visits_page_header.dart';
import 'visits_schedule_grid.dart';

/// Shimmering stand-in for the schedule while Firebase loads: the real
/// header, grid and legend, drawn as bones. The week below only gives the
/// bones their shape; none of its text is ever readable.
class VisitsSkeleton extends StatelessWidget {
  static final _placeholder = () {
    final inspectors = [
      for (var i = 0; i < 4; i++)
        Inspector(id: 'skeleton-$i', name: 'اسم المفتش'),
    ];
    final days = [
      for (var i = 0; i < 6; i++)
        VisitDay(order: i, label: 'اليوم 00', date: ''),
    ];
    return VisitSchedule(
      weekLabel: 'الأسبوع 00 – 00 الشهر 0000',
      inspectors: inspectors,
      days: days,
      today: days[4],
      visits: [
        for (final (i, inspector) in inspectors.indexed)
          Visit(
            inspector: inspector,
            day: days[(i * 2) % days.length],
            time: '00:00',
            facility: 'اسم المنشأة',
            type: 'نوع الزيارة',
            status: VisitStatus.planned,
          ),
      ],
    );
  }();

  const VisitsSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Skeletonizer(
    child: SingleChildScrollView(
      padding: DashboardLayoutConfig.contentPadding,
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          VisitsPageHeader(
            weekLabel: _placeholder.weekLabel,
            onScheduleVisit: () {},
            onPreviousWeek: () {},
            onNextWeek: () {},
          ),
          SizedBox(height: DashboardLayoutConfig.sectionGap),
          VisitsScheduleGrid(schedule: _placeholder, onVisitTap: (_) {}),
          SizedBox(height: DashboardLayoutConfig.sectionGap),
          const VisitsLegend(),
        ],
      ),
    ),
  );
}
