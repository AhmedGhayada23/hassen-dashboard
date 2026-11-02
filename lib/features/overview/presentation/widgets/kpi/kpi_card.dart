import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../domain/entities/dashboard_kpi.dart';

class KpiCard extends StatelessWidget {
  final DashboardKpi kpi;
  final VoidCallback onTap;

  const KpiCard({super.key, required this.kpi, required this.onTap});

  static Color colorFor(KpiTone tone) => switch (tone) {
    KpiTone.neutral => HaseenColors.navy,
    KpiTone.warning => HaseenColors.warningText,
    KpiTone.danger => HaseenColors.red,
  };

  @override
  Widget build(BuildContext context) => InkWell(
    borderRadius: BorderRadius.circular(12.r),
    onTap: onTap,
    child: AppCard(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            kpi.label,
            style: TextStyle(fontSize: 12.5.sp, color: HaseenColors.muted),
          ),
          SizedBox(height: 6.h),
          Text(
            '${kpi.value}',
            style: TextStyle(
              fontSize: 28.sp,
              height: 1.1,
              fontWeight: FontWeight.w700,
              color: colorFor(kpi.tone),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            kpi.subtitle,
            style: TextStyle(fontSize: 11.5.sp, color: HaseenColors.hint),
          ),
        ],
      ),
    ),
  );
}
