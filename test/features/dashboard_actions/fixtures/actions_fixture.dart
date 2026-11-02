import 'package:hassen_dashboard/features/dashboard_actions/domain/entities/action_due_status.dart';
import 'package:hassen_dashboard/features/dashboard_actions/domain/entities/action_severity.dart';
import 'package:hassen_dashboard/features/dashboard_actions/domain/entities/action_status.dart';
import 'package:hassen_dashboard/features/dashboard_actions/domain/entities/corrective_action.dart';

/// The nine actions exactly as the original single-file screen hard-coded them,
/// in column order. Written independently of the data layer to catch drift.
CorrectiveAction _a(
  String id,
  String title,
  String facility,
  ActionSeverity severity,
  String owner,
  String dueText,
  ActionDueStatus due,
  ActionStatus status,
) => CorrectiveAction(
  id: id,
  title: title,
  facility: facility,
  severity: severity,
  owner: owner,
  dueText: dueText,
  dueStatus: due,
  status: status,
);

final expectedActions = [
  _a(
    'CA-0431',
    'إزالة الأسرّة من أمام مخرج الطوارئ 2',
    'مستشفى الشفاء',
    ActionSeverity.critical,
    'مسؤول السلامة',
    '24 ساعة',
    ActionDueStatus.late,
    ActionStatus.open,
  ),
  _a(
    'CA-0428',
    'تغطية التمديدات في الأرشيف',
    'بلدية غزة',
    ActionSeverity.high,
    'مدير الخدمات',
    '14 يوماً',
    ActionDueStatus.ok,
    ActionStatus.open,
  ),
  _a(
    'CA-0412',
    'تركيب حاجز على آلة القص 3',
    'مصنع العودة',
    ActionSeverity.high,
    'مدير الإنتاج',
    'متأخر 6 أيام',
    ActionDueStatus.late,
    ActionStatus.inProgress,
  ),
  _a(
    'CA-0405',
    'تركيب نقاط تثبيت للعمل على ارتفاع',
    'شركة كهرباء غزة',
    ActionSeverity.high,
    'مهندس السلامة',
    '5 أيام',
    ActionDueStatus.soon,
    ActionStatus.inProgress,
  ),
  _a(
    'CA-0399',
    'توفير ملصقات لمواد التنظيف',
    'مستشفى الشفاء',
    ActionSeverity.medium,
    'مسؤول المرافق',
    '12 يوماً',
    ActionDueStatus.ok,
    ActionStatus.inProgress,
  ),
  _a(
    'CA-0398',
    'تحديث لوحات الإرشاد',
    'بلدية غزة',
    ActionSeverity.medium,
    'مسؤول المرافق',
    'الدليل مرفوع',
    ActionDueStatus.ok,
    ActionStatus.pendingClosure,
  ),
  _a(
    'CA-0390',
    'استبدال طفايات منتهية',
    'بنك فلسطين',
    ActionSeverity.high,
    'مدير المرافق',
    'الدليل مرفوع',
    ActionDueStatus.ok,
    ActionStatus.pendingClosure,
  ),
  _a(
    'CA-0377',
    'فحص التمديدات المؤقتة',
    'مصنع العودة',
    ActionSeverity.medium,
    'فريق الكهرباء',
    'أُغلقت 25/10',
    ActionDueStatus.done,
    ActionStatus.closed,
  ),
  _a(
    'CA-0371',
    'تدريب فريق المناولة',
    'شركة كهرباء غزة',
    ActionSeverity.low,
    'منسق التدريب',
    'أُغلقت 22/10',
    ActionDueStatus.done,
    ActionStatus.closed,
  ),
];

/// Card ids per column, top to bottom, as in the original board.
const expectedColumnIds = [
  ['CA-0431', 'CA-0428'],
  ['CA-0412', 'CA-0405', 'CA-0399'],
  ['CA-0398', 'CA-0390'],
  ['CA-0377', 'CA-0371'],
];
