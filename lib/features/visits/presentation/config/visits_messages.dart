import '../../../../core/errors/failure.dart';
import '../../domain/entities/visit.dart';
import '../../domain/failures/visit_clash_failure.dart';
import '../widgets/schedule_visit_conflict_notice.dart';

/// User-facing visits-page messages; failures carry no UI text of their own.
class VisitsMessages {
  VisitsMessages._();

  static const noInspectors =
      'لا يوجد مفتشو سلامة في جدول users. أضفهم من صفحة الفريق أولاً.';
  static const noFacilities =
      'لا يوجد عملاء في جدول clients. أضفهم من صفحة العملاء أولاً.';

  /// A client booked from its page that the schedule doesn't list.
  static String facilityNotFound(String name) =>
      'لم يُعثر على «$name» في جدول clients. حدّث الصفحة وحاول مرة أخرى.';

  static String scheduled(Visit v) =>
      'تمت جدولة الزيارة وإسنادها إلى ${v.inspector.name} — ${v.day.label} ${v.time}';

  /// Why the schedule could not load, worded so the admin can fix it.
  static String loadFailed(Failure failure) => switch (failure) {
    ForbiddenFailure() =>
      'لا توجد صلاحية لقراءة الزيارات أو المفتشين أو العملاء. راجع قواعد Firestore.',
    NetworkFailure() =>
      'تعذّر الاتصال بالخادم. تحقق من الإنترنت وحاول مرة أخرى.',
    _ => failure.message,
  };

  static String scheduleFailed(Failure failure) => switch (failure) {
    VisitClashFailure() => ScheduleVisitConflictNotice.message,
    ForbiddenFailure() =>
      'لا توجد صلاحية لحفظ الزيارة في جدول visits أو مهامها في جدول tasks. راجع قواعد Firestore.',
    NetworkFailure() =>
      'تعذّر الاتصال بالخادم. تحقق من الإنترنت وحاول مرة أخرى.',
    _ => 'تعذّرت جدولة الزيارة. حاول مرة أخرى.',
  };
}
