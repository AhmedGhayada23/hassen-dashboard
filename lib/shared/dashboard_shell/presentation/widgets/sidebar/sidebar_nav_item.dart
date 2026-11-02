import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/app_svg_icon.dart';
import '../../../domain/entities/nav_item.dart';
import '../../config/dashboard_navigation_config.dart';

class SidebarNavItem extends StatelessWidget {
  final NavItem item;
  final bool isActive;
  final VoidCallback onTap;

  const SidebarNavItem({
    super.key,
    required this.item,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? HaseenColors.gold : HaseenColors.sideText;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          margin: EdgeInsets.only(bottom: 2.h),
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),
          decoration: BoxDecoration(
            color: isActive ? HaseenColors.sideActiveBg : Colors.transparent,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              AppSvgIcon(item.destination.iconAsset, size: 18.sp, color: color),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  item.label,
                  style: TextStyle(
                    color: color,
                    fontSize: 13.5.sp,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
              if (item.hasBadge)
                SidebarNavBadge(count: item.badgeCount, isAlert: item.isAlert),
            ],
          ),
        ),
      ),
    );
  }
}

/// Counter pill: gold for pending work, red for overdue/alerts.
class SidebarNavBadge extends StatelessWidget {
  final int count;
  final bool isAlert;

  const SidebarNavBadge({
    super.key,
    required this.count,
    required this.isAlert,
  });

  @override
  Widget build(BuildContext context) => Container(
    constraints: BoxConstraints(minWidth: 20.r),
    height: 20.r,
    padding: EdgeInsets.symmetric(horizontal: 6.w),
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: isAlert ? HaseenColors.redStrong : HaseenColors.gold,
      borderRadius: BorderRadius.circular(10.r),
    ),
    child: Text(
      '$count',
      style: TextStyle(
        color: isAlert ? Colors.white : HaseenColors.navy,
        fontSize: 11.sp,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
