import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/risk_matrix.dart';
import '../config/risk_level_style.dart';

/// Square heat-map cell: filled when it holds risks, tinted when empty,
/// outlined in navy when it is the selected risk's cell.
class RiskMatrixCellView extends StatelessWidget {
  final RiskMatrixCell cell;
  final bool isSelected;

  const RiskMatrixCellView({
    super.key,
    required this.cell,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    final style = cell.level.style;
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: cell.isEmpty ? style.empty : style.filled,
          borderRadius: BorderRadius.circular(5.r),
          border: Border.all(
            color: isSelected ? HaseenColors.navy : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          cell.isEmpty ? '' : '${cell.count}',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: cell.isEmpty ? style.onEmpty : style.onFilled,
          ),
        ),
      ),
    );
  }
}
