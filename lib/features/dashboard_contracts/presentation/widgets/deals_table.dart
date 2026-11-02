import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/contract_plan.dart';
import '../../domain/entities/deal.dart';
import '../config/deals_table_config.dart';
import 'deal_table_row.dart';

/// Every client's deal: decide on it (or change the decision), and pick the
/// contract length of the accepted ones.
class DealsTable extends StatelessWidget {
  final List<Deal> deals;
  final List<ContractPlan> plans;
  final Set<String> savingIds;
  final ValueChanged<Deal> onAccept;
  final ValueChanged<Deal> onReject;
  final void Function(Deal deal, ContractPlan plan) onSelectPlan;

  /// Shown in place of the rows when there are no deals.
  final String emptyMessage;

  const DealsTable({
    super.key,
    required this.deals,
    required this.plans,
    required this.onAccept,
    required this.onReject,
    required this.onSelectPlan,
    this.savingIds = const {},
    this.emptyMessage = '',
  });

  @override
  Widget build(BuildContext context) => AppCard(
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: HaseenColors.tableHeader,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 11.h),
          child: Row(
            children: [
              for (final (i, label) in DealsTableConfig.headers.indexed)
                Expanded(
                  flex: DealsTableConfig.columnFlex[i],
                  child: Text(label, style: AppTextStyles.tableHeader),
                ),
            ],
          ),
        ),
        if (deals.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 28.h),
            child: Text(
              emptyMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, color: HaseenColors.muted),
            ),
          ),
        for (final deal in deals)
          DealTableRow(
            deal: deal,
            plans: plans,
            isSaving: savingIds.contains(deal.id),
            onAccept: () => onAccept(deal),
            onReject: () => onReject(deal),
            onSelectPlan: (plan) => onSelectPlan(deal, plan),
          ),
      ],
    ),
  );
}
