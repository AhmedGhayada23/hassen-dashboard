import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/visit_task.dart';
import '../config/visit_task_source_label.dart';

/// A task's title, its detail line (if any) and, in teal, where it came from.
class VisitTaskText extends StatelessWidget {
  final VisitTask task;

  const VisitTaskText({super.key, required this.task});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        task.title,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          color: HaseenColors.navy,
          height: 1.45,
        ),
      ),
      if (task.detail.isNotEmpty)
        Text(
          task.detail,
          style: TextStyle(fontSize: 12.sp, color: HaseenColors.muted),
        ),
      Text(
        task.source.label,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w700,
          color: HaseenColors.teal,
        ),
      ),
    ],
  );
}

/// A task as the inspector sees it: numbered, in a bordered card.
class VisitTaskTile extends StatelessWidget {
  final VisitTask task;
  final int number;

  const VisitTaskTile({super.key, required this.task, required this.number});

  @override
  Widget build(BuildContext context) => Container(
    margin: EdgeInsets.only(bottom: 8.h),
    padding: EdgeInsets.all(12.r),
    decoration: BoxDecoration(
      border: Border.all(color: HaseenColors.line),
      borderRadius: BorderRadius.circular(10.r),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24.r,
          height: 24.r,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: HaseenColors.navy,
            shape: BoxShape.circle,
          ),
          child: Text(
            '$number',
            style: TextStyle(
              color: HaseenColors.gold,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(child: VisitTaskText(task: task)),
      ],
    ),
  );
}
