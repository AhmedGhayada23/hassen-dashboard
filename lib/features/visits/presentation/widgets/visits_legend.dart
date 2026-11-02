import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/visit_status.dart';
import '../config/visit_status_style.dart';

/// Color key for every visit status.
class VisitsLegend extends StatelessWidget {
  const VisitsLegend({super.key});

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 16.w,
    runSpacing: 8.h,
    children: [
      for (final status in VisitStatus.values)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10.r,
              height: 10.r,
              decoration: BoxDecoration(
                color: status.style.bar,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(width: 6.w),
            Text(
              status.style.label,
              style: TextStyle(fontSize: 12.sp, color: HaseenColors.muted),
            ),
          ],
        ),
    ],
  );
}
