import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/inspection_decision.dart';

/// Outcome banner for a decided report, with an undo link.
class InspectionDecisionStatus extends StatelessWidget {
  final InspectionDecision decision;
  final VoidCallback onUndo;

  const InspectionDecisionStatus({
    super.key,
    required this.decision,
    required this.onUndo,
  });

  @override
  Widget build(BuildContext context) {
    final approved = decision == InspectionDecision.approved;
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: approved ? HaseenColors.successSoft : HaseenColors.soft,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            approved
                ? 'تم الاعتماد — النتائج ظاهرة الآن لدى المنشأة'
                : 'أُعيد للمفتش مع ملاحظات',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: approved
                  ? HaseenColors.successText
                  : HaseenColors.neutralText,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        TextButton(
          onPressed: onUndo,
          child: const Text(
            'تراجع',
            style: TextStyle(
              color: HaseenColors.muted,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
