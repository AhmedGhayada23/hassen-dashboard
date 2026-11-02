import '../../../../core/errors/failure.dart';

/// User-facing overview text; failures carry no UI text of their own.
class OverviewMessages {
  OverviewMessages._();

  /// Why the overview could not load, worded so the admin can fix it.
  static String loadFailed(Failure failure) => switch (failure) {
    ForbiddenFailure() =>
      'لا توجد صلاحية لقراءة بيانات النظرة العامة (clients أو visits أو risks أو corrective_actions). راجع قواعد Firestore.',
    NetworkFailure() =>
      'تعذّر الاتصال بالخادم. تحقق من الإنترنت وحاول مرة أخرى.',
    _ => failure.message,
  };
}
