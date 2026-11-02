import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';

/// One figure with its caption on a light tile.
class TeamMemberStatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color valueColor;

  const TeamMemberStatItem({
    super.key,
    required this.value,
    required this.label,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(vertical: 6.h),
    decoration: BoxDecoration(
      color: HaseenColors.bg,
      borderRadius: BorderRadius.circular(8.r),
    ),
    child: Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 11.sp, color: HaseenColors.muted),
        ),
      ],
    ),
  );
}
