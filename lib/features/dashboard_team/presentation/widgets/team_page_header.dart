import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Head count with the "add employee" action; the action shows a spinner
/// and is disabled while an account is being created.
class TeamPageHeader extends StatelessWidget {
  final int memberCount;
  final bool isAdding;
  final VoidCallback onAddEmployee;

  const TeamPageHeader({
    super.key,
    required this.memberCount,
    this.isAdding = false,
    required this.onAddEmployee,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text('$memberCount موظفين', style: AppTextStyles.cardTitle),
      const Spacer(),
      FilledButton(
        onPressed: isAdding ? null : onAddEmployee,
        style: FilledButton.styleFrom(
          backgroundColor: HaseenColors.gold,
          foregroundColor: HaseenColors.navy,
          disabledBackgroundColor: HaseenColors.gold.withValues(alpha: .7),
          minimumSize: Size(0, 38.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: isAdding
            ? SizedBox(
                width: 18.r,
                height: 18.r,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: HaseenColors.navy,
                ),
              )
            : const Text(
                '+ إضافة موظف',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
      ),
    ],
  );
}
