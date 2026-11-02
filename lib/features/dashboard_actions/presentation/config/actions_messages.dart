import '../../../../core/errors/failure.dart';

/// User-facing corrective-actions text; failures carry no UI text of their own.
class ActionsMessages {
  ActionsMessages._();

  /// Why the board could not load, worded so the admin can fix it.
  static String loadFailed(Failure failure) => switch (failure) {
    ForbiddenFailure() =>
      'لا توجد صلاحية لقراءة جدول corrective_actions. راجع قواعد Firestore.',
    NetworkFailure() => _offline,
    _ => failure.message,
  };

  static String moveFailed(Failure failure) => switch (failure) {
    ForbiddenFailure() =>
      'لا توجد صلاحية لتعديل الإجراء في جدول corrective_actions. راجع قواعد Firestore.',
    NetworkFailure() => _offline,
    NotFoundFailure() => 'لم يعد هذا الإجراء موجوداً. حدّث الصفحة.',
    _ => 'تعذّر تحديث حالة الإجراء',
  };

  static const _offline =
      'تعذّر الاتصال بالخادم. تحقق من الإنترنت وحاول مرة أخرى.';
}
