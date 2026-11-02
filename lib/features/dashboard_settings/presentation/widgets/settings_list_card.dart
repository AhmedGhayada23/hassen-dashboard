import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_card.dart';

/// A settings card listing rows under a titled header, with an optional
/// header action.
class SettingsListCard extends StatelessWidget {
  final String title;
  final Widget? action;
  final List<Widget> rows;

  const SettingsListCard({
    super.key,
    required this.title,
    required this.rows,
    this.action,
  });

  @override
  Widget build(BuildContext context) => AppCard(
    clipBehavior: Clip.antiAlias,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: HaseenColors.line)),
          ),
          child: Row(
            children: [
              Expanded(child: Text(title, style: AppTextStyles.cardTitle)),
              ?action,
            ],
          ),
        ),
        ...rows,
      ],
    ),
  );
}

/// One row of a [SettingsListCard], divided from the next by a soft line.
class SettingsListRow extends StatelessWidget {
  final List<Widget> children;

  const SettingsListRow({super.key, required this.children});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: HaseenColors.soft)),
    ),
    child: Row(children: children),
  );
}

/// The bold navy name that leads a settings row.
class SettingsRowName extends StatelessWidget {
  final String text;

  const SettingsRowName(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: TextStyle(
      fontSize: 13.sp,
      fontWeight: FontWeight.w700,
      color: HaseenColors.navy,
    ),
  );
}
