import 'dart:math';

/// The first password a new account gets, handed to the employee by the admin.
class TemporaryPassword {
  TemporaryPassword._();

  static const length = 10;

  // No look-alikes (0/O, 1/l/I) so it can be read out or copied by hand.
  static const _upper = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
  static const _lower = 'abcdefghijkmnpqrstuvwxyz';
  static const _digits = '23456789';

  /// [length] characters with at least one upper-case letter, one
  /// lower-case letter and one digit, from a cryptographically secure source.
  static String generate([Random? random]) {
    final rng = random ?? Random.secure();
    String pick(String from) => from[rng.nextInt(from.length)];
    const all = _upper + _lower + _digits;
    final chars = [
      pick(_upper),
      pick(_lower),
      pick(_digits),
      for (var i = 3; i < length; i++) pick(all),
    ]..shuffle(rng);
    return chars.join();
  }
}
