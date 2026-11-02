import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../../../core/widgets/status_badge.dart';
import '../../../domain/entities/visit.dart';
import '../overview_empty_note.dart';

class TodayVisitsCard extends StatelessWidget {
  final List<Visit> visits;

  const TodayVisitsCard({super.key, required this.visits});

  @override
  Widget build(BuildContext context) => AppCard(
    padding: EdgeInsets.all(18.r),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('زيارات اليوم', style: AppTextStyles.cardTitle),
        SizedBox(height: 12.h),
        if (visits.isEmpty) const OverviewEmptyNote('لا توجد زيارات اليوم.'),
        for (final visit in visits) VisitRow(visit: visit),
      ],
    ),
  );
}

class VisitRow extends StatelessWidget {
  final Visit visit;

  const VisitRow({super.key, required this.visit});

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: 8.h),
    child: Row(
      children: [
        SizedBox(
          width: 44.w,
          child: Text(
            visit.time,
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
          ),
        ),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(text: visit.facility),
                TextSpan(
                  text: ' · ${visit.inspector}',
                  style: const TextStyle(color: HaseenColors.muted),
                ),
              ],
            ),
            style: TextStyle(fontSize: 13.sp),
          ),
        ),
        VisitStatusBadge(status: visit.status),
      ],
    ),
  );
}

class VisitStatusBadge extends StatelessWidget {
  final VisitStatus status;

  const VisitStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) => switch (status) {
    VisitStatus.done => const StatusBadge(
      'منجزة',
      HaseenColors.successSoft,
      HaseenColors.successText,
    ),
    VisitStatus.inProgress => const StatusBadge(
      'جارية',
      HaseenColors.warningSoft,
      HaseenColors.warningTextDark,
    ),
    VisitStatus.planned => const StatusBadge(
      'مجدولة',
      HaseenColors.bg,
      HaseenColors.neutralText,
    ),
  };
}
