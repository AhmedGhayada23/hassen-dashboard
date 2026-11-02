import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// Week title between previous/next arrows, a way back to the current week
/// when another is shown, and the "schedule a visit" action.
class VisitsPageHeader extends StatelessWidget {
  static const previousWeekTooltip = 'الأسبوع السابق';
  static const nextWeekTooltip = 'الأسبوع التالي';
  static const currentWeekLabel = 'الأسبوع الحالي';

  final String weekLabel;
  final VoidCallback onScheduleVisit;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;

  /// Null while the current week is shown, which hides its button.
  final VoidCallback? onCurrentWeek;

  const VisitsPageHeader({
    super.key,
    required this.weekLabel,
    required this.onScheduleVisit,
    required this.onPreviousWeek,
    required this.onNextWeek,
    this.onCurrentWeek,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      // chevron_left/right follow the text direction: in RTL "previous"
      // points right, toward the start of the line.
      _WeekArrow(
        icon: Icons.chevron_left,
        tooltip: previousWeekTooltip,
        onPressed: onPreviousWeek,
      ),
      SizedBox(width: 8.w),
      Text(weekLabel, style: AppTextStyles.cardTitle),
      SizedBox(width: 8.w),
      _WeekArrow(
        icon: Icons.chevron_right,
        tooltip: nextWeekTooltip,
        onPressed: onNextWeek,
      ),
      if (onCurrentWeek case final onPressed?) ...[
        SizedBox(width: 12.w),
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            foregroundColor: HaseenColors.teal,
            minimumSize: Size(0, 32.h),
            padding: EdgeInsets.symmetric(horizontal: 10.w),
          ),
          child: const Text(
            currentWeekLabel,
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
      const Spacer(),
      FilledButton(
        onPressed: onScheduleVisit,
        style: FilledButton.styleFrom(
          backgroundColor: HaseenColors.gold,
          foregroundColor: HaseenColors.navy,
          minimumSize: Size(0, 38.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        child: const Text(
          '+ جدولة زيارة',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    ],
  );
}

class _WeekArrow extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _WeekArrow({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => IconButton(
    onPressed: onPressed,
    tooltip: tooltip,
    icon: Icon(icon, size: 20.r),
    color: HaseenColors.navy,
    style: IconButton.styleFrom(
      minimumSize: Size(32.r, 32.r),
      fixedSize: Size(32.r, 32.r),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
        side: const BorderSide(color: HaseenColors.line),
      ),
      backgroundColor: Colors.white,
    ),
  );
}
