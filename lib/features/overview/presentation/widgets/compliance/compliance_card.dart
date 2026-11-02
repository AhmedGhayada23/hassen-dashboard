import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../domain/entities/compliance_record.dart';
import '../overview_empty_note.dart';

/// Compliance percentage per facility with a colored progress bar.
class ComplianceCard extends StatelessWidget {
  final List<ComplianceRecord> records;

  const ComplianceCard({super.key, required this.records});

  @override
  Widget build(BuildContext context) => AppCard(
    padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 16.h),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('نسبة المطابقة حسب المنشأة', style: AppTextStyles.cardTitle),
        SizedBox(height: 12.h),
        if (records.isEmpty) const OverviewEmptyNote('لا توجد نسب مطابقة بعد.'),
        for (final record in records) ComplianceBar(record: record),
      ],
    ),
  );
}

class ComplianceBar extends StatelessWidget {
  final ComplianceRecord record;

  const ComplianceBar({super.key, required this.record});

  static Color colorFor(ComplianceLevel level) => switch (level) {
    ComplianceLevel.excellent => HaseenColors.green,
    ComplianceLevel.good => HaseenColors.teal,
    ComplianceLevel.needsImprovement => HaseenColors.gold,
  };

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          Expanded(
            child: Text(record.facility, style: TextStyle(fontSize: 12.5.sp)),
          ),
          Text(
            '${record.percentage}%',
            style: TextStyle(fontSize: 12.5.sp, fontWeight: FontWeight.w700),
          ),
        ],
      ),
      SizedBox(height: 5.h),
      ClipRRect(
        borderRadius: BorderRadius.circular(4.r),
        child: LinearProgressIndicator(
          value: record.percentage / 100,
          minHeight: 8.h,
          backgroundColor: HaseenColors.soft,
          color: colorFor(record.level),
        ),
      ),
      SizedBox(height: 12.h),
    ],
  );
}
