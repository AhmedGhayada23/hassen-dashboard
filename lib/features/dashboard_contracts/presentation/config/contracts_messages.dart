import '../../../../core/errors/failure.dart';
import '../../domain/entities/deal.dart';
import '../../domain/failures/deal_failures.dart';

/// User-facing contracts-page text; failures carry no UI text of their own.
class ContractsMessages {
  ContractsMessages._();

  static const intro =
      'كل عميل جديد يُدرج هنا تلقائياً بانتظار القرار. بعد القبول اختر مدة التعاقد.';

  static const noClients =
      'لا يوجد عملاء بعد. أضفهم من صفحة «العملاء والمنشآت».';

  /// Confirms an accept or reject decision.
  static String decided(Deal deal) => deal.isAccepted
      ? 'قُبل العقد — ${deal.client}. اختر مدة التعاقد'
      : 'رُفض العقد — ${deal.client}';

  /// Asked before cancelling an accepted contract.
  static String confirmCancel(Deal deal) => 'رفض عقد ${deal.client}؟';

  static const confirmCancelDetail =
      'سيُلغى العقد ومدته، وتعود مرحلة العميل إلى «عرض سعر».';

  static String loadFailed(Failure failure) => switch (failure) {
    ForbiddenFailure() =>
      'لا توجد صلاحية لقراءة جدول clients. راجع قواعد Firestore.',
    NetworkFailure() => _offline,
    _ => failure.message,
  };

  static String actionFailed(Failure failure) => switch (failure) {
    DealAlreadyDecidedFailure() => 'لهذا العرض نفس القرار مسبقاً.',
    DealNotAcceptedFailure() => 'اقبل العقد أولاً ثم اختر مدة التعاقد.',
    ForbiddenFailure() =>
      'لا توجد صلاحية لتعديل العميل في جدول clients. راجع قواعد Firestore.',
    NetworkFailure() => _offline,
    _ => 'تعذّر حفظ التغيير. حاول مرة أخرى.',
  };

  static const _offline =
      'تعذّر الاتصال بالخادم. تحقق من الإنترنت وحاول مرة أخرى.';
}

/// `yyyy-MM-dd`, as the table shows contract dates.
String formatDealDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';
