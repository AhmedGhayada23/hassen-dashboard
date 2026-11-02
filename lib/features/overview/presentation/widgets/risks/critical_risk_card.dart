import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../domain/entities/critical_risk.dart';
import '../overview_empty_note.dart';

class CriticalRiskCard extends StatelessWidget {
  final List<CriticalRisk> risks;

  const CriticalRiskCard({super.key, required this.risks});

  @override
  Widget build(BuildContext context) => AppCard(
    padding: EdgeInsets.all(18.r),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('مخاطر حرجة مفتوحة', style: AppTextStyles.cardTitle),
        SizedBox(height: 12.h),
        if (risks.isEmpty)
          const OverviewEmptyNote('لا توجد مخاطر حرجة مفتوحة.'),
        for (var i = 0; i < risks.length; i++) ...[
          if (i > 0) SizedBox(height: 8.h),
          CriticalRiskTile(risk: risks[i]),
        ],
      ],
    ),
  );
}

class CriticalRiskTile extends StatelessWidget {
  final CriticalRisk risk;

  const CriticalRiskTile({super.key, required this.risk});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
    decoration: BoxDecoration(
      color: HaseenColors.dangerTint,
      border: const Border.fromBorderSide(
        BorderSide(color: HaseenColors.dangerBorder),
      ),
      borderRadius: BorderRadius.circular(10.r),
    ),
    child: Row(
      children: [
        Container(
          width: 34.w,
          height: 30.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: HaseenColors.redStrong,
            borderRadius: BorderRadius.circular(6.r),
          ),
          child: Text(
            '${risk.score}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                risk.title,
                style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
              ),
              Text(
                '${risk.facility} · ${risk.owner}',
                style: TextStyle(fontSize: 12.sp, color: HaseenColors.muted),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
