import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/report_month.dart';
import 'report_input_decoration.dart';

/// "الشهر" with its picker, then how many facilities and reports sent.
class ReportsMonthBar extends StatelessWidget {
  final List<ReportMonth> months;
  final ReportMonth month;
  final String summary;
  final ValueChanged<ReportMonth> onMonthSelected;

  const ReportsMonthBar({
    super.key,
    required this.months,
    required this.month,
    required this.summary,
    required this.onMonthSelected,
  });

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 12.w,
    runSpacing: 8.h,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Text(
        'الشهر',
        style: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          color: HaseenColors.navy,
        ),
      ),
      SizedBox(
        width: 170.w,
        child: DropdownButtonFormField<ReportMonth>(
          key: ValueKey(month),
          initialValue: month,
          isDense: true,
          decoration: reportInputDecoration(),
          items: [
            for (final m in months)
              DropdownMenuItem(
                value: m,
                child: Text(m.label, style: TextStyle(fontSize: 13.sp)),
              ),
          ],
          onChanged: (m) {
            if (m != null) onMonthSelected(m);
          },
        ),
      ),
      Text(
        summary,
        style: TextStyle(fontSize: 12.5.sp, color: HaseenColors.muted),
      ),
    ],
  );
}
