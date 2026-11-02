import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/inspection.dart';
import 'inspection_review_list_item.dart';

/// The review queue card ("قائمة المراجعة").
class InspectionReviewList extends StatelessWidget {
  final List<Inspection> inspections;
  final int selectedIndex;
  final ValueChanged<int> onSelect;

  const InspectionReviewList({
    super.key,
    required this.inspections,
    required this.selectedIndex,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) => AppCard(
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: HaseenColors.line)),
          ),
          child: Text(
            'قائمة المراجعة',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: HaseenColors.navy,
            ),
          ),
        ),
        for (var i = 0; i < inspections.length; i++)
          InspectionReviewListItem(
            inspection: inspections[i],
            isSelected: i == selectedIndex,
            onTap: () => onSelect(i),
          ),
      ],
    ),
  );
}
