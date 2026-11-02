import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/visit_day.dart';
import '../config/visits_layout_config.dart';

/// Header row of the grid: "المفتش" then one cell per day, today in navy.
class VisitsDayHeader extends StatelessWidget {
  final List<VisitDay> days;
  final VisitDay? today;

  const VisitsDayHeader({super.key, required this.days, this.today});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      VisitsHeadCell(
        text: 'المفتش',
        width: VisitsLayoutConfig.inspectorColumnWidth,
      ),
      for (final day in days)
        VisitsHeadCell(
          text: day.label,
          width: VisitsLayoutConfig.dayColumnWidth,
          isDay: true,
          isToday: day == today,
        ),
    ],
  );
}

class VisitsHeadCell extends StatelessWidget {
  final String text;
  final double width;
  final bool isDay;
  final bool isToday;

  const VisitsHeadCell({
    super.key,
    required this.text,
    required this.width,
    this.isDay = false,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: width,
    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
    decoration: BoxDecoration(
      color: isToday ? HaseenColors.navy : HaseenColors.tableHeader,
      border: Border(
        bottom: const BorderSide(color: HaseenColors.line),
        right: isDay
            ? const BorderSide(color: HaseenColors.soft)
            : BorderSide.none,
      ),
    ),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 12.sp,
        fontWeight: isDay ? FontWeight.w700 : FontWeight.w600,
        color: isToday ? Colors.white : HaseenColors.muted,
      ),
    ),
  );
}
