import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/visit.dart';
import '../../domain/entities/visit_facility.dart';
import '../../domain/entities/visit_schedule.dart';
import '../../domain/entities/visit_scheduling_options.dart';
import '../cubits/schedule_visit_form_cubit.dart';
import '../cubits/schedule_visit_form_state.dart';
import 'schedule_visit_conflict_notice.dart';
import 'schedule_visit_field.dart';
import 'schedule_visit_footer.dart';
import 'schedule_visit_inspector_picker.dart';
import 'schedule_visit_tasks_section.dart';

/// Opens the booking form; completes with the new visit, or null if cancelled.
/// With [facility], the visit is booked there and the facility can't be
/// changed.
Future<Visit?> showScheduleVisitDialog(
  BuildContext context, {
  required VisitSchedule schedule,
  required VisitSchedulingOptions options,
  VisitFacility? facility,
}) => showDialog<Visit>(
  context: context,
  builder: (_) => Directionality(
    textDirection: TextDirection.rtl,
    child: BlocProvider(
      create: (_) => ScheduleVisitFormCubit(
        schedule: schedule,
        options: options,
        facility: facility,
      ),
      child: ScheduleVisitDialog(isFacilityFixed: facility != null),
    ),
  ),
);

/// "جدولة زيارة": facility, type, day and time, then an inspector — suggested
/// by workload, with clashes flagged — the visit's tasks and a note.
/// Expects a [ScheduleVisitFormCubit] above it.
class ScheduleVisitDialog extends StatefulWidget {
  /// Shows the facility read-only instead of a picker.
  final bool isFacilityFixed;

  const ScheduleVisitDialog({super.key, this.isFacilityFixed = false});

  @override
  State<ScheduleVisitDialog> createState() => _ScheduleVisitDialogState();
}

class _ScheduleVisitDialogState extends State<ScheduleVisitDialog> {
  // Booked with the visit, for the inspector.
  final _note = TextEditingController();

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _pickTime(ScheduleVisitFormCubit cubit) async {
    final form = cubit.state;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: form.hour, minute: form.minute),
    );
    if (picked != null) cubit.selectTime(picked.hour, picked.minute);
  }

  static String _facilityLabel(VisitFacility f) =>
      f.isContracted ? f.name : '${f.name} — غير متعاقد';

  void _submit(ScheduleVisitFormCubit cubit) {
    final visit = cubit.submit(note: _note.text);
    if (visit != null) Navigator.pop(context, visit);
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ScheduleVisitFormCubit>();
    return BlocBuilder<ScheduleVisitFormCubit, ScheduleVisitFormState>(
      builder: (context, form) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
        ),
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 560.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TitleBar(onClose: () => Navigator.pop(context)),
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 18.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const ScheduleVisitFieldLabel('العميل / المنشأة'),
                      if (widget.isFacilityFixed)
                        ScheduleVisitFixedFacility(
                          label: _facilityLabel(form.facility),
                        )
                      else
                        DropdownButtonFormField(
                          initialValue: form.facility,
                          decoration: scheduleVisitInputDecoration(),
                          items: [
                            for (final f in cubit.options.facilities)
                              scheduleVisitOption(f, _facilityLabel(f)),
                          ],
                          onChanged: (f) {
                            if (f != null) cubit.selectFacility(f);
                          },
                        ),
                      SizedBox(height: 16.h),
                      const ScheduleVisitFieldLabel('نوع الزيارة'),
                      DropdownButtonFormField(
                        // Rebuilt when choosing a facility switches the type.
                        key: ValueKey(form.type),
                        initialValue: form.type,
                        decoration: scheduleVisitInputDecoration(),
                        items: [
                          for (final t in cubit.options.visitTypes)
                            scheduleVisitOption(t, t),
                        ],
                        onChanged: (t) {
                          if (t != null) cubit.selectType(t);
                        },
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const ScheduleVisitFieldLabel('اليوم'),
                                DropdownButtonFormField(
                                  initialValue: form.day,
                                  decoration: scheduleVisitInputDecoration(),
                                  items: [
                                    for (final d in form.schedule.days)
                                      scheduleVisitOption(
                                        d,
                                        form.schedule.isToday(d)
                                            ? '${d.label} (اليوم)'
                                            : d.label,
                                      ),
                                  ],
                                  onChanged: (d) {
                                    if (d != null) cubit.selectDay(d);
                                  },
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 12.w),
                          SizedBox(
                            width: 140.w,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const ScheduleVisitFieldLabel('الوقت'),
                                OutlinedButton.icon(
                                  onPressed: () => _pickTime(cubit),
                                  icon: Icon(Icons.schedule, size: 18.sp),
                                  label: Text(
                                    form.time,
                                    style: TextStyle(fontSize: 14.sp),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: HaseenColors.navy,
                                    minimumSize: Size.fromHeight(48.h),
                                    side: const BorderSide(
                                      color: HaseenColors.fieldBorder,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8.r),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      ScheduleVisitInspectorPicker(
                        form: form,
                        onSelect: cubit.selectInspector,
                        onAutoAssign: cubit.assignSuggestedInspector,
                      ),
                      if (form.hasConflict) ...[
                        SizedBox(height: 12.h),
                        const ScheduleVisitConflictNotice(),
                      ],
                      SizedBox(height: 16.h),
                      ScheduleVisitTasksSection(
                        form: form,
                        onToggle: cubit.toggleTask,
                        onAdd: cubit.addTask,
                        onRemove: cubit.removeTask,
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          const ScheduleVisitFieldLabel('ملاحظات للمفتش'),
                          SizedBox(width: 6.w),
                          Padding(
                            padding: EdgeInsets.only(bottom: 6.h),
                            child: Text(
                              'اختياري',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: HaseenColors.muted,
                              ),
                            ),
                          ),
                        ],
                      ),
                      TextField(
                        controller: _note,
                        maxLines: 2,
                        decoration: scheduleVisitInputDecoration(),
                      ),
                    ],
                  ),
                ),
              ),
              ScheduleVisitFooter(
                canSubmit: !form.hasConflict,
                onSubmit: () => _submit(cubit),
                onCancel: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TitleBar extends StatelessWidget {
  final VoidCallback onClose;

  const _TitleBar({required this.onClose});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.fromLTRB(20.w, 12.h, 12.w, 12.h),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: HaseenColors.line)),
    ),
    child: Row(
      children: [
        Expanded(
          child: Text(
            'جدولة زيارة',
            style: TextStyle(
              fontSize: 17.sp,
              fontWeight: FontWeight.w700,
              color: HaseenColors.navy,
            ),
          ),
        ),
        IconButton(
          tooltip: 'إغلاق',
          onPressed: onClose,
          icon: Icon(Icons.close, size: 20.sp, color: HaseenColors.muted),
        ),
      ],
    ),
  );
}
