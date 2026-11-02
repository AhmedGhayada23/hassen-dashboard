import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/asset_paths.dart';
import '../../../../../core/theme/app_colors.dart';

class SidebarLogo extends StatelessWidget {
  const SidebarLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(18.w, 20.h, 18.w, 18.h),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: HaseenColors.sideDivider)),
      ),
      child: Row(
        children: [
          Image.asset(
            AssetPaths.haseenLogo,
            width: 36.r,
            height: 36.r,
            // Source is 1067px; decode at display size instead.
            cacheWidth: (36.r * MediaQuery.devicePixelRatioOf(context)).round(),
            errorBuilder: (_, _, _) => SizedBox(width: 36.r),
          ),
          SizedBox(width: 10.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الحصين',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'HASEEN',
                style: TextStyle(
                  color: HaseenColors.gold,
                  fontSize: 11.sp,
                  letterSpacing: 3.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
