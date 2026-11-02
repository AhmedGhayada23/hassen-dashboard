import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/visit.dart';
import '../config/visit_status_style.dart';
import '../config/visit_task_source_label.dart';

/// Tappable visit card inside a day cell, tinted by status with a leading bar,
/// with its task count.
class VisitChip extends StatelessWidget {
  final Visit visit;
  final VoidCallback onTap;

  const VisitChip({super.key, required this.visit, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final style = visit.status.style;
    final radius = BorderRadius.circular(7.r);
    return Material(
      color: style.background,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
          decoration: BoxDecoration(
            borderRadius: radius,
            border: BorderDirectional(
              start: BorderSide(color: style.bar, width: 3),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${visit.time} · ${visit.facility}',
                style: TextStyle(
                  fontSize: 11.5.sp,
                  fontWeight: FontWeight.w700,
                  color: HaseenColors.navy,
                ),
              ),
              Text(
                visit.type,
                style: TextStyle(fontSize: 11.5.sp, color: HaseenColors.muted),
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Icon(Icons.checklist, size: 13.sp, color: HaseenColors.navy),
                  SizedBox(width: 4.w),
                  Text(
                    visitTaskCount(visit.tasks.length),
                    style: TextStyle(
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w700,
                      color: HaseenColors.navy,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
