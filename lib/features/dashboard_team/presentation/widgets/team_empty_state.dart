import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';

/// Shown in place of the cards while `users` holds no employees.
class TeamEmptyState extends StatelessWidget {
  const TeamEmptyState({super.key});

  @override
  Widget build(BuildContext context) => AppCard(
    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 36.h),
    child: Column(
      children: [
        Icon(Icons.group_outlined, size: 36.sp, color: HaseenColors.hint),
        SizedBox(height: 10.h),
        Text(
          'لا يوجد موظفون بعد',
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: HaseenColors.navy,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'أضف أول موظف من «+ إضافة موظف» ليظهر هنا.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13.sp, color: HaseenColors.muted),
        ),
      ],
    ),
  );
}
