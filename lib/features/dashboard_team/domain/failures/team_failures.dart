import '../../../../core/errors/failure.dart';

/// An account with this email already exists.
class EmailAlreadyInUseFailure extends Failure {
  const EmailAlreadyInUseFailure({
    super.message = 'An account with this email already exists.',
  });
}
