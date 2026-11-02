import '../../../../core/errors/failure.dart';
import '../../domain/failures/auth_failures.dart';

/// User-facing login messages; failures carry no UI text of their own.
class LoginMessages {
  LoginMessages._();

  static const invalidCredentials =
      'البريد الإلكتروني أو كلمة المرور غير صحيحة.';
  static const accessDenied =
      'هذا الحساب لا يملك صلاحية الدخول إلى لوحة التحكم.';
  static const userDisabled = 'تم تعطيل هذا الحساب. تواصل مع مدير النظام.';
  static const tooManyAttempts =
      'محاولات كثيرة متتالية. انتظر قليلاً ثم حاول مرة أخرى.';
  static const network =
      'تعذّر الاتصال بالخادم. تحقق من الإنترنت وحاول مرة أخرى.';
  static const profileUnavailable =
      'تعذّر التحقق من صلاحيات الحساب. حاول مرة أخرى.';
  static const signInFailed = 'تعذّر تسجيل الدخول. حاول مرة أخرى.';
  static const forgotPassword =
      'تواصل مع مدير النظام لإعادة تعيين كلمة المرور.';

  static String forFailure(Failure failure) => switch (failure) {
    InvalidCredentialsFailure() => invalidCredentials,
    AccessDeniedFailure() => accessDenied,
    UserDisabledFailure() => userDisabled,
    TooManyAttemptsFailure() => tooManyAttempts,
    NetworkFailure() => network,
    ProfileUnavailableFailure() => profileUnavailable,
    _ => signInFailed,
  };
}
