import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/finding.dart';
import 'inspection_finding_card.dart';

/// "البنود غير المطابقة" heading followed by one card per finding.
class InspectionFindingsSection extends StatelessWidget {
  final List<Finding> findings;

  const InspectionFindingsSection({super.key, required this.findings});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        'البنود غير المطابقة',
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          color: HaseenColors.navy,
        ),
      ),
      SizedBox(height: 10.h),
      for (final finding in findings) InspectionFindingCard(finding: finding),
    ],
  );
}
