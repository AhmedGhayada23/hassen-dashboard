import 'package:flutter/material.dart';

import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/visit.dart';
import '../../domain/entities/visit_schedule.dart';
import 'visits_day_cell.dart';
import 'visits_day_header.dart';
import 'visits_inspector_cell.dart';

/// Inspectors × days grid; scrolls horizontally when the page is narrower.
class VisitsScheduleGrid extends StatelessWidget {
  final VisitSchedule schedule;
  final ValueChanged<Visit> onVisitTap;

  const VisitsScheduleGrid({
    super.key,
    required this.schedule,
    required this.onVisitTap,
  });

  @override
  Widget build(BuildContext context) => AppCard(
    clipBehavior: Clip.antiAlias,
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          VisitsDayHeader(days: schedule.days, today: schedule.today),
          for (final inspector in schedule.inspectors)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  VisitsInspectorCell(
                    inspector: inspector,
                    visitCount: schedule.visitCountFor(inspector),
                  ),
                  for (final day in schedule.days)
                    VisitsDayCell(
                      visits: schedule.visitsFor(inspector, day),
                      isToday: schedule.isToday(day),
                      onVisitTap: onVisitTap,
                    ),
                ],
              ),
            ),
        ],
      ),
    ),
  );
}
