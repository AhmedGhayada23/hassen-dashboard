import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/inspection_template.dart';
import '../config/settings_texts.dart';
import 'inspection_template_row.dart';
import 'settings_list_card.dart';

/// "نماذج الفحص": every inspection template, with "+ نموذج".
class InspectionTemplatesCard extends StatelessWidget {
  final List<InspectionTemplate> templates;
  final VoidCallback onAddTemplate;

  const InspectionTemplatesCard({
    super.key,
    required this.templates,
    required this.onAddTemplate,
  });

  @override
  Widget build(BuildContext context) => SettingsListCard(
    title: SettingsTexts.templatesTitle,
    action: TextButton(
      onPressed: onAddTemplate,
      style: TextButton.styleFrom(foregroundColor: HaseenColors.teal),
      child: Text(
        SettingsTexts.addTemplate,
        // Material's default 14, scaled like the rest of the page.
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
      ),
    ),
    rows: [for (final t in templates) InspectionTemplateRow(template: t)],
  );
}
