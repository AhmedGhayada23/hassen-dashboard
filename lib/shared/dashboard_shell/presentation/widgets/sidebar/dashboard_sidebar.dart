import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../domain/entities/nav_group.dart';
import '../../config/dashboard_navigation_config.dart';
import 'sidebar_logo.dart';
import 'sidebar_navigation.dart';
import 'sidebar_user_profile.dart';

class DashboardSidebar extends StatelessWidget {
  final List<NavGroup> groups;
  final SidebarProfile profile;

  const DashboardSidebar({
    super.key,
    required this.groups,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240.w,
      color: HaseenColors.navy,
      child: Column(
        children: [
          const SidebarLogo(),
          Expanded(child: SidebarNavigation(groups: groups)),
          SidebarUserProfile(profile: profile),
        ],
      ),
    );
  }
}
