import '../../../../core/errors/failure.dart';
import '../../domain/entities/team_member.dart';
import '../../domain/failures/team_failures.dart';

/// User-facing team-page messages; failures carry no UI text of their own.
class TeamMessages {
  TeamMessages._();

  static const passwordCopied = 'تم نسخ كلمة المرور';
  static const noRoles =
      'لا توجد أدوار في جدول roles. أضف الأدوار من Firebase Console أولاً.';

  static String added(TeamMember member) =>
      'أُضيف ${member.name} — كلمة المرور المؤقتة في بطاقته لتسليمها له.';

  /// Why the roster could not load, worded so the admin can fix it.
  static String loadFailed(Failure failure) => switch (failure) {
    ForbiddenFailure() =>
      'لا توجد صلاحية لقراءة جدول users. تأكد أن معرّف (ID) مستندك في users '
          'هو نفس UID حسابك في Authentication، وأن قواعد Firestore منشورة.',
    NetworkFailure() =>
      'تعذّر الاتصال بالخادم. تحقق من الإنترنت وحاول مرة أخرى.',
    _ => failure.message,
  };

  static String addFailed(Failure failure) => switch (failure) {
    EmailAlreadyInUseFailure() => 'هذا البريد الإلكتروني مستخدم لحساب آخر.',
    ForbiddenFailure() =>
      'لا توجد صلاحية لحفظ بيانات الموظف. راجع قواعد Firestore.',
    NetworkFailure() =>
      'تعذّر الاتصال بالخادم. تحقق من الإنترنت وحاول مرة أخرى.',
    _ => 'تعذّرت إضافة الموظف. حاول مرة أخرى.',
  };
}
