import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../shared/dashboard_shell/presentation/config/dashboard_layout_config.dart';
import '../../domain/entities/team_member.dart';
import 'team_grid.dart';
import 'team_page_header.dart';

/// Shimmering stand-in for the team page while `users` loads: the real
/// header and cards, drawn as bones. The members below only give the bones
/// their shape; none of their text is ever readable.
class TeamSkeleton extends StatelessWidget {
  static const placeholderCount = 4;

  static final _placeholders = [
    for (var i = 0; i < placeholderCount; i++)
      TeamMember(
        id: 'skeleton-$i',
        name: 'اسم الموظف الكامل',
        role: 'المسمى الوظيفي',
        facilities: 10,
        monthlyVisits: 10,
        lateVisits: 0,
        workload: 50,
      ),
  ];

  const TeamSkeleton({super.key});

  @override
  Widget build(BuildContext context) => Skeletonizer(
    child: SingleChildScrollView(
      padding: DashboardLayoutConfig.contentPadding,
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TeamPageHeader(memberCount: placeholderCount, onAddEmployee: () {}),
          SizedBox(height: DashboardLayoutConfig.sectionGap),
          TeamGrid(members: _placeholders),
        ],
      ),
    ),
  );
}
