import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/risk.dart';
import '../config/risk_level_style.dart';

/// Score chip filled with the risk level's color.
class RiskScoreBadge extends StatelessWidget {
  final Risk risk;

  const RiskScoreBadge({super.key, required this.risk});

  @override
  Widget build(BuildContext context) {
    final style = risk.level.style;
    return Container(
      constraints: BoxConstraints(minWidth: 34.w),
      height: 26.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: style.filled,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        '${risk.score}',
        style: TextStyle(
          color: style.onFilled,
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
