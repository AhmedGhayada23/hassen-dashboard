import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';

/// Red notice shown while the chosen inspector is busy at the chosen slot.
class ScheduleVisitConflictNotice extends StatelessWidget {
  static const message =
      'لدى هذا المفتش زيارة في نفس اليوم والوقت. اختر وقتاً أو مفتشاً آخر.';

  const ScheduleVisitConflictNotice({super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
    decoration: BoxDecoration(
      color: HaseenColors.dangerTint,
      border: Border.all(color: HaseenColors.dangerBorder),
      borderRadius: BorderRadius.circular(8.r),
    ),
    child: Text(
      message,
      style: TextStyle(fontSize: 12.5.sp, color: HaseenColors.red),
    ),
  );
}
