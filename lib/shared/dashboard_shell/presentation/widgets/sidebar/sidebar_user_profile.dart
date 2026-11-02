import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../config/dashboard_navigation_config.dart';

/// Signed-in user card pinned to the bottom of the sidebar.
class SidebarUserProfile extends StatelessWidget {
  final SidebarProfile profile;

  const SidebarUserProfile({super.key, required this.profile});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
    decoration: const BoxDecoration(
      border: Border(top: BorderSide(color: HaseenColors.sideDivider)),
    ),
    child: Row(
      children: [
        Container(
          width: 34.r,
          height: 34.r,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: HaseenColors.gold,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            profile.name.characters.first,
            style: TextStyle(
              color: HaseenColors.navy,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              profile.name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              profile.organization,
              style: TextStyle(
                color: HaseenColors.sideGroupTitle,
                fontSize: 11.sp,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
