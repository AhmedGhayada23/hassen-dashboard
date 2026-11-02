import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/inspector.dart';
import '../config/visits_layout_config.dart';

/// Leading cell of a grid row: inspector name and their weekly visit count.
class VisitsInspectorCell extends StatelessWidget {
  final Inspector inspector;
  final int visitCount;

  const VisitsInspectorCell({
    super.key,
    required this.inspector,
    required this.visitCount,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: VisitsLayoutConfig.inspectorColumnWidth,
    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: HaseenColors.soft)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          inspector.name,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: HaseenColors.navy,
          ),
        ),
        Text(
          '$visitCount زيارات',
          style: TextStyle(fontSize: 11.sp, color: HaseenColors.muted),
        ),
      ],
    ),
  );
}
