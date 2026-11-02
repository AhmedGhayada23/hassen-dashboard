import '../../../../core/errors/failure.dart';

/// User-facing risk-register text; failures carry no UI text of their own.
class RisksMessages {
  RisksMessages._();

  static const noRisks = 'لا توجد مخاطر مسجلة بعد في جدول risks.';

  /// Why the register could not load, worded so the admin can fix it.
  static String loadFailed(Failure failure) => switch (failure) {
    ForbiddenFailure() =>
      'لا توجد صلاحية لقراءة جدول risks. راجع قواعد Firestore.',
    NetworkFailure() =>
      'تعذّر الاتصال بالخادم. تحقق من الإنترنت وحاول مرة أخرى.',
    _ => failure.message,
  };
}
