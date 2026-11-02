import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/visit_task.dart';
import '../config/visit_task_source_label.dart';
import '../cubits/schedule_visit_form_state.dart';
import 'schedule_visit_field.dart';
import 'visit_task_text.dart';

/// "مهام الزيارة" in the booking form: the automatic tasks with a tick each,
/// the hand-added ones with a delete, and a field to add more.
class ScheduleVisitTasksSection extends StatefulWidget {
  static const addTaskLabel = '+ إضافة مهمة';
  static const newTaskHint = 'مهمة إضافية، مثل: فحص غرفة المولد';

  final ScheduleVisitFormState form;
  final void Function(VisitTask task, {required bool included}) onToggle;
  final ValueChanged<String> onAdd;
  final ValueChanged<int> onRemove;

  const ScheduleVisitTasksSection({
    super.key,
    required this.form,
    required this.onToggle,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  State<ScheduleVisitTasksSection> createState() =>
      _ScheduleVisitTasksSectionState();
}

class _ScheduleVisitTasksSectionState extends State<ScheduleVisitTasksSection> {
  final _newTask = TextEditingController();

  @override
  void dispose() {
    _newTask.dispose();
    super.dispose();
  }

  void _add() {
    if (_newTask.text.trim().isEmpty) return;
    widget.onAdd(_newTask.text);
    _newTask.clear();
  }

  @override
  Widget build(BuildContext context) {
    final form = widget.form;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(child: ScheduleVisitFieldLabel('مهام الزيارة')),
            Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: Text(
                visitTaskCount(form.tasks.length),
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w700,
                  color: HaseenColors.teal,
                ),
              ),
            ),
          ],
        ),
        Text(
          'هذه القائمة تظهر للمفتش في التطبيق عند فتح الزيارة.',
          style: TextStyle(fontSize: 12.sp, color: HaseenColors.muted),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: HaseenColors.line),
            borderRadius: BorderRadius.circular(10.r),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final task in form.autoTasks)
                _TaskRow(
                  task: task,
                  included: form.isIncluded(task),
                  onToggle: (included) =>
                      widget.onToggle(task, included: included),
                ),
              for (final (i, task) in form.manualTasks.indexed)
                _TaskRow(
                  task: task,
                  included: true,
                  onRemove: () => widget.onRemove(i),
                ),
              Container(
                color: HaseenColors.tableHeader,
                padding: EdgeInsets.all(10.r),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _newTask,
                        onSubmitted: (_) => _add(),
                        style: TextStyle(fontSize: 13.sp),
                        decoration: scheduleVisitInputDecoration().copyWith(
                          hintText: ScheduleVisitTasksSection.newTaskHint,
                          hintStyle: TextStyle(
                            color: HaseenColors.fieldHint,
                            fontSize: 13.sp,
                          ),
                          fillColor: Colors.white,
                          filled: true,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    OutlinedButton(
                      onPressed: _add,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: HaseenColors.navy,
                        minimumSize: Size(0, 40.h),
                        side: const BorderSide(color: HaseenColors.navy),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        ScheduleVisitTasksSection.addTaskLabel,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// One task in the form: faded when unticked; a hand-added one can't be
/// unticked, only deleted.
class _TaskRow extends StatelessWidget {
  final VisitTask task;
  final bool included;
  final ValueChanged<bool>? onToggle;
  final VoidCallback? onRemove;

  const _TaskRow({
    required this.task,
    required this.included,
    this.onToggle,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: included ? 1 : .55,
    child: Container(
      padding: EdgeInsets.fromLTRB(8.w, 6.h, 12.w, 6.h),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: HaseenColors.soft)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: included,
            activeColor: HaseenColors.navy,
            onChanged: onToggle == null
                ? null
                : (value) => onToggle!(value ?? false),
            visualDensity: VisualDensity.compact,
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 6.h),
              child: VisitTaskText(task: task),
            ),
          ),
          if (onRemove case final remove?)
            TextButton(
              onPressed: remove,
              style: TextButton.styleFrom(foregroundColor: HaseenColors.red),
              child: Text(
                'حذف',
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
    ),
  );
}
