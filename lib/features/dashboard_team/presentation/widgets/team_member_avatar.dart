import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/team_member.dart';

/// Member initial on a light-blue rounded square.
class TeamMemberAvatar extends StatelessWidget {
  final TeamMember member;

  const TeamMemberAvatar({super.key, required this.member});

  @override
  Widget build(BuildContext context) => Container(
    width: 40.r,
    height: 40.r,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: HaseenColors.infoSoft,
      borderRadius: BorderRadius.circular(10.r),
    ),
    child: Text(
      member.initial,
      style: TextStyle(
        color: HaseenColors.infoText,
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
