import '../../../../core/errors/failure.dart';

/// Accepting a deal already accepted, or rejecting one already rejected.
class DealAlreadyDecidedFailure extends Failure {
  const DealAlreadyDecidedFailure({
    super.message = 'This deal already has that decision.',
  });
}

/// Choosing a contract length for a deal that wasn't accepted.
class DealNotAcceptedFailure extends Failure {
  const DealNotAcceptedFailure({
    super.message = 'Only an accepted deal has a contract length.',
  });
}
