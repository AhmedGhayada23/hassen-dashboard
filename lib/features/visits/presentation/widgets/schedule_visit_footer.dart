import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';

/// Dialog footer: "schedule & assign" (disabled on a clash), cancel, and a hint.
class ScheduleVisitFooter extends StatelessWidget {
  final bool canSubmit;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  const ScheduleVisitFooter({
    super.key,
    required this.canSubmit,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
    decoration: BoxDecoration(
      color: HaseenColors.tableHeader,
      border: const Border(top: BorderSide(color: HaseenColors.line)),
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(14.r)),
    ),
    child: Row(
      children: [
        FilledButton(
          onPressed: canSubmit ? onSubmit : null,
          style: FilledButton.styleFrom(
            backgroundColor: HaseenColors.gold,
            foregroundColor: HaseenColors.navy,
            minimumSize: Size(0, 42.h),
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          child: const Text(
            'جدولة وإسناد',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        SizedBox(width: 10.w),
        OutlinedButton(
          onPressed: onCancel,
          style: OutlinedButton.styleFrom(
            foregroundColor: HaseenColors.navy,
            minimumSize: Size(0, 42.h),
            side: const BorderSide(color: HaseenColors.fieldBorder),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          child: const Text(
            'إلغاء',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            'تصل الزيارة للمفتش في التطبيق الميداني',
            textAlign: TextAlign.end,
            style: TextStyle(fontSize: 11.5.sp, color: HaseenColors.muted),
          ),
        ),
      ],
    ),
  );
}
