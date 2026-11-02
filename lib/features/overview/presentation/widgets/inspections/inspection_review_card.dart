import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../domain/entities/inspection_review.dart';
import '../overview_empty_note.dart';
import 'inspection_review_row.dart';

/// Inspection results waiting for approval, as a compact table.
class InspectionReviewCard extends StatelessWidget {
  final List<InspectionReview> reviews;
  final VoidCallback onOpenReview;

  const InspectionReviewCard({
    super.key,
    required this.reviews,
    required this.onOpenReview,
  });

  @override
  Widget build(BuildContext context) => AppCard(
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(18.w, 10.h, 10.w, 10.h),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: HaseenColors.line)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  'نتائج تفتيش بانتظار الاعتماد',
                  style: AppTextStyles.cardTitle,
                ),
              ),
              TextButton(
                onPressed: onOpenReview,
                child: Text(
                  'فتح المراجعة ←',
                  style: TextStyle(
                    color: HaseenColors.teal,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ],
          ),
        ),
        const InspectionReviewHeaderRow(),
        if (reviews.isEmpty)
          const OverviewEmptyNote('لا توجد نتائج تفتيش بانتظار الاعتماد.'),
        for (final review in reviews) InspectionReviewRow(review: review),
      ],
    ),
  );
}
