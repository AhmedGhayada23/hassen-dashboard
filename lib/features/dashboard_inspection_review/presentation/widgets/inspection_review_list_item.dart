import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../domain/entities/inspection.dart';
import 'inspection_status_pill.dart';

/// One report in the review queue; the selected one gets a tint and a gold bar.
class InspectionReviewListItem extends StatelessWidget {
  final Inspection inspection;
  final bool isSelected;
  final VoidCallback onTap;

  const InspectionReviewListItem({
    super.key,
    required this.inspection,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: isSelected ? HaseenColors.selectedRow : Colors.white,
    child: InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          border: BorderDirectional(
            bottom: const BorderSide(color: HaseenColors.soft),
            start: BorderSide(
              color: isSelected ? HaseenColors.gold : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    inspection.facility,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: HaseenColors.navy,
                    ),
                  ),
                ),
                InspectionStatusPill(decision: inspection.decision),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              '${inspection.id} · ${inspection.inspector} · ${inspection.date.isoDate}',
              style: TextStyle(fontSize: 12.sp, color: HaseenColors.muted),
            ),
          ],
        ),
      ),
    ),
  );
}
