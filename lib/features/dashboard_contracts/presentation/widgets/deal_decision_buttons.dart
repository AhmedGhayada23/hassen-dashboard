import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/deal.dart';

/// The decisions open to a deal: "قبول العقد" unless it is accepted, and
/// "رفض" unless it is rejected — so a decision can always be changed.
class DealDecisionButtons extends StatelessWidget {
  static const acceptLabel = 'قبول العقد';
  static const rejectLabel = 'رفض';

  final Deal deal;

  /// Disables both while the deal's last change is being saved.
  final bool isSaving;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const DealDecisionButtons({
    super.key,
    required this.deal,
    required this.onAccept,
    required this.onReject,
    this.isSaving = false,
  });

  @override
  Widget build(BuildContext context) {
    final label = TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w700);
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(6.r),
    );
    return Wrap(
      spacing: 6.w,
      runSpacing: 6.h,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (!deal.isAccepted)
          FilledButton(
            onPressed: isSaving ? null : onAccept,
            style: FilledButton.styleFrom(
              backgroundColor: HaseenColors.teal,
              minimumSize: Size(0, 32.h),
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              shape: shape,
            ),
            child: Text(acceptLabel, style: label),
          ),
        if (!deal.isRejected)
          OutlinedButton(
            onPressed: isSaving ? null : onReject,
            style: OutlinedButton.styleFrom(
              foregroundColor: HaseenColors.red,
              minimumSize: Size(0, 32.h),
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              side: const BorderSide(color: HaseenColors.dangerBorder),
              shape: shape,
            ),
            child: Text(rejectLabel, style: label),
          ),
        if (isSaving)
          SizedBox.square(
            dimension: 16.r,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
      ],
    );
  }
}
