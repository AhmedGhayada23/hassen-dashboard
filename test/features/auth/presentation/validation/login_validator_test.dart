import 'package:flutter_test/flutter_test.dart';
import 'package:hassen_dashboard/features/auth/presentation/validation/login_validator.dart';

void main() {
  group('email', () {
    test('is required (empty, blank or null)', () {
      for (final value in [null, '', '   ']) {
        expect(
          LoginValidator.email(value),
          'أدخل البريد الإلكتروني',
          reason: '"$value"',
        );
      }
    });

    test('rejects malformed addresses', () {
      for (final value in [
        'name',
        'name@',
        '@haseen.ps',
        'name@haseen',
        'na me@haseen.ps',
        'a@b@c.d',
      ]) {
        expect(
          LoginValidator.email(value),
          'صيغة البريد غير صحيحة',
          reason: value,
        );
      }
    });

    test('accepts valid addresses, ignoring surrounding spaces', () {
      for (final value in [
        'name@haseen.ps',
        '  name@haseen.ps  ',
        'a.b+c@mail.example.org',
      ]) {
        expect(LoginValidator.email(value), isNull, reason: value);
      }
    });
  });

  group('password', () {
    test('needs at least 8 characters', () {
      for (final value in [null, '', '1234567']) {
        expect(
          LoginValidator.password(value),
          'كلمة المرور 8 أحرف على الأقل',
          reason: '"$value"',
        );
      }
      expect(LoginValidator.password('12345678'), isNull);
    });

    test('has no other rules (spaces count, no complexity required)', () {
      expect(LoginValidator.password('        '), isNull);
      expect(LoginValidator.password('aaaaaaaa'), isNull);
    });
  });

  test('isValid needs both fields valid', () {
    expect(
      LoginValidator.isValid(email: 'name@haseen.ps', password: '12345678'),
      isTrue,
    );
    expect(
      LoginValidator.isValid(email: 'name@haseen.ps', password: '1234567'),
      isFalse,
    );
    expect(LoginValidator.isValid(email: 'bad', password: '12345678'), isFalse);
  });
}
