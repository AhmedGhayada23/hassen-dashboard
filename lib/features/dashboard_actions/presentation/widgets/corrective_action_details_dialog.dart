import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/corrective_action.dart';
import '../config/action_severity_style.dart';
import '../config/action_status_style.dart';
import 'action_due_pill.dart';

Future<void> showCorrectiveActionDetailsDialog(
  BuildContext context,
  CorrectiveAction action,
) => showDialog<void>(
  context: context,
  builder: (_) => CorrectiveActionDetailsDialog(action: action),
);

class CorrectiveActionDetailsDialog extends StatelessWidget {
  final CorrectiveAction action;

  const CorrectiveActionDetailsDialog({super.key, required this.action});

  @override
  Widget build(BuildContext context) => Directionality(
    textDirection: TextDirection.rtl,
    child: AlertDialog(
      title: Text(
        action.title,
        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Fact(label: 'الرقم', value: action.id),
          _Fact(label: 'المنشأة', value: action.facility),
          _Fact(label: 'الخطورة', value: action.severity.style.label),
          _Fact(label: 'المسؤول', value: action.owner),
          _Fact(label: 'الحالة', value: action.status.style.label),
          SizedBox(height: 8.h),
          ActionDuePill(action: action),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إغلاق'),
        ),
      ],
    ),
  );
}

class _Fact extends StatelessWidget {
  final String label, value;

  const _Fact({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: 6.h),
    child: Row(
      children: [
        SizedBox(
          width: 70.w,
          child: Text(
            label,
            style: TextStyle(fontSize: 13.sp, color: HaseenColors.muted),
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}
