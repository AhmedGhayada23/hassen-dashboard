import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../config/clients_layout_config.dart';

class ClientTableHeader extends StatelessWidget {
  const ClientTableHeader({super.key});

  static const labels = [
    'العميل',
    'القطاع',
    'الفروع',
    'المرحلة',
    'ملاحظات مفتوحة',
    'المطابقة',
  ];

  @override
  Widget build(BuildContext context) => Container(
    color: HaseenColors.tableHeader,
    padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 11.h),
    child: Row(
      children: [
        for (var i = 0; i < labels.length; i++)
          Expanded(
            flex: ClientsLayoutConfig.columnFlex[i],
            child: Text(labels[i], style: AppTextStyles.tableHeader),
          ),
      ],
    ),
  );
}
