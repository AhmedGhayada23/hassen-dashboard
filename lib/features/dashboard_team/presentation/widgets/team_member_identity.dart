import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/team_member.dart';

/// Member name over their role.
class TeamMemberIdentity extends StatelessWidget {
  final TeamMember member;

  const TeamMemberIdentity({super.key, required this.member});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        member.name,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          color: HaseenColors.navy,
        ),
      ),
      Text(
        member.role,
        style: TextStyle(fontSize: 12.sp, color: HaseenColors.muted),
      ),
    ],
  );
}
