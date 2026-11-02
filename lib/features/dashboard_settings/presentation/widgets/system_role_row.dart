import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/system_role.dart';
import '../config/settings_texts.dart';
import 'settings_list_card.dart';

/// A role: its name, how many users hold it, and who they work for.
class SystemRoleRow extends StatelessWidget {
  final SystemRole role;

  const SystemRoleRow({super.key, required this.role});

  @override
  Widget build(BuildContext context) {
    final (label, background, foreground) = role.organization.pill;
    return SettingsListRow(
      children: [
        Expanded(child: SettingsRowName(role.name)),
        Text(
          SettingsTexts.users(role.usersCount),
          style: TextStyle(fontSize: 13.sp, color: HaseenColors.muted),
        ),
        SizedBox(width: 10.w),
        StatusBadge(label, background, foreground),
      ],
    );
  }
}
