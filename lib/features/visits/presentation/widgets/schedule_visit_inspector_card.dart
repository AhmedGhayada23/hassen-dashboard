import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/inspector.dart';

/// Selectable inspector tile: name, weekly load, and "suggested"/"busy" tags.
class ScheduleVisitInspectorCard extends StatelessWidget {
  final Inspector inspector;
  final int weeklyVisits;
  final bool selected;
  final bool suggested;
  final bool busy;
  final VoidCallback onTap;

  const ScheduleVisitInspectorCard({
    super.key,
    required this.inspector,
    required this.weeklyVisits,
    required this.selected,
    required this.suggested,
    required this.busy,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? HaseenColors.navy : Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.r),
      side: BorderSide(
        color: selected ? HaseenColors.navy : HaseenColors.fieldBorder,
        width: 1.5,
      ),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(10.r),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    inspector.name,
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : HaseenColors.navy,
                    ),
                  ),
                ),
                if (suggested)
                  const StatusBadge(
                    'مقترح',
                    HaseenColors.gold,
                    HaseenColors.navy,
                  ),
                if (busy)
                  const StatusBadge(
                    'مشغول',
                    HaseenColors.criticalSoft,
                    HaseenColors.red,
                  ),
              ],
            ),
            Text(
              '$weeklyVisits زيارات هذا الأسبوع',
              style: TextStyle(
                fontSize: 11.5.sp,
                color: selected ? HaseenColors.mutedOnNavy : HaseenColors.muted,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
