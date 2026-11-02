import '../../../../core/errors/failure.dart';
import '../../domain/entities/monthly_report.dart';
import '../../domain/entities/report_delivery.dart';

/// User-facing reports-page text.
class ReportsMessages {
  ReportsMessages._();

  static const intro =
      'يُنشأ تقرير شهري تلقائياً لكل منشأة متعاقدة، ويجمع التفتيشات والبلاغات والفحوصات والإصلاحات خلال الشهر.';

  static String summary(int facilities, int sent) =>
      '$facilities منشآت متعاقدة · $sent تقارير مُرسلة';

  static const noFacilities =
      'لا توجد منشآت متعاقدة بعد. اقبل عقود العملاء من صفحة «العروض والعقود».';

  /// Shown after "sending": the delivery is recorded in Firebase, but
  /// nothing is emailed until a mail service exists.
  static String sent(ReportDelivery delivery) =>
      'سُجّل التقرير كمُرسَل إلى ${delivery.to}. الإرسال الفعلي بالبريد يحتاج ربط خدمة البريد';

  /// Why the reports could not load, worded so the admin can fix it.
  static String loadFailed(Failure failure) => switch (failure) {
    ForbiddenFailure() =>
      'لا توجد صلاحية لقراءة بيانات التقارير (clients أو visits أو risks أو corrective_actions أو report_deliveries). راجع قواعد Firestore.',
    NetworkFailure() => _offline,
    _ => failure.message,
  };

  static String sendFailed(Failure failure) => switch (failure) {
    ForbiddenFailure() =>
      'لا توجد صلاحية لحفظ الإرسال في جدول report_deliveries. راجع قواعد Firestore.',
    NetworkFailure() => _offline,
    _ => 'تعذّر تسجيل إرسال التقرير. حاول مرة أخرى.',
  };

  static const _offline =
      'تعذّر الاتصال بالخادم. تحقق من الإنترنت وحاول مرة أخرى.';

  static String subject(MonthlyReport report) =>
      'التقرير الشهري للسلامة — ${report.facility.name} — ${report.month.label}';

  static String carriedOver(MonthlyReport report) => report.openCount > 0
      ? '${report.openCount} بنود ما زالت مفتوحة وتُرحَّل للشهر القادم.'
      : 'جميع البنود مغلقة.';

  static const noActivities = 'لا توجد أنشطة مسجلة لهذه المنشأة خلال الشهر.';
}

/// Columns of the reports table, in display order, with their flex widths.
class ReportsTableConfig {
  ReportsTableConfig._();

  static const headers = [
    'المنشأة',
    'تفتيش',
    'بلاغات',
    'فحوصات',
    'إصلاحات',
    'الإجمالي',
    'الحالة',
    'الإجراءات',
  ];

  static const columnFlex = [4, 1, 1, 1, 1, 1, 2, 4];
}
