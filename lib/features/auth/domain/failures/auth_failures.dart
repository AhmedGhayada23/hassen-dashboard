import '../../../../core/errors/failure.dart';

/// Wrong email or password (or no such account).
class InvalidCredentialsFailure extends Failure {
  const InvalidCredentialsFailure({
    super.message = 'Invalid email or password.',
  });
}

/// The account exists but is not an admin, or has no profile in `users`.
class AccessDeniedFailure extends Failure {
  const AccessDeniedFailure({
    super.message = 'This account may not use the dashboard.',
  });
}

/// The account was disabled by an administrator.
class UserDisabledFailure extends Failure {
  const UserDisabledFailure({super.message = 'This account is disabled.'});
}

/// Too many failed attempts; the service is throttling sign-ins.
class TooManyAttemptsFailure extends Failure {
  const TooManyAttemptsFailure({
    super.message = 'Too many attempts. Try again later.',
  });
}

/// The account's profile could not be read (e.g. database rules refused it).
class ProfileUnavailableFailure extends Failure {
  const ProfileUnavailableFailure({
    super.message = 'The account profile could not be read.',
  });
}
