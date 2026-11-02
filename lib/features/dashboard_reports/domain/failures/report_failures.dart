import '../../../../core/errors/failure.dart';

/// The recipient (or the copy) isn't an email address.
class InvalidReportRecipientFailure extends Failure {
  const InvalidReportRecipientFailure({
    super.message = 'The report recipient is not a valid email address.',
  });
}
