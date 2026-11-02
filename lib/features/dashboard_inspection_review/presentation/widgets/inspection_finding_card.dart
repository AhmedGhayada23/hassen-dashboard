import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_svg_icon.dart';
import '../../domain/entities/finding.dart';
import 'finding_severity_badge.dart';

/// One non-conformity: photo placeholder, title + severity, note and deadline.
class InspectionFindingCard extends StatelessWidget {
  final Finding finding;

  const InspectionFindingCard({super.key, required this.finding});

  @override
  Widget build(BuildContext context) => Container(
    margin: EdgeInsets.only(bottom: 8.h),
    padding: EdgeInsets.all(12.r),
    decoration: BoxDecoration(
      border: const Border.fromBorderSide(BorderSide(color: HaseenColors.line)),
      borderRadius: BorderRadius.circular(10.r),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 52.r,
          height: 52.r,
          decoration: BoxDecoration(
            color: HaseenColors.soft,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: AppSvgIcon(
            AppIcons.camera,
            size: 24.sp,
            color: HaseenColors.neutralBar,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8.w,
                runSpacing: 4.h,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    finding.title,
                    style: TextStyle(
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w700,
                      color: HaseenColors.navy,
                    ),
                  ),
                  FindingSeverityBadge(severity: finding.severity),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                finding.note,
                style: TextStyle(
                  fontSize: 12.5.sp,
                  color: HaseenColors.neutralText,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          'المهلة: ${finding.due}',
          style: TextStyle(fontSize: 12.sp, color: HaseenColors.muted),
        ),
      ],
    ),
  );
}
