import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/team_member.dart';
import '../config/team_workload_style.dart';

/// Thin workload bar, orange when the member is overloaded.
class TeamWorkloadIndicator extends StatelessWidget {
  final TeamMember member;

  const TeamWorkloadIndicator({super.key, required this.member});

  @override
  Widget build(BuildContext context) => Skeleton.leaf(
    // A single bone while loading, rather than a coloured bar.
    child: ClipRRect(
      borderRadius: BorderRadius.circular(3.r),
      child: LinearProgressIndicator(
        value: member.workload / 100,
        minHeight: 6.h,
        backgroundColor: HaseenColors.soft,
        color: member.workloadColor,
      ),
    ),
  );
}
