/// Field rules and messages of the "new client" form, as in the original.
class AddClientValidator {
  AddClientValidator._();

  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  /// Digits, spaces and "+", 7–15 characters.
  static final _phonePattern = RegExp(r'^[+0-9 ]{7,15}$');

  /// Required, and not one of [existingNames].
  static String? name(String? value, Set<String> existingNames) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'أدخل اسم المنشأة';
    if (existingNames.contains(name)) return 'هذه المنشأة مسجلة مسبقاً';
    return null;
  }

  static String? sector(String? value) => value == null ? 'اختر القطاع' : null;

  /// A whole number of at least 1.
  static String? branches(String? value) =>
      (int.tryParse(value?.trim() ?? '') ?? 0) < 1 ? 'أدخل عدداً صحيحاً' : null;

  static String? contactName(String? value) =>
      (value == null || value.trim().isEmpty) ? 'أدخل اسم جهة التواصل' : null;

  /// Email or phone is required; a given email must look like an address.
  static String? email(String? value, {required String phone}) {
    final email = value?.trim() ?? '';
    if (email.isEmpty && phone.trim().isEmpty) {
      return 'أدخل البريد أو رقم الهاتف';
    }
    if (email.isNotEmpty && !_emailPattern.hasMatch(email)) {
      return 'صيغة البريد غير صحيحة';
    }
    return null;
  }

  /// Optional: only a non-empty value is checked.
  static String? phone(String? value) {
    final phone = value?.trim() ?? '';
    return (phone.isNotEmpty && !_phonePattern.hasMatch(phone))
        ? 'رقم الهاتف غير صحيح'
        : null;
  }
}
