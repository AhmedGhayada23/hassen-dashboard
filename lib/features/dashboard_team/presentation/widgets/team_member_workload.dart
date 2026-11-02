import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/team_member.dart';

/// "عبء العمل" caption with the percentage at the far end.
class TeamMemberWorkload extends StatelessWidget {
  final TeamMember member;

  const TeamMemberWorkload({super.key, required this.member});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        'عبء العمل',
        style: TextStyle(fontSize: 12.sp, color: HaseenColors.muted),
      ),
      const Spacer(),
      Text(
        '${member.workload}%',
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w700,
          color: HaseenColors.navy,
        ),
      ),
    ],
  );
}
