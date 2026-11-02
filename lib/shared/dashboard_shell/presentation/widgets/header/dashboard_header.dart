import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/app_icons.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/app_svg_icon.dart';
import '../../../../../core/widgets/status_badge.dart';

/// 64px top bar: page title, demo-data badge, search field and optional actions.
class DashboardHeader extends StatelessWidget {
  final String title;
  final String searchHint;
  final ValueChanged<String>? onSearchChanged;
  final List<Widget> actions;

  const DashboardHeader({
    super.key,
    required this.title,
    required this.searchHint,
    this.onSearchChanged,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder searchBorder(Color color) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(8.r),
      borderSide: BorderSide(color: color),
    );
    return Container(
      height: 64.h,
      padding: EdgeInsets.symmetric(horizontal: 28.w),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: HaseenColors.line)),
      ),
      child: Row(
        children: [
          Text(title, style: AppTextStyles.pageTitle),
          SizedBox(width: 12.w),
          const StatusBadge(
            'بيانات تجريبية',
            HaseenColors.warningSoft,
            HaseenColors.warningText,
          ),
          const Spacer(),
          SizedBox(
            width: 280.w,
            height: 38.h,
            child: TextField(
              onChanged: onSearchChanged,
              decoration: InputDecoration(
                hintText: searchHint,
                hintStyle: TextStyle(fontSize: 13.sp, color: HaseenColors.hint),
                prefixIcon: AppSvgIcon(AppIcons.search, size: 18.sp),
                isDense: true,
                filled: true,
                fillColor: HaseenColors.bg,
                contentPadding: EdgeInsets.zero,
                border: searchBorder(HaseenColors.line),
                enabledBorder: searchBorder(HaseenColors.line),
                focusedBorder: searchBorder(HaseenColors.navy),
              ),
            ),
          ),
          for (final action in actions) ...[SizedBox(width: 12.w), action],
        ],
      ),
    );
  }
}
