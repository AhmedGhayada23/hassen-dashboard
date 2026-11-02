import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/app_icons.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/app_svg_icon.dart';

/// Bell button with a red dot when there are unread notifications.
class NotificationsButton extends StatelessWidget {
  final bool hasUnread;
  final VoidCallback onPressed;

  const NotificationsButton({
    super.key,
    required this.hasUnread,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => Badge(
    isLabelVisible: hasUnread,
    smallSize: 8.r,
    backgroundColor: HaseenColors.redStrong,
    child: OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: Size(38.r, 38.r),
        padding: EdgeInsets.zero,
        side: const BorderSide(color: HaseenColors.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
      child: AppSvgIcon(AppIcons.bell, size: 18.sp, color: HaseenColors.navy),
    ),
  );
}
