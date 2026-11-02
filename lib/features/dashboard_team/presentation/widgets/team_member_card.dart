import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/team_member.dart';
import 'team_member_avatar.dart';
import 'team_member_identity.dart';
import 'team_member_password.dart';
import 'team_member_stats.dart';
import 'team_member_workload.dart';
import 'team_workload_indicator.dart';

/// One member: identity (tagged while awaiting activation), three stats,
/// workload, then — for accounts created here — the temporary password.
class TeamMemberCard extends StatelessWidget {
  final TeamMember member;
  final bool passwordRevealed;
  final VoidCallback? onTogglePassword;
  final VoidCallback? onCopyPassword;

  const TeamMemberCard({
    super.key,
    required this.member,
    this.passwordRevealed = false,
    this.onTogglePassword,
    this.onCopyPassword,
  });

  @override
  Widget build(BuildContext context) => AppCard(
    padding: EdgeInsets.all(16.r),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            TeamMemberAvatar(member: member),
            SizedBox(width: 10.w),
            Expanded(child: TeamMemberIdentity(member: member)),
            if (member.isPendingActivation)
              const StatusBadge(
                'بانتظار التفعيل',
                HaseenColors.warningSoft,
                HaseenColors.warningTextDark,
              ),
          ],
        ),
        SizedBox(height: 12.h),
        TeamMemberStats(member: member),
        SizedBox(height: 12.h),
        TeamMemberWorkload(member: member),
        SizedBox(height: 4.h),
        TeamWorkloadIndicator(member: member),
        if (member.temporaryPassword case final password?) ...[
          SizedBox(height: 12.h),
          TeamMemberPassword(
            password: password,
            revealed: passwordRevealed,
            onToggleVisibility: onTogglePassword ?? () {},
            onCopy: onCopyPassword ?? () {},
          ),
        ],
      ],
    ),
  );
}
