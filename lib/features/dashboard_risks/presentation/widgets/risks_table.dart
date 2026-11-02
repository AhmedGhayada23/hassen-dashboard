import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/risk.dart';
import 'risk_table_header.dart';
import 'risk_table_row.dart';

class RisksTable extends StatelessWidget {
  final List<Risk> risks;
  final String? selectedRiskId;
  final ValueChanged<Risk> onRiskTap;

  /// Shown in place of the rows when the register is empty.
  final String emptyMessage;

  const RisksTable({
    super.key,
    required this.risks,
    required this.selectedRiskId,
    required this.onRiskTap,
    this.emptyMessage = '',
  });

  @override
  Widget build(BuildContext context) => AppCard(
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const RiskTableHeader(),
        if (risks.isEmpty)
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 28.h),
            child: Text(
              emptyMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, color: HaseenColors.muted),
            ),
          ),
        for (final risk in risks)
          RiskTableRow(
            risk: risk,
            isSelected: risk.id == selectedRiskId,
            onTap: () => onRiskTap(risk),
          ),
      ],
    ),
  );
}
