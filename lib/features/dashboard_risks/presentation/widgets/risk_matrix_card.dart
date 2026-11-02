import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/risk.dart';
import '../../domain/entities/risk_matrix.dart';
import 'risk_details_summary.dart';
import 'risk_matrix_grid.dart';

/// Matrix title, the heat map, and the selected risk's summary below it.
class RiskMatrixCard extends StatelessWidget {
  final RiskMatrix matrix;
  final Risk? selected;

  const RiskMatrixCard({
    super.key,
    required this.matrix,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final selected = this.selected;
    return AppCard(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'مصفوفة المخاطر — عدد المخاطر',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: HaseenColors.navy,
            ),
          ),
          SizedBox(height: 12.h),
          RiskMatrixGrid(matrix: matrix, selected: selected),
          if (selected != null) ...[
            SizedBox(height: 14.h),
            const Divider(color: HaseenColors.soft, height: 1),
            SizedBox(height: 12.h),
            RiskDetailsSummary(risk: selected),
          ],
        ],
      ),
    );
  }
}
