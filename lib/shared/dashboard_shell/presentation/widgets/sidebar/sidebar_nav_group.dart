import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/nav_destination.dart';
import '../../../domain/entities/nav_group.dart';
import 'sidebar_nav_item.dart';

class SidebarNavGroup extends StatelessWidget {
  final NavGroup group;
  final NavDestination active;
  final ValueChanged<NavDestination> onSelect;

  const SidebarNavGroup({
    super.key,
    required this.group,
    required this.active,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    // stretch keeps every child full-width, exactly as when they sat directly in the ListView.
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(10.w, 12.h, 10.w, 6.h),
          child: Text(
            group.title,
            style: TextStyle(
              color: HaseenColors.sideGroupTitle,
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        for (final item in group.items)
          SidebarNavItem(
            item: item,
            isActive: item.destination == active,
            onTap: () => onSelect(item.destination),
          ),
      ],
    );
  }
}
