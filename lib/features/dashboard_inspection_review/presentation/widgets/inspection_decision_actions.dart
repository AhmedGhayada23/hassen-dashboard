import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';

/// Approve / return buttons shown while a report is pending.
class InspectionDecisionActions extends StatelessWidget {
  final VoidCallback onApprove;
  final VoidCallback onReturn;

  const InspectionDecisionActions({
    super.key,
    required this.onApprove,
    required this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8.r),
    );
    return Wrap(
      spacing: 10.w,
      runSpacing: 10.h,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        FilledButton(
          onPressed: onApprove,
          style: FilledButton.styleFrom(
            backgroundColor: HaseenColors.teal,
            minimumSize: Size(0, 42.h),
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            shape: shape,
          ),
          child: const Text(
            'اعتماد ونشر للمنشأة',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        OutlinedButton(
          onPressed: onReturn,
          style: OutlinedButton.styleFrom(
            foregroundColor: HaseenColors.navy,
            minimumSize: Size(0, 42.h),
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            side: const BorderSide(color: HaseenColors.chipBorder),
            shape: shape,
          ),
          child: const Text(
            'إعادة للمفتش',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        Text(
          'لا تظهر النتائج للمنشأة قبل الاعتماد، باستثناء الخطر الحرج.',
          style: TextStyle(fontSize: 12.sp, color: HaseenColors.muted),
        ),
      ],
    );
  }
}
