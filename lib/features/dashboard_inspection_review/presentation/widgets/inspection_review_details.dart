import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/inspection.dart';
import 'inspection_decision_actions.dart';
import 'inspection_decision_status.dart';
import 'inspection_findings_section.dart';
import 'inspection_summary_stats.dart';

/// Details card: header with stats, findings, then the decision area.
class InspectionReviewDetails extends StatelessWidget {
  final Inspection inspection;
  final VoidCallback onApprove;
  final VoidCallback onReturn;
  final VoidCallback onUndo;

  const InspectionReviewDetails({
    super.key,
    required this.inspection,
    required this.onApprove,
    required this.onReturn,
    required this.onUndo,
  });

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: HaseenColors.line)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      inspection.facility,
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                        color: HaseenColors.navy,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '${inspection.id} · ${inspection.template} · ${inspection.inspector} · ${inspection.date.isoDate}',
                      style: TextStyle(
                        fontSize: 12.5.sp,
                        color: HaseenColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              InspectionSummaryStats(inspection: inspection),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.all(20.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InspectionFindingsSection(findings: inspection.findings),
              SizedBox(height: 8.h),
              const Divider(color: HaseenColors.soft, height: 1),
              SizedBox(height: 16.h),
              inspection.isPending
                  ? InspectionDecisionActions(
                      onApprove: onApprove,
                      onReturn: onReturn,
                    )
                  : InspectionDecisionStatus(
                      decision: inspection.decision,
                      onUndo: onUndo,
                    ),
            ],
          ),
        ),
      ],
    ),
  );
}
