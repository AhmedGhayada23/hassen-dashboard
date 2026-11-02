/// Field rules and messages of the "add employee" form, as in the original.
class AddEmployeeValidator {
  AddEmployeeValidator._();

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// Digits, spaces and "+", 7–15 characters.
  static final _phonePattern = RegExp(r'^[+0-9 ]{7,15}$');

  static String? fullName(String? value) =>
      (value == null || value.trim().isEmpty) ? 'أدخل الاسم الكامل' : null;

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'أدخل البريد الإلكتروني';
    if (!_emailPattern.hasMatch(value.trim())) return 'صيغة البريد غير صحيحة';
    return null;
  }

  /// Optional: only a non-empty value is checked.
  static String? phone(String? value) =>
      (value != null && value.isNotEmpty && !_phonePattern.hasMatch(value))
      ? 'رقم الهاتف غير صحيح'
      : null;
}
