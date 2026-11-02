import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';
import '../../domain/entities/operation_rule.dart';
import '../config/settings_texts.dart';
import 'operation_rule_row.dart';

/// "قواعد التشغيل": every operating rule with its setting, read-only.
class OperationRulesCard extends StatelessWidget {
  final List<OperationRule> rules;

  const OperationRulesCard({super.key, required this.rules});

  @override
  Widget build(BuildContext context) => AppCard(
    padding: EdgeInsets.fromLTRB(18.w, 16.h, 18.w, 8.h),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(SettingsTexts.rulesTitle, style: AppTextStyles.cardTitle),
        SizedBox(height: 8.h),
        for (final rule in rules) OperationRuleRow(rule: rule),
      ],
    ),
  );
}
