import '../../../../core/errors/failure.dart';

/// The inspector already has a visit on that day and time.
class VisitClashFailure extends Failure {
  const VisitClashFailure({
    super.message = 'The inspector already has a visit at this slot.',
  });
}
