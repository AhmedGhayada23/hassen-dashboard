import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/constants/app_icons.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_text_styles.dart';
import '../../../../../core/utils/extensions.dart';
import '../../../../../core/widgets/app_card.dart';
import '../../../../../core/widgets/app_svg_icon.dart';
import '../../../domain/entities/contract_alert.dart';
import '../overview_empty_note.dart';

class ContractAlertCard extends StatelessWidget {
  final List<ContractAlert> alerts;
  final VoidCallback onManageContracts;

  const ContractAlertCard({
    super.key,
    required this.alerts,
    required this.onManageContracts,
  });

  @override
  Widget build(BuildContext context) => AppCard(
    padding: EdgeInsets.all(18.r),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('تنبيهات العقود', style: AppTextStyles.cardTitle),
        SizedBox(height: 12.h),
        if (alerts.isEmpty) ...[
          const OverviewEmptyNote('لا توجد عقود تنتهي خلال 60 يوماً.'),
          SizedBox(height: 4.h),
        ],
        for (final alert in alerts) ...[
          ContractAlertTile(alert: alert),
          SizedBox(height: 12.h),
        ],
        OutlinedButton(
          onPressed: onManageContracts,
          style: OutlinedButton.styleFrom(
            foregroundColor: HaseenColors.navy,
            minimumSize: Size(0, 38.h),
            side: const BorderSide(color: HaseenColors.chipBorder),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          child: Text(
            'إدارة العقود',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.sp),
          ),
        ),
      ],
    ),
  );
}

class ContractAlertTile extends StatelessWidget {
  final ContractAlert alert;

  const ContractAlertTile({super.key, required this.alert});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.all(12.r),
    decoration: BoxDecoration(
      color: HaseenColors.warningSoft,
      borderRadius: BorderRadius.circular(10.r),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSvgIcon(
          AppIcons.clock,
          size: 18.sp,
          color: HaseenColors.warningTextDark,
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'عقد ${alert.client}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                TextSpan(
                  text:
                      ' ينتهي في ${alert.endDate.isoDate} (بعد ${alert.daysRemaining} يوماً). أعدّ عرض التجديد.',
                ),
              ],
            ),
            style: TextStyle(
              fontSize: 13.sp,
              color: HaseenColors.warningTextDark,
              height: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
}
