import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/inspection.dart';

/// Conforming / non-conforming counts and the compliance percentage.
class InspectionSummaryStats extends StatelessWidget {
  final Inspection inspection;

  const InspectionSummaryStats({super.key, required this.inspection});

  @override
  Widget build(BuildContext context) {
    final compliance = inspection.compliancePercent;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _Stat(
          value: '${inspection.passCount}',
          label: 'مطابق',
          color: HaseenColors.successText,
        ),
        SizedBox(width: 16.w),
        _Stat(
          value: '${inspection.failCount}',
          label: 'غير مطابق',
          color: HaseenColors.red,
        ),
        SizedBox(width: 16.w),
        _Stat(
          value: compliance == null ? '—' : '$compliance%',
          label: 'المطابقة',
          color: HaseenColors.navy,
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String value, label;
  final Color color;

  const _Stat({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: TextStyle(
          fontSize: 22.sp,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
      Text(
        label,
        style: TextStyle(fontSize: 11.5.sp, color: HaseenColors.muted),
      ),
    ],
  );
}
