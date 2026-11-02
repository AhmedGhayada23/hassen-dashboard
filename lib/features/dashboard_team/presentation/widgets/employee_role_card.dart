import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/employee_role.dart';

/// Selectable role tile: name over a one-line description; navy when chosen.
class EmployeeRoleCard extends StatelessWidget {
  final EmployeeRole role;
  final bool selected;
  final VoidCallback onTap;

  const EmployeeRoleCard({
    super.key,
    required this.role,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? HaseenColors.navy : Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.r),
      side: BorderSide(
        color: selected ? HaseenColors.navy : HaseenColors.fieldBorder,
        width: 1.5,
      ),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(10.r),
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              role.name,
              style: TextStyle(
                fontSize: 13.5.sp,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : HaseenColors.navy,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              role.description,
              style: TextStyle(
                fontSize: 11.5.sp,
                color: selected ? HaseenColors.mutedOnNavy : HaseenColors.muted,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
