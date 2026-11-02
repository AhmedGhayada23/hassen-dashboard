import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/risk.dart';

/// Selected risk: hazard, "facility · likelihood × severity = score", control.
class RiskDetailsSummary extends StatelessWidget {
  final Risk risk;

  const RiskDetailsSummary({super.key, required this.risk});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        risk.hazard,
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          color: HaseenColors.navy,
        ),
      ),
      SizedBox(height: 2.h),
      Text(
        '${risk.facility} · الاحتمال ${risk.likelihood} × الشدة ${risk.severity} = ${risk.score}',
        style: TextStyle(fontSize: 12.5.sp, color: HaseenColors.muted),
      ),
      SizedBox(height: 6.h),
      Text(
        risk.control,
        style: TextStyle(fontSize: 12.5.sp, color: HaseenColors.neutralText),
      ),
    ],
  );
}
