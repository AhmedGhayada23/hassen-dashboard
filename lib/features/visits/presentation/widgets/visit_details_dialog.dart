import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/visit.dart';
import '../config/visit_task_source_label.dart';
import 'visit_status_pill.dart';
import 'visit_task_text.dart';

/// Slides in [VisitDetailsPanel] from the start (right) edge.
Future<void> showVisitDetailsDialog(BuildContext context, Visit visit) =>
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'إغلاق',
      barrierColor: HaseenColors.navy.withValues(alpha: .5),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (_, _, _) => Directionality(
        textDirection: TextDirection.rtl,
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: VisitDetailsPanel(visit: visit),
        ),
      ),
      transitionBuilder: (_, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    );

/// The visit and its tasks, as the inspector sees them on opening it in the
/// field app.
class VisitDetailsPanel extends StatelessWidget {
  final Visit visit;

  const VisitDetailsPanel({super.key, required this.visit});

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    elevation: 12,
    child: SizedBox(
      width: 440.w,
      height: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PanelHeader(visit: visit),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(20.r),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'مهام الزيارة',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: HaseenColors.navy,
                        ),
                      ),
                    ),
                    Text(
                      visitTaskCount(visit.tasks.length),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        color: HaseenColors.teal,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                _FieldAppNotice(inspector: visit.inspector.name),
                SizedBox(height: 12.h),
                for (final (i, task) in visit.tasks.indexed)
                  VisitTaskTile(task: task, number: i + 1),
                if (visit.note.isNotEmpty) ...[
                  Divider(color: HaseenColors.soft, height: 24.h),
                  Text(
                    'ملاحظات للمفتش',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: HaseenColors.navy,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    visit.note,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: HaseenColors.neutralText,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 14.h),
            decoration: const BoxDecoration(
              color: HaseenColors.tableHeader,
              border: Border(top: BorderSide(color: HaseenColors.line)),
            ),
            child: Text(
              'بعد التنفيذ يرسل المفتش النتائج معاً إلى «مراجعة التفتيش».',
              style: TextStyle(fontSize: 12.sp, color: HaseenColors.muted),
            ),
          ),
        ],
      ),
    ),
  );
}

class _PanelHeader extends StatelessWidget {
  final Visit visit;

  const _PanelHeader({required this.visit});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.fromLTRB(20.w, 16.h, 12.w, 16.h),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: HaseenColors.line)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                visit.facility,
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: HaseenColors.navy,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                '${visit.type} · ${visit.day.label} · ${visit.time} · '
                '${visit.inspector.name}',
                style: TextStyle(fontSize: 12.5.sp, color: HaseenColors.muted),
              ),
            ],
          ),
        ),
        VisitStatusPill(status: visit.status),
        IconButton(
          tooltip: 'إغلاق',
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close, size: 20.sp, color: HaseenColors.muted),
        ),
      ],
    ),
  );
}

class _FieldAppNotice extends StatelessWidget {
  final String inspector;

  const _FieldAppNotice({required this.inspector});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
    decoration: BoxDecoration(
      color: HaseenColors.infoSoft,
      borderRadius: BorderRadius.circular(8.r),
    ),
    child: Row(
      children: [
        Icon(Icons.smartphone, size: 16.sp, color: HaseenColors.infoText),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
            'هذا ما يراه $inspector في التطبيق عند فتح الزيارة.',
            style: TextStyle(fontSize: 12.sp, color: HaseenColors.infoText),
          ),
        ),
      ],
    ),
  );
}
