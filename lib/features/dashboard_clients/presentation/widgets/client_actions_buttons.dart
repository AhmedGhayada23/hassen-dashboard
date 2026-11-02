import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';

/// "جدولة زيارة" and "التقارير" side by side.
class ClientActionsButtons extends StatelessWidget {
  final VoidCallback onScheduleVisit;
  final VoidCallback onReports;

  const ClientActionsButtons({
    super.key,
    required this.onScheduleVisit,
    required this.onReports,
  });

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.r),
    );
    final label = TextStyle(fontWeight: FontWeight.w700, fontSize: 13.sp);
    return Row(
      children: [
        Expanded(
          child: FilledButton(
            onPressed: onScheduleVisit,
            style: FilledButton.styleFrom(
              backgroundColor: HaseenColors.navy,
              minimumSize: Size(0, 38.h),
              shape: shape,
            ),
            child: Text('جدولة زيارة', style: label),
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: OutlinedButton(
            onPressed: onReports,
            style: OutlinedButton.styleFrom(
              foregroundColor: HaseenColors.navy,
              minimumSize: Size(0, 38.h),
              side: const BorderSide(color: HaseenColors.chipBorder),
              shape: shape,
            ),
            child: Text('التقارير', style: label),
          ),
        ),
      ],
    );
  }
}
