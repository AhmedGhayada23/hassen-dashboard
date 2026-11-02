import '../../../../core/errors/failure.dart';

/// A client with this name is already registered.
class DuplicateClientFailure extends Failure {
  const DuplicateClientFailure({
    super.message = 'A client with this name already exists.',
  });
}
