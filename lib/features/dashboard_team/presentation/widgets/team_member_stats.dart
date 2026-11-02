import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/team_member.dart';
import '../config/team_workload_style.dart';
import 'team_member_stat_item.dart';

/// Facilities, monthly visits and late visits in three equal tiles.
class TeamMemberStats extends StatelessWidget {
  final TeamMember member;

  const TeamMemberStats({super.key, required this.member});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('${member.facilities}', 'منشآت', HaseenColors.navy),
      ('${member.monthlyVisits}', 'زيارات الشهر', HaseenColors.navy),
      ('${member.lateVisits}', 'متأخرة', member.lateVisitsColor),
    ];
    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) SizedBox(width: 6.w),
          Expanded(
            child: TeamMemberStatItem(
              value: items[i].$1,
              label: items[i].$2,
              valueColor: items[i].$3,
            ),
          ),
        ],
      ],
    );
  }
}
