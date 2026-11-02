import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/client.dart';
import '../config/client_stage_style.dart';

/// Label/value lines for the selected client, in the original order.
class ClientDetailsFacts extends StatelessWidget {
  final Client client;

  const ClientDetailsFacts({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    final facts = [
      ('المرحلة', client.stage.style.label),
      ('المدينة / العنوان', client.city),
      ('العقد', client.contract),
      ('تكرار الزيارات', client.visits),
      ('المفتش المسؤول', client.inspector),
      ('جهة التواصل', client.contact),
      ('ملاحظات مفتوحة', '${client.openFindings}'),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (label, value) in facts)
          Container(
            padding: EdgeInsets.only(bottom: 8.h, top: 2.h),
            margin: EdgeInsets.only(bottom: 8.h),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: HaseenColors.soft)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(fontSize: 13.sp, color: HaseenColors.muted),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    value,
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: HaseenColors.navy,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
