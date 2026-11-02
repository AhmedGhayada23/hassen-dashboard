import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/status_badge.dart';
import '../../domain/entities/report_activity.dart';
import '../config/report_styles.dart';

/// The month's activities in the report: numbered, dated, typed, described,
/// owned and with their status, under a navy header.
class ReportActivityTable extends StatelessWidget {
  static const _headers = [
    '#',
    'التاريخ',
    'النوع',
    'الوصف',
    'المسؤول',
    'الحالة',
  ];
  static const _flex = [1, 3, 2, 6, 3, 3];

  final List<ReportActivity> activities;

  const ReportActivityTable({super.key, required this.activities});

  @override
  Widget build(BuildContext context) {
    final cell = TextStyle(fontSize: 12.5.sp);
    final padding = EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h);
    Widget pill(ReportPillStyle s) => Align(
      alignment: AlignmentDirectional.centerStart,
      child: StatusBadge(s.label, s.background, s.foreground),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          color: HaseenColors.navy,
          padding: padding,
          child: Row(
            children: [
              for (final (i, label) in _headers.indexed)
                Expanded(
                  flex: _flex[i],
                  child: Text(
                    label,
                    style: cell.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        for (final (i, a) in activities.indexed)
          Container(
            padding: padding,
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: HaseenColors.line)),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: _flex[0],
                  child: Text(
                    '${i + 1}',
                    style: cell.copyWith(color: HaseenColors.muted),
                  ),
                ),
                Expanded(
                  flex: _flex[1],
                  child: Text(a.date, style: cell),
                ),
                Expanded(flex: _flex[2], child: pill(a.type.style)),
                Expanded(
                  flex: _flex[3],
                  child: Text(
                    a.description,
                    style: cell.copyWith(color: HaseenColors.navy),
                  ),
                ),
                Expanded(
                  flex: _flex[4],
                  child: Text(
                    a.owner,
                    style: cell.copyWith(color: HaseenColors.neutralText),
                  ),
                ),
                Expanded(flex: _flex[5], child: pill(a.status.style)),
              ],
            ),
          ),
      ],
    );
  }
}
