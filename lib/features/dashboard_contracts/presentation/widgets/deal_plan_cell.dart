import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/contract_plan.dart';
import '../../domain/entities/deal.dart';
import '../config/contracts_messages.dart';

/// The contract-length picker of an accepted deal, with the period it covers
/// once a length is picked.
class DealPlanCell extends StatelessWidget {
  static const hint = 'اختر المدة';

  final Deal deal;
  final List<ContractPlan> plans;

  /// Null disables the picker, e.g. while the deal is being saved.
  final ValueChanged<ContractPlan>? onSelect;

  const DealPlanCell({
    super.key,
    required this.deal,
    required this.plans,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final plan = plans.where((p) => p.id == deal.planId).firstOrNull;
    final start = deal.startDate;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(7.r),
      borderSide: const BorderSide(color: HaseenColors.fieldBorder, width: 1.5),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 220.w),
          child: DropdownButtonFormField<ContractPlan>(
            // Rebuilt when the saved length changes.
            key: ValueKey(plan),
            initialValue: plan,
            hint: Text(hint, style: TextStyle(fontSize: 13.sp)),
            isDense: true,
            isExpanded: true,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 10.w,
                vertical: 8.h,
              ),
              enabledBorder: border,
              disabledBorder: border,
              focusedBorder: border.copyWith(
                borderSide: const BorderSide(
                  color: HaseenColors.navy,
                  width: 1.5,
                ),
              ),
            ),
            items: [
              for (final p in plans)
                DropdownMenuItem(
                  value: p,
                  child: Text(p.name, style: TextStyle(fontSize: 13.sp)),
                ),
            ],
            onChanged: switch (onSelect) {
              final select? => (p) {
                if (p != null && p != plan) select(p);
              },
              null => null,
            },
          ),
        ),
        if (plan != null && start != null)
          Padding(
            padding: EdgeInsets.only(top: 3.h),
            child: Text(
              '${formatDealDate(start)} ← ${formatDealDate(plan.endFor(start))}',
              style: TextStyle(fontSize: 11.5.sp, color: HaseenColors.muted),
            ),
          ),
      ],
    );
  }
}
