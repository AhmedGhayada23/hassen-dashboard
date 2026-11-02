/// The login form's field rules and messages, unchanged from the original
/// screen. Used by the form fields and, as a guard, by `LoginCubit`.
class LoginValidator {
  LoginValidator._();

  static const minPasswordLength = 8;
  static const emailRequired = 'أدخل البريد الإلكتروني';
  static const emailInvalid = 'صيغة البريد غير صحيحة';
  static const passwordTooShort = 'كلمة المرور 8 أحرف على الأقل';

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return emailRequired;
    if (!_emailPattern.hasMatch(value.trim())) return emailInvalid;
    return null;
  }

  static String? password(String? value) =>
      (value == null || value.length < minPasswordLength)
      ? passwordTooShort
      : null;

  static bool isValid({required String email, required String password}) =>
      LoginValidator.email(email) == null &&
      LoginValidator.password(password) == null;
}
