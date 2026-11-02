import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/inspector.dart';
import '../cubits/schedule_visit_form_state.dart';
import 'schedule_visit_inspector_card.dart';

/// "المفتش" heading with the auto-assign link, over a two-column grid of inspectors.
class ScheduleVisitInspectorPicker extends StatelessWidget {
  final ScheduleVisitFormState form;
  final ValueChanged<Inspector> onSelect;
  final VoidCallback onAutoAssign;

  const ScheduleVisitInspectorPicker({
    super.key,
    required this.form,
    required this.onSelect,
    required this.onAutoAssign,
  });

  @override
  Widget build(BuildContext context) {
    final suggested = form.suggestedInspector;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'المفتش',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: HaseenColors.navy,
                ),
              ),
            ),
            TextButton(
              onPressed: onAutoAssign,
              style: TextButton.styleFrom(foregroundColor: HaseenColors.teal),
              child: Text(
                'توزيع تلقائي حسب عبء العمل',
                style: TextStyle(
                  fontSize: 12.5.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8.h,
          crossAxisSpacing: 8.w,
          childAspectRatio: 3.6,
          children: [
            for (final inspector in form.schedule.inspectors)
              ScheduleVisitInspectorCard(
                inspector: inspector,
                weeklyVisits: form.schedule.visitCountFor(inspector),
                selected: inspector == form.inspector,
                suggested: inspector == suggested,
                busy: form.isBusy(inspector),
                onTap: () => onSelect(inspector),
              ),
          ],
        ),
      ],
    );
  }
}
