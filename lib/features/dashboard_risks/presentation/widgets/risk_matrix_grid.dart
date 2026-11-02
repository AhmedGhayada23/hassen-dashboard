import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/risk.dart';
import '../../domain/entities/risk_matrix.dart';
import 'risk_matrix_cell.dart';

/// 5 × 5 grid laid out left-to-right (severity 1 → 5) regardless of the app's
/// RTL, with likelihood 5 → 1 top to bottom as the matrix already orders it.
class RiskMatrixGrid extends StatelessWidget {
  final RiskMatrix matrix;

  /// The selected risk, whose cell gets outlined.
  final Risk? selected;

  const RiskMatrixGrid({
    super.key,
    required this.matrix,
    required this.selected,
  });

  @override
  Widget build(BuildContext context) {
    final axisLabel = TextStyle(fontSize: 11.sp, color: HaseenColors.muted);
    bool isSelected(RiskMatrixCell c) =>
        c.likelihood == selected?.likelihood &&
        c.severity == selected?.severity;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RotatedBox(
            quarterTurns: 3,
            child: Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: Text('الاحتمال', style: axisLabel),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                for (final row in matrix.rows)
                  Padding(
                    padding: EdgeInsets.only(bottom: 4.h),
                    child: Row(
                      children: [
                        for (final cell in row)
                          Expanded(
                            child: Padding(
                              padding: EdgeInsets.only(
                                right: cell.severity < Risk.maxRating ? 4.w : 0,
                              ),
                              child: RiskMatrixCellView(
                                cell: cell,
                                isSelected: isSelected(cell),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                Text('الشدة', style: axisLabel),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
