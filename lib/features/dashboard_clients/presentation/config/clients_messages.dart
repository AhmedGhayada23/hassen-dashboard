import '../../../../core/errors/failure.dart';
import '../../domain/entities/client.dart';
import '../../domain/failures/client_failures.dart';

/// User-facing clients-page messages; failures carry no UI text of their own.
class ClientsMessages {
  ClientsMessages._();

  static const noClients = 'لا يوجد عملاء بعد. أضف أول عميل من «+ عميل جديد».';
  static const noClientsInStage = 'لا يوجد عملاء في هذه المرحلة';
  static const noSectors =
      'لا توجد قطاعات في جدول sectors. أضفها من Firebase Console أولاً.';

  static String added(Client client, bool schedulePreInspection) =>
      schedulePreInspection
      ? 'أُضيف ${client.name} — بانتظار جدولة الفحص الأولي'
      : 'أُضيف ${client.name} إلى سجل العملاء';

  /// Why the clients could not load, worded so the admin can fix it.
  static String loadFailed(Failure failure) => switch (failure) {
    ForbiddenFailure() =>
      'لا توجد صلاحية لقراءة جدول clients. راجع قواعد Firestore.',
    NetworkFailure() =>
      'تعذّر الاتصال بالخادم. تحقق من الإنترنت وحاول مرة أخرى.',
    _ => failure.message,
  };

  /// Why the "new client" form could not open (its sectors and inspectors
  /// are read from Firebase).
  static String formFailed(Failure failure) => switch (failure) {
    ForbiddenFailure() =>
      'لا توجد صلاحية لقراءة القطاعات أو المفتشين. راجع قواعد Firestore.',
    NetworkFailure() =>
      'تعذّر الاتصال بالخادم. تحقق من الإنترنت وحاول مرة أخرى.',
    _ => 'تعذّر تحميل بيانات نموذج العميل. حاول مرة أخرى.',
  };

  static String addFailed(Failure failure) => switch (failure) {
    DuplicateClientFailure() => 'هذه المنشأة مسجلة مسبقاً',
    ForbiddenFailure() =>
      'لا توجد صلاحية لحفظ العميل في جدول clients. راجع قواعد Firestore.',
    NetworkFailure() =>
      'تعذّر الاتصال بالخادم. تحقق من الإنترنت وحاول مرة أخرى.',
    _ => 'تعذّرت إضافة العميل. حاول مرة أخرى.',
  };
}
