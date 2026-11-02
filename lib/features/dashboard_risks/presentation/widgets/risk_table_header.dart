import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../config/risks_layout_config.dart';

class RiskTableHeader extends StatelessWidget {
  const RiskTableHeader({super.key});

  static const labels = ['الدرجة', 'الخطر', 'المنشأة', 'المسؤول', 'الحالة'];

  @override
  Widget build(BuildContext context) => Container(
    color: HaseenColors.tableHeader,
    padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 11.h),
    child: Row(
      children: [
        for (var i = 0; i < labels.length; i++)
          Expanded(
            flex: RisksLayoutConfig.columnFlex[i],
            child: Text(labels[i], style: AppTextStyles.tableHeader),
          ),
      ],
    ),
  );
}
