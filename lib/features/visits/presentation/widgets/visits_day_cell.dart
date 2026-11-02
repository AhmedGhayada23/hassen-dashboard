import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/visit.dart';
import '../config/visits_layout_config.dart';
import 'visit_chip.dart';

/// One inspector × day cell holding that day's visits.
class VisitsDayCell extends StatelessWidget {
  final List<Visit> visits;
  final bool isToday;
  final ValueChanged<Visit> onVisitTap;

  const VisitsDayCell({
    super.key,
    required this.visits,
    required this.isToday,
    required this.onVisitTap,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: VisitsLayoutConfig.dayColumnWidth,
    constraints: BoxConstraints(minHeight: VisitsLayoutConfig.dayCellMinHeight),
    padding: EdgeInsets.all(8.r),
    decoration: BoxDecoration(
      color: isToday ? HaseenColors.todayTint : Colors.white,
      border: const Border(
        bottom: BorderSide(color: HaseenColors.soft),
        right: BorderSide(color: HaseenColors.soft),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final visit in visits)
          Padding(
            padding: EdgeInsets.only(bottom: 6.h),
            child: VisitChip(visit: visit, onTap: () => onVisitTap(visit)),
          ),
      ],
    ),
  );
}
