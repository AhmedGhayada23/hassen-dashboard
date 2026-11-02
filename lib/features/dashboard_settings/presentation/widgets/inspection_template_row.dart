import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/inspection_template.dart';
import '../config/settings_texts.dart';
import 'settings_list_card.dart';

/// A template: its name, version badge, and item count.
class InspectionTemplateRow extends StatelessWidget {
  final InspectionTemplate template;

  const InspectionTemplateRow({super.key, required this.template});

  @override
  Widget build(BuildContext context) => SettingsListRow(
    children: [
      Expanded(child: SettingsRowName(template.name)),
      Container(
        padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: HaseenColors.soft,
          borderRadius: BorderRadius.circular(4.r),
        ),
        child: Text(
          template.version,
          textDirection: TextDirection.ltr,
          style: TextStyle(fontSize: 11.5.sp, color: HaseenColors.navy),
        ),
      ),
      SizedBox(width: 10.w),
      SizedBox(
        width: 70.w,
        child: Text(
          SettingsTexts.items(template.items),
          style: TextStyle(fontSize: 13.sp, color: HaseenColors.muted),
        ),
      ),
    ],
  );
}
