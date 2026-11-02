import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/risk.dart';
import '../config/risk_status_style.dart';
import '../config/risks_layout_config.dart';
import 'risk_score_badge.dart';

/// One register line; the selected one is tinted.
class RiskTableRow extends StatelessWidget {
  final Risk risk;
  final bool isSelected;
  final VoidCallback onTap;

  const RiskTableRow({
    super.key,
    required this.risk,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final flex = RisksLayoutConfig.columnFlex;
    final cell = TextStyle(fontSize: 13.sp);
    final muted = cell.copyWith(color: HaseenColors.muted);
    return Material(
      color: isSelected ? HaseenColors.selectedRow : Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 11.h),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: HaseenColors.soft)),
          ),
          child: Row(
            children: [
              Expanded(
                flex: flex[0],
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: RiskScoreBadge(risk: risk),
                ),
              ),
              Expanded(
                flex: flex[1],
                child: Text(
                  risk.hazard,
                  style: cell.copyWith(
                    fontWeight: FontWeight.w700,
                    color: HaseenColors.navy,
                  ),
                ),
              ),
              Expanded(
                flex: flex[2],
                child: Text(risk.facility, style: muted),
              ),
              Expanded(
                flex: flex[3],
                child: Text(risk.owner, style: muted),
              ),
              Expanded(
                flex: flex[4],
                child: Text(risk.status.label, style: cell),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
