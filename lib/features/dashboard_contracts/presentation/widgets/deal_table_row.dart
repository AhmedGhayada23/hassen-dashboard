import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/contract_plan.dart';
import '../../domain/entities/deal.dart';
import '../config/deal_status_style.dart';
import '../config/deals_table_config.dart';
import 'deal_decision_buttons.dart';
import 'deal_plan_cell.dart';

/// One client's deal: number, client, date, status, the contract length
/// (accepted only) and the decisions it can still take.
class DealTableRow extends StatelessWidget {
  final Deal deal;
  final List<ContractPlan> plans;
  final bool isSaving;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final ValueChanged<ContractPlan> onSelectPlan;

  const DealTableRow({
    super.key,
    required this.deal,
    required this.plans,
    required this.onAccept,
    required this.onReject,
    required this.onSelectPlan,
    this.isSaving = false,
  });

  @override
  Widget build(BuildContext context) {
    final flex = DealsTableConfig.columnFlex;
    final status = deal.status.style;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: HaseenColors.soft)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: flex[0],
            child: Text(
              deal.number,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: HaseenColors.navy,
              ),
            ),
          ),
          Expanded(
            flex: flex[1],
            child: Text(deal.client, style: TextStyle(fontSize: 13.sp)),
          ),
          Expanded(
            flex: flex[2],
            child: Text(
              deal.date,
              style: TextStyle(fontSize: 13.sp, color: HaseenColors.muted),
            ),
          ),
          Expanded(
            flex: flex[3],
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: StatusBadge(
                status.label,
                status.background,
                status.foreground,
              ),
            ),
          ),
          Expanded(
            flex: flex[4],
            child: deal.isAccepted
                ? DealPlanCell(
                    deal: deal,
                    plans: plans,
                    onSelect: isSaving ? null : onSelectPlan,
                  )
                : const Text(
                    '—',
                    style: TextStyle(color: HaseenColors.fieldHint),
                  ),
          ),
          Expanded(
            flex: flex[5],
            child: DealDecisionButtons(
              deal: deal,
              isSaving: isSaving,
              onAccept: onAccept,
              onReject: onReject,
            ),
          ),
        ],
      ),
    );
  }
}
