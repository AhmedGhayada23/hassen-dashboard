import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/status_badge.dart';
import '../../../domain/entities/inspection_review.dart';

/// Column flex shared by the header and data rows so they stay aligned.
const _columnFlex = [2, 3, 2, 2, 2];

class InspectionReviewHeaderRow extends StatelessWidget {
  const InspectionReviewHeaderRow({super.key});

  static const _labels = ['رقم', 'المنشأة', 'المفتش', 'غير مطابق', 'الحالة'];

  @override
  Widget build(BuildContext context) => Container(
    color: HaseenColors.tableHeader,
    padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
    child: Row(
      children: [
        for (var i = 0; i < _labels.length; i++)
          Expanded(
            flex: _columnFlex[i],
            child: Text(_labels[i], style: AppTextStyles.tableHeader),
          ),
      ],
    ),
  );
}

class InspectionReviewRow extends StatelessWidget {
  final InspectionReview review;

  const InspectionReviewRow({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final cell = TextStyle(fontSize: 13.sp);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 11.h),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: HaseenColors.soft)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: _columnFlex[0],
            child: Text(
              review.id,
              style: cell.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            flex: _columnFlex[1],
            child: Text(review.facility, style: cell),
          ),
          Expanded(
            flex: _columnFlex[2],
            child: Text(
              review.inspector,
              style: cell.copyWith(color: HaseenColors.muted),
            ),
          ),
          Expanded(
            flex: _columnFlex[3],
            child: Row(
              children: [
                Text(
                  '${review.nonConformities}',
                  style: cell.copyWith(
                    fontWeight: FontWeight.w700,
                    color: review.hasHighNonConformities
                        ? HaseenColors.red
                        : HaseenColors.navy,
                  ),
                ),
                if (review.isCritical) ...[
                  SizedBox(width: 6.w),
                  const StatusBadge(
                    'حرج',
                    HaseenColors.criticalSoft,
                    HaseenColors.red,
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            flex: _columnFlex[4],
            child: const Align(
              alignment: AlignmentDirectional.centerStart,
              child: StatusBadge(
                'بانتظار',
                HaseenColors.warningSoft,
                HaseenColors.warningTextDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
