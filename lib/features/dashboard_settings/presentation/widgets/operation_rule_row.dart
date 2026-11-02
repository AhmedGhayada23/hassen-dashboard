import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/operation_rule.dart';

/// A rule: its title, then its value aligned to the far edge.
class OperationRuleRow extends StatelessWidget {
  final OperationRule rule;

  const OperationRuleRow({super.key, required this.rule});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(vertical: 9.h),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: HaseenColors.soft)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            rule.title,
            style: TextStyle(fontSize: 13.sp, color: HaseenColors.navy),
          ),
        ),
        SizedBox(width: 10.w),
        Flexible(
          child: Text(
            rule.value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: HaseenColors.navy,
            ),
          ),
        ),
      ],
    ),
  );
}
